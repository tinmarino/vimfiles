#!/usr/bin/env python3

"""
Load Claude and OpenCode session history for ai-dashboard.

This module keeps the storage parsing shared between the Rich terminal view and
the lazy-loaded local web UI.

"""

from __future__ import annotations

# Parse local session stores
from dataclasses import dataclass, field
from datetime import UTC, datetime
from json import JSONDecodeError, loads as json_loads
from pathlib import Path
from re import compile as re_compile
from shlex import quote as shlex_quote
from sqlite3 import Row, connect as sqlite_connect
from threading import Lock
from time import time as time_time


PATH_HOME = Path.home()
PATH_CLAUDE_HISTORY = PATH_HOME / ".claude/history.jsonl"
PATH_CLAUDE_PROJECTS = PATH_HOME / ".claude/projects"
PATH_OPENCODE_DB = PATH_HOME / ".local/share/opencode/opencode.db"
PATH_OPENCODE_DIFF = PATH_HOME / ".local/share/opencode/storage/session_diff"
RE_UUID = re_compile(
    r"^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$"
)


@dataclass
class PromptRecord:
    """ Store one captured user prompt. """

    time_ms: int | None
    text: str

    def to_dict(self) -> dict:
        """ Return a JSON-serializable prompt payload. """
        return {
            "time_ms": self.time_ms,
            "time_text": DashboardStore.format_time_ms(self.time_ms),
            "title": DashboardStore.build_title(self.text, fallback="Prompt"),
            "text": self.text,
        }


@dataclass
class SessionSummary:
    """ Store one root-session summary row. """

    source: str
    session_id: str
    start_ms: int | None
    end_ms: int | None
    cwd: str
    cwd_short: str
    folder_name: str
    title: str
    source_file: str
    resume_command: str

    def to_dict(self) -> dict:
        """ Return a JSON-serializable summary payload. """
        return {
            "source": self.source,
            "session_id": self.session_id,
            "start_ms": self.start_ms,
            "end_ms": self.end_ms,
            "start_text": DashboardStore.format_time_ms(self.start_ms),
            "end_text": DashboardStore.format_time_ms(self.end_ms),
            "cwd": self.cwd,
            "cwd_short": self.cwd_short,
            "folder_name": self.folder_name,
            "title": self.title,
            "source_file": self.source_file,
            "resume_command": self.resume_command,
        }


@dataclass
class SessionDetail(SessionSummary):
    """ Store one root or child session with prompts and nested children. """

    kind: str
    model_label: str
    description: str
    prompts: list[PromptRecord] = field(default_factory=list)
    children: list["SessionDetail"] = field(default_factory=list)

    def to_dict(self) -> dict:
        """ Return a JSON-serializable detail payload. """
        payload = super().to_dict()
        payload.update(
            {
                "kind": self.kind,
                "model_label": self.model_label,
                "description": self.description,
                "prompts": [prompt.to_dict() for prompt in self.prompts],
                "children": [child.to_dict() for child in self.children],
            }
        )
        return payload


class DashboardStore:
    """ Cache shared session summaries and lazily-loaded detail payloads. """

    def __init__(self, max_root_sessions: int = 100):
        """ Build the shared store from local Claude and OpenCode storage. """
        # Cache the configured root-session cap
        self.max_root_sessions = max_root_sessions

        # Reuse parsed Claude transcripts between summary and detail loads
        self._claude_transcript_info_cache: dict[str, tuple[int, dict]] = {}

        # Protect the lazily-loaded detail cache
        self._detail_lock = Lock()
        self._detail_cache: dict[tuple[str, str], tuple[int, SessionDetail]] = {}

        # Load the cheap summary sources first
        self._last_refresh_ts = 0.0
        self.refresh()

    @staticmethod
    def format_time_ms(time_ms: int | None) -> str:
        """ Return one compact local datetime line. """
        # Handle missing timestamps early
        if time_ms is None:
            return "-"
        return DashboardStore.datetime_from_ms(time_ms).strftime("%Y-%m-%d %H:%M:%S")

    @staticmethod
    def datetime_from_ms(time_ms: int) -> datetime:
        """ Return the local datetime object for *time_ms*. """
        return datetime.fromtimestamp(time_ms / 1000)

    @staticmethod
    def normalize_text(value: str) -> str:
        """ Return a trimmed text block with normalized newlines. """
        return value.replace("\r\n", "\n").replace("\r", "\n").strip()

    @classmethod
    def build_title(cls, value: str, fallback: str) -> str:
        """ Return a compact, readable session title. """
        # Reduce the value to its first logical paragraph
        cleaned = cls.normalize_text(value)
        if not cleaned:
            return fallback
        paragraph = cleaned.split("\n\n", 1)[0]
        single_line = " ".join(paragraph.split())
        if len(single_line) <= 320:
            return single_line
        return single_line[:317].rstrip() + "..."

    @staticmethod
    def shorten_home(path_str: str) -> str:
        """ Replace the home directory prefix with `~` when possible. """
        # Handle empty paths early
        if not path_str:
            return ""
        path = Path(path_str).expanduser()
        try:
            relative = path.relative_to(PATH_HOME)
        except ValueError:
            return path_str
        if str(relative) == ".":
            return "~"
        return f"~/{relative}"

    @staticmethod
    def folder_name(path_str: str) -> str:
        """ Return the basename-like folder label for *path_str*. """
        # Handle empty paths early
        if not path_str:
            return "-"
        name = Path(path_str).name
        return name or path_str

    @staticmethod
    def parse_json(payload: str) -> dict | list | None:
        """ Return parsed JSON or `None` when decoding fails. """
        try:
            return json_loads(payload)
        except JSONDecodeError:
            return None

    @staticmethod
    def parse_time_ms(value: object) -> int | None:
        """ Parse millisecond or ISO timestamps into epoch milliseconds. """
        # Accept numeric timestamps directly
        if isinstance(value, int):
            return value
        if isinstance(value, float):
            return int(value)

        # Parse ISO timestamps used by Claude transcripts
        if isinstance(value, str) and value:
            try:
                parsed = datetime.fromisoformat(value.replace("Z", "+00:00"))
            except ValueError:
                return None
            if parsed.tzinfo is None:
                parsed = parsed.replace(tzinfo=UTC)
            return int(parsed.timestamp() * 1000)
        return None

    @classmethod
    def strip_claude_fork_boilerplate(cls, text: str) -> str:
        """ Drop Claude fork boilerplate and keep only the directive. """
        marker = "Your directive:"
        if marker not in text:
            return text
        return cls.normalize_text(text.split(marker, 1)[1])

    @classmethod
    def extract_claude_text(cls, content: object) -> str:
        """ Extract plain user text from a Claude message payload. """
        # Accept the direct string form first
        if isinstance(content, str):
            return cls.strip_claude_fork_boilerplate(cls.normalize_text(content))

        # Merge explicit text blocks and ignore tool results and images
        if isinstance(content, list):
            text_parts: list[str] = []
            for item in content:
                if not isinstance(item, dict):
                    continue
                if item.get("type") != "text":
                    continue
                text_value = item.get("text")
                if isinstance(text_value, str) and text_value.strip():
                    text_parts.append(text_value)
            merged = cls.normalize_text("\n\n".join(text_parts))
            return cls.strip_claude_fork_boilerplate(merged)

        return ""

    @staticmethod
    def format_opencode_model(model_json: str) -> str:
        """ Return a compact OpenCode model label. """
        # Handle empty or legacy model fields early
        if not model_json:
            return ""
        if not model_json.lstrip().startswith("{"):
            return model_json

        # Read and flatten the stored model object
        model_data = DashboardStore.parse_json(model_json)
        if not isinstance(model_data, dict):
            return model_json
        model_id = str(model_data.get("id") or "")
        provider_id = str(model_data.get("providerID") or "")
        variant = str(model_data.get("variant") or "")
        suffix = "/".join(value for value in (provider_id, variant) if value)
        if model_id and suffix:
            return f"{model_id} / {suffix}"
        return model_id or suffix

    @staticmethod
    def format_claude_model(model_name: str) -> str:
        """ Return a compact Claude model label. """
        if not model_name or model_name == "<synthetic>":
            return ""
        return model_name

    @staticmethod
    def make_opencode_resume_command(cwd: str, session_id: str) -> str:
        """ Return a shell-safe OpenCode resume command. """
        if cwd:
            return f"opencode {shlex_quote(cwd)} --session {session_id}"
        return f"opencode --session {session_id}"

    def get_summary_page(self, source: str, offset: int, limit: int) -> dict:
        """ Return one paged summary response for *source*. """
        self.refresh_if_stale(max_age_sec=5)

        # Select the requested source list
        summaries = self._summary_list_for(source)
        total = len(summaries)

        # Slice the page window defensively
        start = max(0, offset)
        end = total if limit == 0 else max(start, start + max(0, limit))
        items = [summary.to_dict() for summary in summaries[start:end]]
        return {
            "source": source,
            "offset": start,
            "limit": limit,
            "total": total,
            "items": items,
        }

    def list_summaries(self, source: str) -> list[SessionSummary]:
        """ Return the configured summary objects for *source*. """
        self.refresh_if_stale(max_age_sec=5)
        return list(self._summary_list_for(source))

    def refresh(self) -> None:
        """ Rebuild the summary caches from local storage. """
        # Rebuild the source indexes and clear stale caches
        self._claude_transcript_info_cache.clear()
        self._claude_history = self._load_claude_history()
        self._claude_transcripts = self._index_claude_transcripts()
        self._claude_summaries = self._build_claude_summaries()
        self._opencode_summaries = self._build_opencode_summaries()
        with self._detail_lock:
            self._detail_cache.clear()
        self._last_refresh_ts = time_time()

    def refresh_if_stale(self, max_age_sec: int) -> None:
        """ Refresh the summary caches when they are older than *max_age_sec*. """
        if time_time() - self._last_refresh_ts < max_age_sec:
            return
        self.refresh()

    def get_detail(self, source: str, session_id: str) -> SessionDetail:
        """ Return one cached or lazily-loaded session detail. """
        # Reject unsupported sources early
        if source not in ("claude", "opencode"):
            raise ValueError(f"Unsupported source: {source}")
        if not session_id:
            raise ValueError("Missing session_id")

        # Return any cached payload first
        key = (source, session_id)
        with self._detail_lock:
            current_stamp = self._detail_stamp(source=source, session_id=session_id)
            cached = self._detail_cache.get(key)
            if cached is not None and cached[0] == current_stamp:
                return cached[1]

            # Load and cache the detail while holding the lock so parallel
            # requests do not parse the same session twice.
            if source == "claude":
                detail = self._load_claude_detail(session_id)
            else:
                detail = self._load_opencode_detail(session_id)
            self._detail_cache[key] = (current_stamp, detail)
            return detail

    def warm_details(self) -> None:
        """ Warm the detail cache in the background. """
        # Keep a no-op hook so the caller can opt into warming later.
        return

    def _summary_list_for(self, source: str) -> list[SessionSummary]:
        """ Return the configured summary list for *source*. """
        if source == "claude":
            return self._claude_summaries
        if source == "opencode":
            return self._opencode_summaries
        raise ValueError(f"Unsupported source: {source}")

    def _detail_stamp(self, source: str, session_id: str) -> int:
        """ Return a freshness stamp for one cached detail payload. """
        # Use the transcript mtime for Claude sessions when available
        if source == "claude":
            session_file = self._claude_transcripts.get(session_id)
            if session_file and session_file.is_file():
                stamp = int(session_file.stat().st_mtime * 1000)
                child_dir = session_file.parent / session_file.stem / "subagents"
                if child_dir.is_dir():
                    for child_file in child_dir.iterdir():
                        stamp = max(stamp, int(child_file.stat().st_mtime * 1000))
                return stamp
            history = self._claude_history.get(session_id, {})
            return int(history.get("end_ms") or 0)

        # Use the database time_updated value for OpenCode sessions
        if source == "opencode" and PATH_OPENCODE_DB.is_file():
            with sqlite_connect(PATH_OPENCODE_DB) as connection:
                row = connection.execute(
                    "with recursive tree(id) as ("
                    " select id from session where id = ?"
                    " union all"
                    " select session.id from session join tree on session.parent_id = tree.id"
                    ")"
                    " select max(value) from ("
                    "  select max(time_updated) as value from session where id in (select id from tree)"
                    "  union all"
                    "  select max(time_updated) as value from message where session_id in (select id from tree)"
                    "  union all"
                    "  select max(time_updated) as value from part where session_id in (select id from tree)"
                    " )",
                    (session_id,),
                ).fetchone()
            if row is None:
                raise KeyError(session_id)
            return int(row[0] or 0)

        raise ValueError(f"Unsupported source: {source}")

    def _load_claude_history(self) -> dict[str, dict]:
        """ Return Claude history grouped by session id. """
        # Return early when the history file is absent
        if not PATH_CLAUDE_HISTORY.is_file():
            return {}

        # Group prompt entries by session id
        history_map: dict[str, dict] = {}
        with PATH_CLAUDE_HISTORY.open("r", encoding="utf-8") as file_in:
            for raw_line in file_in:
                payload = self.parse_json(raw_line)
                if not isinstance(payload, dict):
                    continue
                session_id = payload.get("sessionId")
                if not isinstance(session_id, str) or not session_id:
                    continue
                time_ms = self.parse_time_ms(payload.get("timestamp"))
                prompt_display = payload.get("display")
                cwd = payload.get("project") if isinstance(payload.get("project"), str) else ""

                entry = history_map.setdefault(
                    session_id,
                    {
                        "cwd": cwd,
                        "start_ms": time_ms,
                        "end_ms": time_ms,
                        "title": "",
                        "prompts": [],
                    },
                )
                if cwd and not entry["cwd"]:
                    entry["cwd"] = cwd
                if time_ms is not None:
                    if entry["start_ms"] is None or time_ms < entry["start_ms"]:
                        entry["start_ms"] = time_ms
                    if entry["end_ms"] is None or time_ms > entry["end_ms"]:
                        entry["end_ms"] = time_ms
                if isinstance(prompt_display, str) and prompt_display.strip():
                    prompt_text = self.normalize_text(prompt_display)
                    if not entry["title"]:
                        entry["title"] = self.build_title(prompt_text, fallback="Claude session")
                    entry["prompts"].append(PromptRecord(time_ms=time_ms, text=prompt_text))
        return history_map

    def _index_claude_transcripts(self) -> dict[str, Path]:
        """ Return root Claude transcript files indexed by session id. """
        # Return early when the projects directory is absent
        if not PATH_CLAUDE_PROJECTS.is_dir():
            return {}

        # Index only root transcript files named by UUID session ids
        transcript_map: dict[str, Path] = {}
        for project_dir in sorted(PATH_CLAUDE_PROJECTS.iterdir()):
            if not project_dir.is_dir():
                continue
            for session_file in project_dir.glob("*.jsonl"):
                session_id = session_file.stem
                if RE_UUID.fullmatch(session_id):
                    transcript_map[session_id] = session_file
        return transcript_map

    def _build_claude_summaries(self) -> list[SessionSummary]:
        """ Return the configured Claude root-session summaries. """
        # Rank the candidate ids using cheap timestamps first
        candidate_ids = sorted(
            set(self._claude_history) | set(self._claude_transcripts),
            key=self._claude_candidate_sort_key,
            reverse=True,
        )
        if self.max_root_sessions > 0:
            parse_budget = min(len(candidate_ids), self.max_root_sessions + 24)
            selected_ids = candidate_ids[:parse_budget]
        else:
            selected_ids = candidate_ids

        # Build summaries from both history and transcript-backed sessions
        summaries: list[SessionSummary] = []
        for session_id in selected_ids:
            entry = self._claude_history.get(session_id, {})
            session_file = self._claude_transcripts.get(session_id)
            parsed = self._get_claude_transcript_info(session_id) if session_file else {
                "start_ms": entry.get("start_ms"),
                "end_ms": entry.get("end_ms"),
                "cwd": entry.get("cwd") or "",
                "model_label": "",
                "title": entry.get("title") or "",
                "prompts": entry.get("prompts") or [],
            }
            prompts = parsed["prompts"] or entry.get("prompts") or []
            cwd = str(parsed["cwd"] or entry.get("cwd") or "")
            title_source = parsed["title"] or entry.get("title") or (prompts[0].text if prompts else "")
            summaries.append(
                SessionSummary(
                    source="claude",
                    session_id=session_id,
                    start_ms=parsed["start_ms"] or entry.get("start_ms"),
                    end_ms=parsed["end_ms"] or entry.get("end_ms"),
                    cwd=cwd,
                    cwd_short=self.shorten_home(cwd),
                    folder_name=self.folder_name(cwd),
                    title=self.build_title(title_source, fallback="Claude session"),
                    source_file=str(session_file) if session_file else str(PATH_CLAUDE_HISTORY),
                    resume_command=f"claude --resume {session_id}",
                )
            )

        # Sort and cap the configured root window
        summaries.sort(key=lambda record: record.end_ms or 0, reverse=True)
        if self.max_root_sessions > 0:
            return summaries[:self.max_root_sessions]
        return summaries

    def _claude_candidate_sort_key(self, session_id: str) -> int:
        """ Return a cheap recency sort key for one Claude root session. """
        history = self._claude_history.get(session_id, {})
        history_end = int(history.get("end_ms") or 0)
        session_file = self._claude_transcripts.get(session_id)
        if session_file is None or not session_file.is_file():
            return history_end
        transcript_mtime = int(session_file.stat().st_mtime * 1000)
        return max(history_end, transcript_mtime)

    def _get_claude_transcript_info(self, session_id: str) -> dict:
        """ Return cached parsed metadata for one Claude transcript. """
        session_file = self._claude_transcripts.get(session_id)
        if session_file is None:
            raise KeyError(session_id)
        current_mtime = int(session_file.stat().st_mtime * 1000)
        cached = self._claude_transcript_info_cache.get(session_id)
        if cached is not None and cached[0] == current_mtime:
            return cached[1]
        parsed = self._parse_claude_transcript(session_file)
        self._claude_transcript_info_cache[session_id] = (current_mtime, parsed)
        return parsed

    def _parse_claude_transcript(self, session_file: Path) -> dict:
        """ Return parsed metadata for one Claude transcript. """
        info = {
            "start_ms": None,
            "end_ms": None,
            "cwd": "",
            "model_label": "",
            "title": "",
            "prompts": [],
        }
        with session_file.open("r", encoding="utf-8") as file_in:
            for raw_line in file_in:
                payload = self.parse_json(raw_line)
                if not isinstance(payload, dict):
                    continue

                time_ms = self.parse_time_ms(payload.get("timestamp"))
                if time_ms is not None:
                    if info["start_ms"] is None:
                        info["start_ms"] = time_ms
                    info["end_ms"] = time_ms

                cwd = payload.get("cwd")
                if isinstance(cwd, str) and cwd and not info["cwd"]:
                    info["cwd"] = cwd

                if payload.get("type") == "assistant":
                    message = payload.get("message")
                    if isinstance(message, dict) and not info["model_label"]:
                        model_name = message.get("model")
                        if isinstance(model_name, str):
                            info["model_label"] = self.format_claude_model(model_name)

                if payload.get("type") != "user":
                    continue
                message = payload.get("message")
                if not isinstance(message, dict):
                    continue
                if message.get("role") != "user":
                    continue
                prompt_text = self.extract_claude_text(message.get("content"))
                if not prompt_text:
                    continue
                if not info["title"]:
                    info["title"] = self.build_title(prompt_text, fallback="Claude session")
                info["prompts"].append(PromptRecord(time_ms=time_ms, text=prompt_text))
        return info

    def _load_claude_children(self, session_file: Path | None) -> list[SessionDetail]:
        """ Return nested Claude child sessions stored beside one root transcript. """
        # Return early when there is no root transcript path
        if session_file is None:
            return []
        child_dir = session_file.parent / session_file.stem / "subagents"
        if not child_dir.is_dir():
            return []

        # Load each child transcript and metadata file
        children: list[SessionDetail] = []
        for meta_path in sorted(child_dir.glob("*.meta.json")):
            meta_payload = self.parse_json(meta_path.read_text(encoding="utf-8"))
            if not isinstance(meta_payload, dict):
                continue
            child_id = meta_path.name.replace(".meta.json", "")
            child_file = meta_path.with_name(f"{child_id}.jsonl")
            child_info = self._parse_claude_transcript(child_file) if child_file.is_file() else {
                "start_ms": None,
                "end_ms": None,
                "cwd": "",
                "model_label": "",
                "title": "",
                "prompts": [],
            }

            # Pick a readable child title and description
            child_name = str(meta_payload.get("name") or child_id)
            child_description = self.normalize_text(str(meta_payload.get("description") or ""))
            title_source = child_info["title"] or child_name
            cwd = str(child_info["cwd"] or "")
            children.append(
                SessionDetail(
                    source="claude",
                    kind="subagent",
                    session_id=child_id,
                    start_ms=child_info["start_ms"],
                    end_ms=child_info["end_ms"],
                    cwd=cwd,
                    cwd_short=self.shorten_home(cwd),
                    folder_name=self.folder_name(cwd),
                    title=self.build_title(title_source, fallback=child_name),
                    source_file=str(child_file) if child_file.is_file() else str(meta_path),
                    resume_command="",
                    model_label=str(child_info["model_label"] or ""),
                    description=child_description or child_name,
                    prompts=child_info["prompts"],
                    children=[],
                )
            )

        # Sort child sessions by recency
        children.sort(key=lambda record: record.end_ms or 0, reverse=True)
        return children

    def _load_claude_detail(self, session_id: str) -> SessionDetail:
        """ Return one Claude root-session detail payload. """
        # Load the fast history fallback first
        history = self._claude_history.get(session_id, {})
        session_file = self._claude_transcripts.get(session_id)
        parsed = self._get_claude_transcript_info(session_id) if session_file else {
            "start_ms": history.get("start_ms"),
            "end_ms": history.get("end_ms"),
            "cwd": history.get("cwd") or "",
            "model_label": "",
            "title": history.get("title") or "",
            "prompts": history.get("prompts") or [],
        }

        # Prefer transcript prompts and timestamps when they exist
        prompts = parsed["prompts"] or history.get("prompts") or []
        cwd = str(parsed["cwd"] or history.get("cwd") or "")
        title_source = parsed["title"] or history.get("title") or (prompts[0].text if prompts else "")
        return SessionDetail(
            source="claude",
            kind="session",
            session_id=session_id,
            start_ms=parsed["start_ms"] or history.get("start_ms"),
            end_ms=parsed["end_ms"] or history.get("end_ms"),
            cwd=cwd,
            cwd_short=self.shorten_home(cwd),
            folder_name=self.folder_name(cwd),
            title=self.build_title(title_source, fallback="Claude session"),
            source_file=str(session_file) if session_file else str(PATH_CLAUDE_HISTORY),
            resume_command=f"claude --resume {session_id}",
            model_label=str(parsed["model_label"] or ""),
            description=self.build_title(title_source, fallback="Claude session"),
            prompts=prompts,
            children=self._load_claude_children(session_file),
        )

    def _build_opencode_summaries(self) -> list[SessionSummary]:
        """ Return the configured OpenCode root-session summaries. """
        # Return early when the database is absent
        if not PATH_OPENCODE_DB.is_file():
            return []

        # Read the configured root window from SQLite
        with sqlite_connect(PATH_OPENCODE_DB) as connection:
            connection.row_factory = Row
            query = (
                "select id, directory, title, time_created, time_updated "
                "from session where parent_id is null order by time_updated desc"
            )
            if self.max_root_sessions > 0:
                query += " limit ?"
                rows = connection.execute(query, (self.max_root_sessions,)).fetchall()
            else:
                rows = connection.execute(query).fetchall()
            root_ids = [row["id"] for row in rows]
            prompt_titles = self._load_opencode_first_prompt_titles(connection, root_ids)

        # Build the configured root summaries
        summaries: list[SessionSummary] = []
        for row in rows:
            cwd = str(row["directory"] or "")
            fallback_title = str(row["title"] or "OpenCode session")
            title = self._choose_opencode_title(
                session_title=fallback_title,
                prompt_title=prompt_titles.get(row["id"], ""),
            )
            diff_path = PATH_OPENCODE_DIFF / f"{row['id']}.json"
            summaries.append(
                SessionSummary(
                    source="opencode",
                    session_id=row["id"],
                    start_ms=row["time_created"],
                    end_ms=row["time_updated"],
                    cwd=cwd,
                    cwd_short=self.shorten_home(cwd),
                    folder_name=self.folder_name(cwd),
                    title=title,
                    source_file=str(diff_path if diff_path.is_file() else PATH_OPENCODE_DB),
                    resume_command=self.make_opencode_resume_command(cwd, row["id"]),
                )
            )
        return summaries

    def _choose_opencode_title(self, session_title: str, prompt_title: str) -> str:
        """ Pick the most readable OpenCode root-session title. """
        # Prefer the generated title unless it is still the default placeholder
        normalized_title = self.normalize_text(session_title)
        prompt_value = self.normalize_text(prompt_title)
        if normalized_title and not normalized_title.startswith("New session -"):
            return self.build_title(normalized_title, fallback="OpenCode session")
        if prompt_value:
            return self.build_title(prompt_value, fallback=normalized_title or "OpenCode session")
        return self.build_title(normalized_title, fallback="OpenCode session")

    def _load_opencode_first_prompt_titles(self, connection, root_ids: list[str]) -> dict[str, str]:
        """ Return first user-prompt titles for selected OpenCode roots. """
        # Handle the empty case early
        if not root_ids:
            return {}

        # Query the prompt parts for the selected root sessions
        placeholders = ", ".join("?" for _ in root_ids)
        message_query = (
            "select id, session_id, time_created, data from message "
            f"where session_id in ({placeholders}) "
            "order by session_id, time_created"
        )
        part_query = (
            "select message_id, session_id, time_created, data from part "
            f"where session_id in ({placeholders}) "
            "order by session_id, time_created"
        )
        message_rows = connection.execute(message_query, root_ids).fetchall()
        part_rows = connection.execute(part_query, root_ids).fetchall()

        # Keep only the first user message per root session
        user_messages: dict[str, dict] = {}
        seen_sessions: set[str] = set()
        for row in message_rows:
            if row["session_id"] in seen_sessions:
                continue
            payload = self.parse_json(row["data"])
            if not isinstance(payload, dict):
                continue
            if payload.get("role") != "user":
                continue
            user_messages[row["id"]] = {
                "session_id": row["session_id"],
                "parts": [],
            }
            seen_sessions.add(row["session_id"])

        # Merge text parts for each first user message
        for row in part_rows:
            message_info = user_messages.get(row["message_id"])
            if message_info is None:
                continue
            payload = self.parse_json(row["data"])
            if not isinstance(payload, dict):
                continue
            if payload.get("type") != "text":
                continue
            text_value = payload.get("text")
            if not isinstance(text_value, str) or not text_value.strip():
                continue
            message_info["parts"].append(self.normalize_text(text_value))

        # Pick the title of each reconstructed prompt
        prompt_titles: dict[str, str] = {}
        for message_info in user_messages.values():
            if not message_info["parts"]:
                continue
            prompt_titles[message_info["session_id"]] = self.build_title(
                "\n\n".join(message_info["parts"]),
                fallback="OpenCode session",
            )
        return prompt_titles

    def _fetch_opencode_tree_rows(self, connection, root_id: str) -> list[Row]:
        """ Return one root OpenCode session and every descendant row. """
        # Expand the selected root through every descendant
        query = (
            "with recursive tree(id) as ("
            " select id from session where id = ?"
            " union all"
            " select session.id from session join tree on session.parent_id = tree.id"
            ")"
            " select id, parent_id, directory, title, agent, model, time_created, time_updated"
            " from session where id in (select id from tree)"
        )
        return connection.execute(query, (root_id,)).fetchall()

    def _load_opencode_prompt_map(self, connection, session_ids: list[str]) -> dict[str, list[PromptRecord]]:
        """ Return grouped OpenCode user prompts for selected session ids. """
        # Handle the empty case early
        if not session_ids:
            return {}

        # Read the raw message and part rows for the selected tree
        placeholders = ", ".join("?" for _ in session_ids)
        message_query = (
            "select id, session_id, time_created, data from message "
            f"where session_id in ({placeholders}) "
            "order by session_id, time_created"
        )
        part_query = (
            "select message_id, session_id, time_created, data from part "
            f"where session_id in ({placeholders}) "
            "order by session_id, time_created"
        )
        message_rows = connection.execute(message_query, session_ids).fetchall()
        part_rows = connection.execute(part_query, session_ids).fetchall()

        # Keep only user messages and collect their text parts
        user_messages: dict[str, dict] = {}
        for row in message_rows:
            payload = self.parse_json(row["data"])
            if not isinstance(payload, dict):
                continue
            if payload.get("role") != "user":
                continue
            user_messages[row["id"]] = {
                "session_id": row["session_id"],
                "time_ms": row["time_created"],
                "parts": [],
            }

        # Merge text parts back into user prompts
        for row in part_rows:
            message_info = user_messages.get(row["message_id"])
            if message_info is None:
                continue
            payload = self.parse_json(row["data"])
            if not isinstance(payload, dict):
                continue
            if payload.get("type") != "text":
                continue
            text_value = payload.get("text")
            if not isinstance(text_value, str) or not text_value.strip():
                continue
            message_info["parts"].append(self.normalize_text(text_value))

        # Group the reconstructed prompts by session id
        prompt_map: dict[str, list[PromptRecord]] = {}
        for message_info in user_messages.values():
            if not message_info["parts"]:
                continue
            prompt_map.setdefault(message_info["session_id"], []).append(
                PromptRecord(
                    time_ms=message_info["time_ms"],
                    text="\n\n".join(message_info["parts"]),
                )
            )
        return prompt_map

    def _load_opencode_detail(self, root_id: str) -> SessionDetail:
        """ Return one OpenCode root-session detail payload. """
        # Return early when the database is absent
        if not PATH_OPENCODE_DB.is_file():
            raise FileNotFoundError(PATH_OPENCODE_DB)

        # Load the selected root tree and its prompts
        with sqlite_connect(PATH_OPENCODE_DB) as connection:
            connection.row_factory = Row
            tree_rows = self._fetch_opencode_tree_rows(connection, root_id)
            prompt_map = self._load_opencode_prompt_map(
                connection,
                [row["id"] for row in tree_rows],
            )

        # Instantiate each node before wiring parent-child links
        detail_map: dict[str, SessionDetail] = {}
        for row in tree_rows:
            session_id = row["id"]
            cwd = str(row["directory"] or "")
            prompts = prompt_map.get(session_id, [])
            raw_title = str(row["title"] or "")
            prompt_title = prompts[0].text if prompts else ""
            title = self._choose_opencode_title(raw_title, prompt_title)
            diff_path = PATH_OPENCODE_DIFF / f"{session_id}.json"
            detail_map[session_id] = SessionDetail(
                source="opencode",
                kind="subagent" if row["parent_id"] else "session",
                session_id=session_id,
                start_ms=row["time_created"],
                end_ms=row["time_updated"],
                cwd=cwd,
                cwd_short=self.shorten_home(cwd),
                folder_name=self.folder_name(cwd),
                title=title,
                source_file=str(diff_path if diff_path.is_file() else PATH_OPENCODE_DB),
                resume_command=self.make_opencode_resume_command(cwd, session_id),
                model_label=self.format_opencode_model(str(row["model"] or "")),
                description=title,
                prompts=prompts,
                children=[],
            )

        # Attach children recursively under their parents
        for row in tree_rows:
            parent_id = row["parent_id"]
            if not parent_id:
                continue
            parent_record = detail_map.get(parent_id)
            child_record = detail_map.get(row["id"])
            if parent_record is None or child_record is None:
                continue
            parent_record.children.append(child_record)

        # Sort child collections by recency and return the root
        for record in detail_map.values():
            record.children.sort(key=lambda child: child.end_ms or 0, reverse=True)
        root = detail_map.get(root_id)
        if root is None:
            raise KeyError(root_id)
        return root
