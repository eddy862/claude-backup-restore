<#
.SYNOPSIS
  Pulls the current machine's ~/.claude config back into this repo.

.DESCRIPTION
  Run this before committing, whenever you've changed settings, enabled/
  disabled a plugin, added an MCP server, or added a custom skill/agent/
  command. It copies the relevant files from ~/.claude into the repo's
  claude/ folder -- it does NOT commit or push anything, so review
  `git diff` / `git status` yourself afterwards before committing.

  Never copies .credentials.json or any other secrets -- only the specific
  files listed below.
#>

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$repoClaudeDir = Join-Path $repoRoot "claude"
$claudeDir = Join-Path $env:USERPROFILE ".claude"
$claudeJsonPath = Join-Path $env:USERPROFILE ".claude.json"

Write-Host "Pulling Claude Code config from $claudeDir into the repo ..."

Write-Host "`n[1/3] settings.json"
$settingsDest = Join-Path $repoClaudeDir "settings.json"
Copy-Item (Join-Path $claudeDir "settings.json") $settingsDest -Force
$settings = Get-Content $settingsDest -Raw | ConvertFrom-Json
foreach ($plugin in $settings.enabledPlugins.PSObject.Properties) {
    if ($plugin.Value) {
        Write-Host "  plugin '$($plugin.Name)' backed up"
    }
}

Write-Host "`n[2/3] custom skills / agents / commands"
foreach ($kind in @("skills", "agents", "commands")) {
    $src = Join-Path $claudeDir $kind
    $dest = Join-Path $repoClaudeDir $kind
    if (Test-Path $src) {
        $items = Get-ChildItem $src -Force
        if ($items) {
            New-Item -ItemType Directory -Force -Path $dest | Out-Null
            $label = $kind.Substring(0, $kind.Length - 1)
            foreach ($item in $items) {
                Copy-Item $item.FullName $dest -Recurse -Force
                $name = [System.IO.Path]::GetFileNameWithoutExtension($item.Name)
                Write-Host "  $label '$name' backed up"
            }
        } else {
            Write-Host "  no $kind on this machine"
        }
    } else {
        Write-Host "  no $kind on this machine"
    }
}

Write-Host "`n[3/3] MCP servers (exporting from ~/.claude.json)"
$mergeScript = Join-Path $PSScriptRoot "sync-mcp-servers.js"
$repoMcpPath = Join-Path $repoClaudeDir "mcp-servers.json"
$node = Get-Command node -ErrorAction SilentlyContinue
if ($node) {
    node $mergeScript export $claudeJsonPath $repoMcpPath
} else {
    Write-Warning "Node.js not found -- couldn't export mcpServers automatically."
    Write-Warning "Manually copy the `"mcpServers`" key from $claudeJsonPath into $repoMcpPath"
}

Write-Host "`nDone. Now review the changes before committing:"
Write-Host "  git -C `"$repoRoot`" status"
Write-Host "  git -C `"$repoRoot`" diff"
