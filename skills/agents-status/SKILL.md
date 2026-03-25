---
name: agents-status
description: Show the status of all installed agents, their MCP connections, preloaded skills, and memory state
disable-model-invocation: true
---

Display the status of all installed custom agents.

## For Each Agent, Report:

1. **Name and color** — Agent identifier
2. **Installed** — Does the .md file exist in ~/.claude/agents/ or .claude/agents/?
3. **MCPs connected** — For each MCP in the agent's mcpServers list, check if it appears in `claude mcp list` output
4. **Skills available** — For each skill in the agent's skills list, check if it exists in ~/.claude/skills/ or .claude/skills/
5. **Memory state** — Does ~/.claude/agent-memory/{name}/ exist? If so, how many files and what's the last modified date?
6. **Hook scripts** — If the agent defines hooks, check if the script files exist and are executable

## Expected Agents

| Agent | Color | Slash Command |
|-------|-------|---------------|
| cybersentinel | red | /sec |
| codecraft | blue | /bpr |
| testforge | yellow | /tst |
| growthforge | green | /seo |
| docmaster | purple | /doc |
| infraforge | cyan | /ops |
| dataforge | orange | /db |
| apiforge | white | /api |
| humanforge | magenta | /hmn |

## Output Format

Use a clean table format. Mark each item with a status indicator:
- Connected/Available/Exists
- Missing/Disconnected/Not Found

At the end, show a summary: X/9 agents installed, Y MCPs connected, Z skills available.
