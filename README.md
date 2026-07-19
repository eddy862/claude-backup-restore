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
  skills/                          -> ~/.claude/skills (custom user-level skills; empty for now)
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
   git clone <this-repo-url>
   cd claude-config
   .\scripts\install.ps1
   ```

Then start `claude` once (so it installs the enabled plugins) and log back
into any claude.ai connectors you use — those are account-linked, not
restored by this repo.

## Save changes from this device

```powershell
.\scripts\backup.ps1
git diff        # review before committing
git add -A
git commit -m "..."
git push
```
