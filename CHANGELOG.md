# Changelog

All notable changes to secret-courier are recorded here. The format follows Keep a Changelog; versions follow
semantic versioning.

## Unreleased

- Every op now prints a plain sentence saying what happened to the value and where it is now (store,
  encryption, ACL, git-ignore, ledger id and the matching `sweep` command) before its status line.
- The `prompt` console explains where the value goes and what Claude sees before you type.
- `courier log` shows the audit log (names and statuses only).
- Refusals from the hooks name the `courier` command to use instead.

## 0.1.0 - 2026-10-20

First release. Windows only.

- Stores: `dpapi` (DPAPI-encrypted file under `~/.secret-courier`, owner-only ACL) and `credman` (Windows
  Credential Manager); `env` and `keyvault` as read-only sources.
- Operations, each printing one `STATUS` line and never a value: `exists`, `names`, `prompt` (masked console
  prompt), `copy`, `remove`, `test` (HTTPS probe through `HttpClient`), `inject` (git-ignored, ACL'd,
  ledgered local config), `run` (value only in a child process environment), `sinks`, `sweep`, `scan`, `doctor`.
- Guard hooks for Bash, PowerShell, Read, Grep, Glob, Write, Edit, NotebookEdit and the prompt: stdlib-only
  Python, no virtual environment, fail closed on every failure path.
- Policy file `config/guard-policy.json` with an add-only developer overlay; endpoint catalogue
  `config/endpoints.json` with a developer overlay.
- Skill `secret-courier` and command `/courier`.
