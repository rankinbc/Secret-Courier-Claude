# secret-courier

A Claude Code plugin that moves secrets around **by name**, so the model never sees a value and nothing is
left lying around.

Claude is good at wiring up an API client, a deploy script or a local config. It should never have to see the
token that makes it work. With this plugin the token goes from your keyboard into an encrypted store once, and
from there, by name only, to wherever a job needs it: a child process, a git-ignored `.env`, an HTTPS probe.
Hooks keep Claude's own tools away from secret files and value-printing commands, and a ledger remembers every
plaintext copy so you can sweep them when the job is done.

- The developer types a value once, at a masked prompt in a console the plugin opens. It lands in a DPAPI
  encrypted store or Windows Credential Manager.
- Claude asks for it by name: into a child process environment (`courier run`), into a git-ignored local
  config (`courier inject`), or to check that a token still works (`courier test`).
- Every plaintext copy the plugin writes is recorded; `courier sweep` removes them.
- Hooks stop Claude's own tools from reading secret files, dumping environments, or running commands that
  would print a value. They fail closed.

## Requirements

Windows 10/11, PowerShell 7 (`winget install Microsoft.PowerShell`), Python 3.11+ (`winget install
Python.Python.3.13`), Claude Code 2.1.295 or newer. No pip packages: the guard and the CLI are standard library
only.

## Install

```
claude plugin marketplace add <this repository URL>
claude plugin install secret-courier@secret-courier
```

Restart Claude Code. Then, in a session: `/courier doctor`.

## Use

In a session Claude follows the `secret-courier` skill; you can also drive it yourself:

```
/courier exists github-pat                        which store holds it (dpapi, credman, env)
/courier prompt github-pat --description "GitHub PAT for releases"
                                                  a console opens; type or paste the value there
/courier run --env GITHUB_TOKEN=dpapi:github-pat -- gh release list
                                                  the value exists only in that child process
/courier inject --target .env --format dotenv --map GITHUB_TOKEN=dpapi:github-pat
                                                  a git-ignored, owner-only, ledgered copy
/courier test github-pat github                   valid 200 / invalid 401 (endpoints in config/endpoints.json)
/courier copy dpapi:github-pat credman:github-pat
/courier sinks                                    every plaintext copy still on disk
/courier sweep --dry-run                          what a sweep would remove
/courier sweep                                    remove them
/courier names                                    every name the store knows, and where
/courier log                                      what the plugin did and when (names only)
/courier scan src                                 find secret-shaped values in files (never prints one)
```

Every command answers with a sentence about what happened to the value and where it is now, then a status
line. For example `exists` says "'github-pat' is held in Windows Credential Manager as
'secret-courier/github-pat', encrypted by the OS for the account you; its value was not read for this check",
and `inject` names the ledger id and the `sweep` command that removes the copy again. The console that `prompt`
opens explains where the value goes before you type it.

The same commands run from any shell: `"<plugin root>\scripts\courier.cmd" <command>`.

## How it works

```
developer ──masked prompt──▶ store (dpapi | credman) ──by name──▶ child process env   (run)
                                       │                        ▶ git-ignored local file (inject)  ──ledger──▶ sweep
                                       │                        ▶ HTTPS probe           (test)
Claude ◀── one STATUS line, redacted ──┘        (never a value)
```

| Part | What it does |
|---|---|
| `powershell/Courier.psm1` | the stores (DPAPI file, Credential Manager, env, Key Vault as a source), owner-only ACLs, the interactive guard, the audit log |
| `powershell/CourierSinks.psm1` | the sink ledger: writes `.env` / JSON / dotnet user-secrets, refuses files git does not ignore, sweeps |
| `powershell/ops/*.ps1` | one script per operation; prints `STATUS <status> <detail>`, never a value |
| `src/courier/bridge.py` | validates names, runs an op, redacts its output, turns a leak into an error |
| `src/courier/guard*.py` | the PreToolUse hooks: Bash/PowerShell, Read/Grep/Glob, Write/Edit, and the paste interceptor |
| `config/guard-policy.json` | the deny lists; `~/.secret-courier/guard-policy.json` may add to them and set `paste` |
| `config/endpoints.json` | the endpoints `courier test` may probe; `~/.secret-courier/config.json` adds yours |

Read `SECURITY.md` for the contract and the limits.

## Configuration

`~/.secret-courier/guard-policy.json` (optional):

```json
{ "denied_dirs": ["my-vault-dir"], "paste": "block" }
```

`~/.secret-courier/config.json` (optional):

```json
{ "endpoints": { "my-api": { "url": "https://api.example.com/me", "auth": "bearer", "expect": 200 } } }
```

`COURIER_HOME` moves the state directory; `COURIER_PYTHON` pins the interpreter the hooks use.

## Develop

```
python -m pip install -e ".[dev]"
python -m ruff check src tests scripts && python -m ruff format --check src tests scripts
python -m pytest -q
pwsh -NoProfile -Command "Invoke-Pester -Path powershell/tests"
courier doctor                  (pip install puts `courier` on PATH; or scripts\courier.cmd doctor)
```

CI runs the same on `windows-latest` for Python 3.11 and 3.13, plus a self-scan of the repo for
secret-shaped values. See `CONTRIBUTING.md` for the rules that keep the plugin trustworthy and `CHANGELOG.md`
for what changed.

## Status

0.1.0, Windows only. macOS and Linux need a keychain or libsecret backend and a shell wrapper for the hooks;
the layout leaves room for both.

MIT license.
