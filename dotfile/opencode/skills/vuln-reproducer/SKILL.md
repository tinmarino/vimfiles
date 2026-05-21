---
name: vuln-reproducer
description: Reproduce and report pentest vulnerabilities from todo.md task lists. Use when the user asks to reproduce a vulnerability, automate a vuln report from notes, or process AI todo items that describe security findings to be reported to CyScope. Triggers on keywords like "reproduce", "report vuln", "Bice", "CyScope", or when processing items from todo.md under the "# AI" heading.
---

# vuln-reproducer

Automates the workflow of reproducing a vulnerability described in `todo.md` and writing a CyScope Markdown report using the `vuln-reporter` skill format.

## 1. Workflow

When triggered, execute these steps in order:

### Step 1: Parse the task

Read the vulnerability task from `todo.md` (under `# AI Report` or `# AI` heading). Extract:

- **ID**: e.g. `Bice185`
- **Severity**: ALTO, MEDI, BAJA, INFO, HYPO
- **Title/summary**: short description
- **Endpoints**: URLs, GraphQL operations, API paths
- **Steps**: any reproduction steps provided
- **Context**: linked `.md` files, Burp references

### Step 2: Gather context

1. Read `README.md` for credentials, scope, and account information.
2. Read any linked `.md` files mentioned in the task.
3. Check `Findings/` directory for similar past reports as format reference.
4. If Burp MCP is available, query it for recorded HTTP requests matching the endpoint.

### Step 3: Reproduce

Attempt to reproduce the vulnerability using `curl` or Python scripts:

1. Start with the simplest request (no auth, direct endpoint hit).
2. If auth is needed, use credentials from `README.md`.
3. Capture the full HTTP request and response.
4. Verify the vulnerability is confirmed (data leak, access granted, logic bypassed).
5. If reproduction fails, note what's missing and ask the user via `ai-pending.md`.

### Step 4: Write the report

Load the `vuln-reporter` skill and write the report in the CyScope format (11 sections + tables). Place it in `Findings/Vuln<ID>/report.md`.

### Step 5: Write exploitation tools

If the vulnerability enables enumeration or mass exploitation:

1. Write a Python PoC script in `Findings/Vuln<ID>/` following `python-writer` style.
2. The script should accept input (e.g., RUT file) and output results (JSON).
3. Include `--help`, proper error handling, and rate limiting.

### Step 6: Update tracking files

1. Mark the task as `[X]` in `doc/ai-todo.md`.
2. Move it to `doc/ai-done.md` with timestamp and solution suffix.
3. Commit with message: `Claude: <summary>`.

## 2. CVSS Quick Reference for Common Vuln Types

| Type | Typical Vector | Score |
| --- | --- | --- |
| Unauthenticated IDOR (read) | AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:N/A:N | 7.5 Alto |
| Authenticated IDOR (read+write) | AV:N/AC:L/PR:L/UI:N/S:C/C:L/I:H/A:H | 9.9 Critico |
| Info disclosure (no PII) | AV:N/AC:L/PR:N/UI:N/S:U/C:L/I:N/A:N | 5.3 Medio |
| Info disclosure (PII) | AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:N/A:N | 7.5 Alto |
| Consent/logic bypass | AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:L/A:N | 5.3 Medio |
| Auth bypass | AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:N | 9.1 Critico |

## 3. GraphQL Enumeration Techniques

When facing a GraphQL endpoint with introspection disabled:

1. **Typo suggestions**: Send a query with a close-but-wrong field name and parse "Did you mean" from the error.
2. **Field brute-force**: Try common prefixes (`get`, `create`, `update`, `delete`, `initialize`, `save`) with common suffixes.
3. **Type discovery**: Use `... on TypeName { __typename }` to discover union types.
4. **Input validation errors**: Send wrong types to input fields — errors reveal the expected type and available fields.

## 4. Credential Handling

- Read credentials from `README.md` in the project root.
- Never hardcode real tokens in reports — use `$TOKEN`, `$LEAD_ID`, `$USER_ID` placeholders in the report.
- In PoC scripts, read sensitive values from CLI arguments or environment variables.
- Auth headers in the report's `## Solicitud` section: show as `Authorization: Bearer ...` (truncated).

## 5. When Blocked

If reproduction requires data you don't have:

1. Write the question to `doc/ai-pending.md`.
2. Write a partial report with `TODO` markers for missing sections.
3. Move on to the next task.

Do NOT fabricate data or guess at responses you haven't actually received.
