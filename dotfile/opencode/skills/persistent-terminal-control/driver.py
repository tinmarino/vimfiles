#!/usr/bin/env python3
"""Persistent shell driver with per-command output capture."""

from __future__ import annotations

import argparse
import base64
import json
import os
import pty
import select
import shlex
import signal
import socket
import subprocess
import sys
import time
import uuid
from pathlib import Path


STATE_ROOT = Path("/tmp/opencode/persistent-terminal-control")


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Persistent shell driver with explicit output markers",
    )
    subparsers = parser.add_subparsers(dest="subcommand", required=True)

    parser_start = subparsers.add_parser("start")
    parser_start.add_argument("--name", required=True)
    parser_start.add_argument("--cwd")
    parser_start.add_argument("command", nargs=argparse.REMAINDER)

    parser_daemon = subparsers.add_parser("daemon")
    parser_daemon.add_argument("--name", required=True)
    parser_daemon.add_argument("--cwd")
    parser_daemon.add_argument("command", nargs=argparse.REMAINDER)

    parser_run = subparsers.add_parser("run")
    parser_run.add_argument("--name", required=True)
    parser_run.add_argument("--timeout", type=float, default=10.0)
    parser_run.add_argument("command")

    parser_stop = subparsers.add_parser("stop")
    parser_stop.add_argument("--name", required=True)

    parser_status = subparsers.add_parser("status")
    parser_status.add_argument("--name", required=True)

    return parser


def state_dir(name: str) -> Path:
    return STATE_ROOT / name


def state_paths(name: str) -> dict[str, Path]:
    root = state_dir(name)
    return {
        "root": root,
        "socket": root / "driver.sock",
        "meta": root / "meta.json",
        "stdout": root / "daemon.stdout.log",
        "stderr": root / "daemon.stderr.log",
    }


def normalize_command(command_parts: list[str]) -> list[str]:
    parts = list(command_parts)
    if parts and parts[0] == "--":
        parts = parts[1:]
    if not parts:
        return ["bash", "--noprofile", "--norc", "-i"]
    return parts


def read_meta(name: str) -> dict:
    paths = state_paths(name)
    if not paths["meta"].exists():
        raise SystemExit(f"No session metadata for {name}")
    return json.loads(paths["meta"].read_text())


def process_alive(pid: int) -> bool:
    try:
        os.kill(pid, 0)
    except OSError:
        return False
    return True


def start_session(args: argparse.Namespace) -> int:
    paths = state_paths(args.name)
    paths["root"].mkdir(parents=True, exist_ok=True)
    if paths["meta"].exists():
        meta = json.loads(paths["meta"].read_text())
        if process_alive(meta.get("pid", -1)) and paths["socket"].exists():
            print(json.dumps(meta, indent=2))
            return 0

    command = normalize_command(args.command)
    stderr_file = paths["stderr"].open("ab")
    child = subprocess.Popen(
        [
            sys.executable,
            str(Path(__file__).resolve()),
            "daemon",
            "--name",
            args.name,
            *( ["--cwd", args.cwd] if args.cwd else [] ),
            "--",
            *command,
        ],
        stdin=subprocess.DEVNULL,
        stdout=subprocess.DEVNULL,
        stderr=stderr_file,
        start_new_session=True,
        cwd=args.cwd or None,
    )
    stderr_file.close()

    deadline = time.time() + 5.0
    while time.time() < deadline:
        if paths["socket"].exists() and paths["meta"].exists():
            print(paths["meta"].read_text())
            return 0
        if child.poll() is not None:
            raise SystemExit(f"Driver daemon exited with {child.returncode}")
        time.sleep(0.05)
    raise SystemExit("Timed out waiting for driver socket")


def wait_for(fd: int, predicate, timeout: float) -> str:
    deadline = time.time() + timeout
    chunks: list[str] = []
    while time.time() < deadline:
        ready, _, _ = select.select([fd], [], [], 0.2)
        if not ready:
            continue
        try:
            data = os.read(fd, 65536)
        except BlockingIOError:
            continue
        if not data:
            continue
        text = data.decode(errors="ignore")
        chunks.append(text)
        current = "".join(chunks)
        if predicate(current):
            return current
    raise TimeoutError("Timed out waiting for shell output")


def build_wrapped_command(command: str, marker: str) -> str:
    encoded = base64.b64encode(command.encode()).decode()
    return (
        "printf '__OC_START__:%s\\n' '" + marker + "'; "
        + "printf '%s' '" + encoded + "' | base64 -d | bash; "
        + "__oc_status=$?; "
        + "printf '__OC_EXIT__:%s:%s\\n' '" + marker + "' \"$__oc_status\"; "
        + "printf '__OC_END__:%s\\n' '" + marker + "'"
    )


def daemon_main(args: argparse.Namespace) -> int:
    paths = state_paths(args.name)
    paths["root"].mkdir(parents=True, exist_ok=True)
    if paths["socket"].exists():
        paths["socket"].unlink()

    command = normalize_command(args.command)
    pid, fd = pty.fork()
    if pid == 0:
        if args.cwd:
            os.chdir(args.cwd)
        os.execvp(command[0], command)

    os.set_blocking(fd, False)
    time.sleep(0.2)
    try:
        wait_for(fd, lambda output: output.endswith(("> ", "$ ", "# ", "% ")) or output, 1.0)
    except TimeoutError:
        pass

    try:
        os.write(fd, b"export PS1= PS2= PROMPT_COMMAND=; stty -echo\r")
        time.sleep(0.1)
        try:
            wait_for(fd, lambda output: True, 0.5)
        except TimeoutError:
            pass
    except OSError:
        pass

    meta = {
        "name": args.name,
        "pid": os.getpid(),
        "child_pid": pid,
        "socket": str(paths["socket"]),
        "cwd": args.cwd or os.getcwd(),
        "command": command,
        "started_at": time.time(),
    }
    paths["meta"].write_text(json.dumps(meta, indent=2))

    server = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    server.bind(str(paths["socket"]))
    server.listen(1)

    while True:
        connection, _ = server.accept()
        with connection:
            payload = b""
            while not payload.endswith(b"\n"):
                chunk = connection.recv(65536)
                if not chunk:
                    break
                payload += chunk
            if not payload:
                continue
            request = json.loads(payload.decode())
            if request.get("action") == "stop":
                try:
                    os.write(fd, b"exit\r")
                except OSError:
                    pass
                response = {"ok": True}
                connection.sendall((json.dumps(response) + "\n").encode())
                break

            marker = uuid.uuid4().hex.upper()[:12]
            wrapped = build_wrapped_command(request["command"], marker)
            started = time.perf_counter()
            os.write(fd, wrapped.encode() + b"\r")

            end_marker = f"__OC_END__:{marker}"
            exit_marker = f"__OC_EXIT__:{marker}:"
            output = wait_for(fd, lambda text: end_marker in text, request.get("timeout", 10.0))
            duration_ms = round((time.perf_counter() - started) * 1000, 1)

            normalized = output.replace("\r\n", "\n").replace("\r", "\n")
            start_token = f"__OC_START__:{marker}\n"
            start_index = normalized.find(start_token)
            exit_index = normalized.find(exit_marker, start_index)
            end_index = normalized.find(end_marker, exit_index)
            stdout = ""
            exit_code = None
            if start_index != -1 and exit_index != -1:
                stdout = normalized[start_index + len(start_token):exit_index]
                exit_line = normalized[exit_index:].splitlines()[0]
                exit_code = int(exit_line.rsplit(":", 1)[1])
            response = {
                "ok": True,
                "marker": marker,
                "stdout": stdout.rstrip("\r\n"),
                "exit_code": exit_code,
                "duration_ms": duration_ms,
            }
            connection.sendall((json.dumps(response) + "\n").encode())

    server.close()
    try:
        paths["socket"].unlink()
    except FileNotFoundError:
        pass
    return 0


def request_session(name: str, payload: dict) -> dict:
    meta = read_meta(name)
    if not process_alive(meta.get("pid", -1)):
        raise SystemExit(f"Driver daemon for {name} is not running")
    client = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    client.connect(meta["socket"])
    with client:
        client.sendall((json.dumps(payload) + "\n").encode())
        response = b""
        while not response.endswith(b"\n"):
            chunk = client.recv(65536)
            if not chunk:
                break
            response += chunk
    return json.loads(response.decode())


def run_command(args: argparse.Namespace) -> int:
    response = request_session(
        args.name,
        {
            "action": "run",
            "command": args.command,
            "timeout": args.timeout,
        },
    )
    print(json.dumps(response, indent=2))
    return 0


def stop_session(args: argparse.Namespace) -> int:
    response = request_session(args.name, {"action": "stop"})
    print(json.dumps(response, indent=2))
    return 0


def status_session(args: argparse.Namespace) -> int:
    meta = read_meta(args.name)
    meta["alive"] = process_alive(meta.get("pid", -1))
    print(json.dumps(meta, indent=2))
    return 0


def main() -> int:
    STATE_ROOT.mkdir(parents=True, exist_ok=True)
    parser = build_parser()
    args = parser.parse_args()
    if args.subcommand == "start":
        return start_session(args)
    if args.subcommand == "daemon":
        return daemon_main(args)
    if args.subcommand == "run":
        return run_command(args)
    if args.subcommand == "stop":
        return stop_session(args)
    if args.subcommand == "status":
        return status_session(args)
    raise SystemExit(f"Unknown subcommand {args.subcommand}")


if __name__ == "__main__":
    raise SystemExit(main())
