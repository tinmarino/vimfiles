import type { Plugin } from "@opencode-ai/plugin"
import { appendFileSync, mkdirSync } from "fs"
import { homedir } from "os"
import { join } from "path"

// Return: ~/Log
function logDir(): string {
  return join(homedir(), "Log")
}

// Return: ~/Log/opencode-command-YYYY-MM-DD.log
function logPath(): string {
  const date = new Date().toISOString().slice(0, 10)
  return join(logDir(), `opencode-command-${date}.log`)
}

// Return: YYYY-MM-DDTHH:MM:SS
function timestamp(): string {
  return new Date().toISOString().replace(/\.\d{3}Z$/, "")
}

// Return: void — appends a timestamped entry to the daily log file
function log(data: string): void {
  const dir = logDir()
  mkdirSync(dir, { recursive: true })

  const header = `###### Command ${timestamp()}\n`
  const entry = `${header}${data}\n\n`

  appendFileSync(logPath(), entry, "utf-8")
}

export const CommandLogger: Plugin = async () => {
  const logged = new Set<string>()

  return {
    event: async ({ event }: { event: any }) => {
      if (event.type !== "message.part.updated") return

      const part = event.properties?.part
      if (part?.type !== "tool" || part?.tool !== "bash") return
      if (part?.state?.status !== "running") return

      const cmd = part.state?.input?.command
      if (!cmd) return

      // Deduplicate: same callID fires multiple running events
      const key = part.callID + ":" + cmd
      if (logged.has(key)) return
      logged.add(key)

      log(cmd)
    },
  }
}
