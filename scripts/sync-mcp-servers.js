// Merges the mcpServers block between this repo and ~/.claude.json.
// ~/.claude.json is Claude Code's own state file (history, cache, etc.) --
// we only ever touch the "mcpServers" key on it, never anything else.
// Plain PowerShell ConvertFrom-Json/ConvertTo-Json chokes on duplicate keys
// that Claude Code itself sometimes writes into that file (e.g. differently
//-cased project paths), so this merge step goes through Node's tolerant
// JSON.parse instead.

const fs = require("fs");

const mode = process.argv[2]; // "import" (repo -> claude.json) or "export" (claude.json -> repo)
const claudeJsonPath = process.argv[3];
const repoMcpPath = process.argv[4];

if (!mode || !claudeJsonPath || !repoMcpPath) {
  console.error("Usage: node sync-mcp-servers.js <import|export> <claude.json path> <repo mcp-servers.json path>");
  process.exit(1);
}

function readJson(path, fallback) {
  if (!fs.existsSync(path)) return fallback;
  return JSON.parse(fs.readFileSync(path, "utf8"));
}

if (mode === "import") {
  const claudeJson = readJson(claudeJsonPath, {});
  const repoMcp = readJson(repoMcpPath, {});
  claudeJson.mcpServers = { ...(claudeJson.mcpServers || {}), ...repoMcp };
  fs.writeFileSync(claudeJsonPath, JSON.stringify(claudeJson, null, 2));
  const names = Object.keys(repoMcp);
  if (names.length === 0) console.log("  no MCP servers in repo yet");
  names.forEach((n) => console.log(`  mcp server '${n}' installed`));
} else if (mode === "export") {
  const claudeJson = readJson(claudeJsonPath, {});
  const mcpServers = claudeJson.mcpServers || {};
  fs.writeFileSync(repoMcpPath, JSON.stringify(mcpServers, null, 2) + "\n");
  const names = Object.keys(mcpServers);
  if (names.length === 0) console.log("  no MCP servers on this machine");
  names.forEach((n) => console.log(`  mcp server '${n}' backed up`));
} else {
  console.error(`Unknown mode "${mode}", expected "import" or "export"`);
  process.exit(1);
}
