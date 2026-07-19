# claude-config

Backup/restore for my personal Claude Code user config (plugins, MCP servers,
and any custom skills/agents/commands), so switching to a new machine takes
one script instead of re-clicking through setup.

See [CLAUDE.md](./CLAUDE.md) for what's tracked here and why.

## Structure

```
claude/
  settings.json                    -> ~/.claude/settings.json (enabledPlugins, theme, autoUpdatesChannel)
  plugins/known_marketplaces.json  -> ~/.claude/plugins/known_marketplaces.json
  mcp-servers.json                 -> merged into the "mcpServers" key of ~/.claude.json
  skills/<name>/SKILL.md           -> ~/.claude/skills/<name>/SKILL.md (custom user-level skills)
  agents/                          -> ~/.claude/agents (custom user-level subagents; empty for now)
  commands/                        -> ~/.claude/commands (custom slash commands; empty for now)
scripts/
  install.ps1              restores repo -> ~/.claude on a (new) machine
  backup.ps1               pulls current ~/.claude -> repo, before committing
  sync-mcp-servers.js      shared Node helper for the ~/.claude.json merge step
CLAUDE.md                  instructions for Claude Code when working in this repo
README.md                 this file
```

Anything not listed above (`.credentials.json`, `history.jsonl`, `cache/`,
`projects/`, `sessions/`, plugin install caches, etc.) is machine/account
state and is intentionally not tracked here.

## Restore on a new device

1. Install the Claude Code CLI (skip if already installed):

   ```powershell
   irm https://claude.ai/install.ps1 | iex
   ```

2. Clone this repo and run the restore script:

   ```powershell
   git clone https://github.com/eddy862/claude-backup-restore.git
   cd claude-backup-restore
   powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1
   ```

   Windows blocks unsigned local scripts by default (`running scripts is
   disabled on this system`), so `-ExecutionPolicy Bypass` is needed to run
   `install.ps1`/`backup.ps1` — it only affects that one invocation, no
   system setting is changed. If you'd rather not type it every time, run
   `Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned`
   once instead, then call the scripts directly (`.\scripts\install.ps1`).

   The script prints each item as it restores it, e.g.:

   ```
   [1/4] settings.json
     plugin 'github@claude-plugins-official' enabled
     ...
   [3/4] custom skills / agents / commands
     skill 'learn-by-building' installed
   [4/4] MCP servers (merging into ~/.claude.json)
     mcp server 'Jam' installed
   ```

Then start `claude` once (so it installs the enabled plugins) and log back
into any claude.ai connectors you use — those are account-linked, not
restored by this repo.

## Save changes from this device

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\backup.ps1
git diff        # review before committing
git add -A
git commit -m "..."
git push
```
