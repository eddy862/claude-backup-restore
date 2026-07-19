# claude-config

This repo is Eddy's personal backup/restore source for Claude Code's user-level
configuration (`~/.claude` and `~/.claude.json`). Its only purpose is to make
moving to a new device fast: clone the repo, run one script, get the same
plugins, MCP servers, and custom skills/agents/commands back.

This is a **private, personal infra repo**, not an application. There is no
build, no tests, and no runtime beyond the two PowerShell scripts.

## Layout

```
claude/
  settings.json              -> ~/.claude/settings.json (enabledPlugins, theme, autoUpdatesChannel)
  mcp-servers.json            -> merged into the "mcpServers" key of ~/.claude.json
  skills/                     -> ~/.claude/skills (custom user-level skills; empty for now)
  agents/                     -> ~/.claude/agents (custom user-level subagents; empty for now)
  commands/                   -> ~/.claude/commands (custom slash commands; empty for now)
scripts/
  install.ps1                 restores repo -> ~/.claude on a (new) machine
  backup.ps1                  pulls current ~/.claude -> repo, before committing
  sync-mcp-servers.js         shared Node helper the two scripts above call for the ~/.claude.json merge step
```

`claude/` mirrors the parts of `~/.claude` worth version-controlling. Anything
not listed above (`.credentials.json`, `history.jsonl`, `cache/`, `projects/`,
`sessions/`, plugin install caches, `plugins/known_marketplaces.json`, etc.)
is machine/account state and is intentionally not tracked here.

`plugins/known_marketplaces.json` is deliberately excluded even though it's a
config file, not a cache: Claude Code writes an `installLocation` and
`lastUpdated` into each entry only after it actually clones that marketplace.
A version of this file captured/restored without those fields reads as
corrupted to Claude Code (`/plugin` throws "Marketplace configuration file is
corrupted"). Re-adding a marketplace with `/plugin marketplace add <repo>`
after install regenerates a valid entry, so it's not worth tracking.

## Workflow

- **New device**: clone the repo, run `scripts/install.ps1`, start `claude`
  once, run `/plugin marketplace add <repo>` for each marketplace you use
  (e.g. `anthropics/claude-plugins-official`) so it fetches the enabled
  plugins, then log back into the claude.ai connectors (ArkWiki, Atlassian,
  Linear, etc.) — those are OAuth/account-linked, not files, so this repo
  can't restore them.
- **After changing config on a machine** (enabling a plugin, adding an MCP
  server, adding a custom skill/agent/command): run `scripts/backup.ps1`,
  review the diff, then commit and push.
- Both scripts are safe to re-run repeatedly; `install.ps1` backs up any file
  it's about to overwrite with a `.bak-<timestamp>` suffix first.

## Hard rules

- **Never commit `.credentials.json` or any OAuth token/secret.** The
  `.gitignore` blocks the obvious filenames, but if you're ever asked to add
  a new file into `claude/`, check its contents for tokens/keys first.
- **Only touch the `mcpServers` key when editing `~/.claude.json`.** That file
  is Claude Code's own state store (history, usage stats, per-project
  settings, machine ID, etc.) — everything else in it is machine-specific or
  generated and must not be synced or overwritten wholesale. This is why the
  merge goes through `sync-mcp-servers.js` (Node's `JSON.parse`) instead of
  `ConvertFrom-Json`/`ConvertTo-Json` in PowerShell — that file has been
  observed to contain duplicate keys (differently-cased project paths on
  Windows) that make `ConvertFrom-Json` throw.
- **Claude.ai connectors are out of scope.** Anything listed under "MCP
  Server Instructions" as a `claude.ai <Name>` connector (ArkWiki, Asana,
  Atlassian, Box, Canva, Figma, HubSpot, Intercom, Linear, Notion,
  monday.com) is tied to the logged-in claude.ai account via OAuth, not to a
  local config file. Don't try to persist these here; just note in the repo
  if a new one becomes important enough to remember to reconnect.
- **Windows-only for now.** The scripts are PowerShell and assume
  `$env:USERPROFILE`. If a Mac/Linux machine ever enters the picture, this
  needs a POSIX equivalent (`~/.claude` path differs, but the JSON contents
  don't) — don't assume it silently works cross-platform.

## Adding a custom skill/agent/command

Drop it under `claude/skills/<name>/`, `claude/agents/<name>.md`, or
`claude/commands/<name>.md` (matching Claude Code's own on-disk format for
each), then run `scripts/backup.ps1` to confirm nothing else changed
unexpectedly, and commit.
