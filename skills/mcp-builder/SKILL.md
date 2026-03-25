---
name: mcp-builder
description: Guide for creating MCP servers that enable LLMs to interact with external services — used by DocMaster when documenting tool interfaces
---

# MCP Server Building Guide

## Architecture

MCP servers expose tools to LLMs via the Model Context Protocol. Each tool has:
- **Name**: snake_case, descriptive (e.g., `search_issues`, `run_query`)
- **Description**: What it does, when to use it, what it returns
- **Parameters**: JSON Schema with required/optional fields, descriptions, and examples
- **Return value**: Structured response the LLM can parse

## Python (FastMCP)

```python
from fastmcp import FastMCP

mcp = FastMCP("my-server")

@mcp.tool()
def search_users(query: str, limit: int = 10) -> list[dict]:
    """Search users by name or email.

    Args:
        query: Search term (name or email)
        limit: Maximum results (default 10, max 100)
    """
    # Implementation
    return results
```

## TypeScript (MCP SDK)

```typescript
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";

const server = new McpServer({ name: "my-server", version: "1.0.0" });

server.tool("search_users", { query: z.string(), limit: z.number().default(10) },
  async ({ query, limit }) => {
    // Implementation
    return { content: [{ type: "text", text: JSON.stringify(results) }] };
  }
);
```

## Tool Design Principles

1. **One tool = one action** — Don't make Swiss Army knife tools
2. **Descriptive names** — The LLM decides which tool to use based on the name and description
3. **Fail gracefully** — Return error messages, don't crash the server
4. **Idempotent where possible** — Same input = same result (for read operations)
5. **Document everything** — The description IS the API docs for the LLM

## Installation

```bash
# Python
claude mcp add -s user my-server -- python /path/to/server.py

# TypeScript (npx)
claude mcp add -s user my-server -- npx -y my-mcp-server@latest

# HTTP
claude mcp add-json -s user my-server '{"type":"http","url":"https://mcp.example.com"}'
```

## Testing

- Test each tool independently with sample inputs
- Test error cases (invalid input, network failures, timeouts)
- Test with Claude Code to verify the LLM can discover and use tools correctly
- Monitor response times — slow tools degrade the agent experience
