# MCP Server Guide

[Model Context Protocol (MCP)](https://modelcontextprotocol.io) servers extend Claude Code with external tools — security scanners, database clients, web search, documentation fetchers, and more. Each agent declares which MCP servers it needs, and Claude Code scopes access accordingly.

## How MCPs Work with Agents

Agents declare MCP dependencies in their frontmatter:

```yaml
mcpServers:
  - cybersec
  - network-monitor
  - tavily
```

When the agent runs, it can only access tools from its declared MCP servers. CyberSentinel gets security tools, DataForge gets database tools, GrowthForge gets search tools. This scoping prevents agents from accessing tools outside their domain.

MCP servers must be installed and configured in Claude Code before agents can use them. Agents work without their MCPs (they fall back to built-in tools), but MCP access significantly increases their capabilities.

## Agent-to-MCP Mapping

| MCP Server | SEC | BPR | TST | SEO | DOC | OPS | DB | API |
|------------|-----|-----|-----|-----|-----|-----|----|----|
| context7 | x | x | x | x | x | x | x | x |
| github | x | x | x | x | x | x | x | x |
| tavily | x | | | x | x | | | |
| cybersec | x | | | | | | | |
| network-monitor | x | | | | | x | | |
| server-admin | x | | | | | x | | |
| local-admin | x | | | | | x | | |
| api-tester | x | | x | | | | | x |
| app-tester | | | x | | | | | |
| excalidraw | | | | | x | | | |

## Installing MCP Servers

### NPM-based MCPs (auto-installable)

These can be installed with a single command:

**context7** — Framework documentation lookup. Used by all agents to verify current best practices.

```bash
claude mcp add -s user context7 -- npx -y @upstash/context7-mcp@latest
```

**github** — Repository analysis, commit history, CI/CD workflows.

```bash
claude mcp add -s user github -- npx -y @modelcontextprotocol/server-github \
  --env GITHUB_PERSONAL_ACCESS_TOKEN=ghp_your_token_here
```

**tavily** — Web search for CVE lookups, documentation, and research.

```bash
claude mcp add -s user tavily -- npx -y tavily-mcp@latest \
  --env TAVILY_API_KEY=tvly-your_key_here
```

### HTTP-based MCPs

**excalidraw** — Diagram generation for architecture docs.

```bash
claude mcp add-json -s user excalidraw '{"type":"http","url":"https://mcp.excalidraw.com"}'
```

### Custom MCPs (require separate installation)

These MCP servers are custom-built and require their own setup. They are not required — agents work without them — but they provide powerful additional capabilities.

**cybersec** — Automated vulnerability scanning with 240+ security tools. Categories: OSINT, recon, web scanning, password auditing, network analysis, forensics, container security.

**server-admin** — SSH-based server management. Pull actual configs from remote servers, inspect Docker containers, check cron jobs, verify file permissions.

**local-admin** — Local machine management. File permissions, running processes, installed packages, network interfaces, hardware info.

**network-monitor** — Network diagnostics. Ping, port scanning, HTTP checks, SSL certificate validation, DNS lookups, traceroute, bandwidth testing.

**api-tester** — HTTP client and load tester. Send requests with custom headers, test rate limiting under load, save request collections.

**app-tester** — Application testing. Browser automation, UI testing, screenshot capture.

Each custom MCP is a separate project with its own installation instructions. The installer (`install.sh --mcps-only`) checks which MCPs are configured and reports missing ones.

## Managing MCP Servers

```bash
# List all configured MCP servers
claude mcp list

# Remove an MCP server
claude mcp remove context7

# Check MCP server status from within Claude Code
/agents-status
```

## MCP Configuration Locations

MCP servers can be configured at two scopes:

| Scope | File | Availability |
|-------|------|-------------|
| User | `~/.claude.json` | All projects for this user |
| Project | `.claude/mcp_servers.json` | Only this project |

The `-s user` flag in `claude mcp add` installs to user scope. Omit it for project scope.

## Creating Your Own MCP

If you build a tool that agents should use, you can expose it as an MCP server:

1. Use the [MCP SDK](https://github.com/modelcontextprotocol/typescript-sdk) (TypeScript) or [Python SDK](https://github.com/modelcontextprotocol/python-sdk)
2. Define your tools with clear names and descriptions
3. Publish to npm with the `mcp-server` keyword, or run locally
4. Add to Claude Code with `claude mcp add`
5. Reference in your agent's `mcpServers` list

## Discovering MCP Servers

- [modelcontextprotocol.io](https://modelcontextprotocol.io) — Official registry
- [GitHub: topic mcp-server](https://github.com/topics/mcp-server) — Community servers
- [Awesome MCP Servers](https://github.com/punkpeye/awesome-mcp-servers) — Curated list

## Troubleshooting

**Agent reports "MCP not available"** — The MCP server is listed in the agent's frontmatter but not configured in Claude Code. Run `claude mcp list` to see configured servers.

**MCP server fails to start** — Run `claude mcp list` and check for error indicators. Try `claude mcp remove <name>` and re-add it.

**Tools not appearing** — Restart Claude Code after adding or modifying MCP servers. Some MCP servers require environment variables (API keys) that may not be set.
