<#
.SYNOPSIS
  Restores this repo's Claude Code config into ~/.claude on the current machine.

.DESCRIPTION
  Copies settings.json, the plugin marketplace list, and any custom
  skills/agents/commands from this repo into ~/.claude, then merges the
  repo's mcpServers block into ~/.claude.json (without touching anything
  else in that file). Existing files are backed up with a timestamp suffix
  before being overwritten.

  Safe to re-run any time to pull down repo changes onto a machine you
  already set up.
#>

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$repoClaudeDir = Join-Path $repoRoot "claude"
$claudeDir = Join-Path $env:USERPROFILE ".claude"
$claudeJsonPath = Join-Path $env:USERPROFILE ".claude.json"
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

function Backup-IfExists($path) {
    if (Test-Path $path) {
        $backupPath = "$path.bak-$timestamp"
        Copy-Item $path $backupPath -Force
        Write-Host "  Backed up existing file to $backupPath"
    }
}

Write-Host "Restoring Claude Code config into $claudeDir ..."
New-Item -ItemType Directory -Force -Path $claudeDir | Out-Null

Write-Host "`n[1/4] settings.json"
$settingsDest = Join-Path $claudeDir "settings.json"
Backup-IfExists $settingsDest
Copy-Item (Join-Path $repoClaudeDir "settings.json") $settingsDest -Force
$settings = Get-Content $settingsDest -Raw | ConvertFrom-Json
foreach ($plugin in $settings.enabledPlugins.PSObject.Properties) {
    if ($plugin.Value) {
        Write-Host "  plugin '$($plugin.Name)' enabled"
    }
}

Write-Host "`n[2/4] plugin marketplaces"
$pluginsDir = Join-Path $claudeDir "plugins"
New-Item -ItemType Directory -Force -Path $pluginsDir | Out-Null
$marketplacesDest = Join-Path $pluginsDir "known_marketplaces.json"
Backup-IfExists $marketplacesDest
Copy-Item (Join-Path $repoClaudeDir "plugins\known_marketplaces.json") $marketplacesDest -Force
$marketplaces = Get-Content $marketplacesDest -Raw | ConvertFrom-Json
foreach ($marketplace in $marketplaces.PSObject.Properties) {
    Write-Host "  marketplace '$($marketplace.Name)' registered"
}

Write-Host "`n[3/4] custom skills / agents / commands"
foreach ($kind in @("skills", "agents", "commands")) {
    $src = Join-Path $repoClaudeDir $kind
    $dest = Join-Path $claudeDir $kind
    $items = Get-ChildItem $src -Force | Where-Object { $_.Name -ne ".gitkeep" }
    if ($items) {
        New-Item -ItemType Directory -Force -Path $dest | Out-Null
        $label = $kind.Substring(0, $kind.Length - 1)
        foreach ($item in $items) {
            Copy-Item $item.FullName $dest -Recurse -Force
            $name = [System.IO.Path]::GetFileNameWithoutExtension($item.Name)
            Write-Host "  $label '$name' installed"
        }
    } else {
        Write-Host "  no $kind in repo yet"
    }
}

Write-Host "`n[4/4] MCP servers (merging into ~/.claude.json)"
Backup-IfExists $claudeJsonPath
$mergeScript = Join-Path $PSScriptRoot "sync-mcp-servers.js"
$repoMcpPath = Join-Path $repoClaudeDir "mcp-servers.json"
$node = Get-Command node -ErrorAction SilentlyContinue
if ($node) {
    node $mergeScript import $claudeJsonPath $repoMcpPath
} else {
    Write-Warning "Node.js not found -- couldn't merge mcpServers automatically."
    Write-Warning "Manually merge the contents of $repoMcpPath into the `"mcpServers`" key of $claudeJsonPath"
}

Write-Host "`nDone. Next steps:"
Write-Host "  - Start 'claude' once so it can fetch/install the enabled plugins from their marketplace."
Write-Host "  - Log back into any claude.ai connectors (ArkWiki, Atlassian, Linear, etc.) -- those are account-linked, not file-based, so they aren't restored by this script."
