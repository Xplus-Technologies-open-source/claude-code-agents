# Hooks Guide

Hook scripts validate agent commands before execution. They act as safety guardrails — blocking destructive operations, enforcing read-only constraints, or requiring confirmation for high-risk commands.

## How Hooks Work

Hooks are configured in an agent's YAML frontmatter:

```yaml
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/validate-no-destructive.sh"
```

When the agent attempts to use a matched tool (in this case, `Bash`), Claude Code pipes the tool call as JSON to the hook script's stdin. The script inspects the payload and decides:

| Exit Code | Meaning |
|-----------|---------|
| `0` | Allow the tool call to proceed |
| `2` | Block the tool call. The message printed to stderr is shown to the agent. |

Any other exit code is treated as a hook error and the tool call is allowed by default.

## Input Format

The hook receives JSON on stdin with the tool call details:

```json
{
  "tool_name": "Bash",
  "tool_input": {
    "command": "rm -rf /tmp/data",
    "description": "Clean up temp files"
  },
  "session_id": "abc-123"
}
```

For other tools, `tool_input` contains tool-specific fields. The `Edit` tool provides `file_path`, `old_string`, and `new_string`. The `Write` tool provides `file_path` and `content`.

## Included Hook Scripts

### validate-no-destructive.sh

**Used by:** CyberSentinel (SEC)

Blocks destructive shell commands during security audits. CyberSentinel runs in `permissionMode: plan` (read-only) and should never execute commands that modify the system.

**Blocked patterns:** `rm -rf /`, `mkfs`, `dd if=`, `format`, `shutdown`, `reboot`, `kill -9 -1`, fork bombs, stopping critical services (sshd, network, firewall).

### validate-readonly-query.sh

**Used by:** DataForge (DB)

Enforces read-only database access. DataForge analyzes schemas and queries but must never execute write operations directly.

**Blocked patterns:** `INSERT`, `UPDATE`, `DELETE`, `DROP`, `CREATE`, `ALTER`, `TRUNCATE`, `REPLACE`, `MERGE`, `GRANT`, `REVOKE`, `EXEC`, `EXECUTE`.

### validate-infra-commands.sh

**Used by:** InfraForge (OPS)

Blocks high-risk infrastructure commands that could cause service outages.

**Blocked patterns:** `docker system prune`, `docker rm -f`, `kubectl delete namespace`, `terraform destroy`, `helm uninstall`, `rm -rf /etc|/var|/opt|/srv`, stopping Docker/nginx/database services, flushing iptables, disabling ufw.

## Defining Hooks in Agent Frontmatter

```yaml
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/validate-no-destructive.sh"
```

The `matcher` field determines which tool triggers the hook. Common matchers:

| Matcher | Triggers On |
|---------|-------------|
| `Bash` | Shell command execution |
| `Edit` | File editing operations |
| `Write` | File creation/overwrite operations |
| `Read` | File reading operations |

You can also match MCP tool names using the `mcp__<server>__<tool>` pattern.

## Supported Hook Events

| Event | When | Common Use |
|-------|------|------------|
| `PreToolUse` | Before a tool executes | Block dangerous commands, validate inputs |
| `PostToolUse` | After a tool executes | Log operations, validate outputs |
| `Stop` | When the agent finishes | Generate summaries, clean up resources |

## Writing Custom Hooks

### Basic Template

```bash
#!/bin/bash
# my-custom-hook.sh
# Exit 0 = allow, Exit 2 = block

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Allow if no command found
[ -z "$COMMAND" ] && exit 0

# Block matching patterns
if echo "$COMMAND" | grep -iE 'your_dangerous_pattern' > /dev/null; then
  echo "Blocked: Reason for blocking this command." >&2
  exit 2
fi

# Allow everything else
exit 0
```

### Example: Block File Writes Outside Project

```bash
#!/bin/bash
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

[ -z "$FILE_PATH" ] && exit 0

PROJECT_DIR="/home/user/my-project"
if [[ "$FILE_PATH" != "$PROJECT_DIR"* ]]; then
  echo "Blocked: Cannot write files outside the project directory." >&2
  exit 2
fi

exit 0
```

### Installation

1. Place the script in `scripts/` in the repository
2. Make it executable: `chmod +x scripts/my-hook.sh`
3. Reference it in the agent's frontmatter with a relative path (`./scripts/my-hook.sh`)
4. The installer rewrites relative paths to absolute paths during installation

For manual installation, use an absolute path directly in the agent frontmatter.

## Requirements

- **jq** — Required for JSON parsing in all included hook scripts
  - Debian/Ubuntu: `sudo apt install jq`
  - macOS: `brew install jq`
  - Fedora/RHEL: `sudo dnf install jq`
- **bash** — Hook scripts use bash. On Windows, WSL or Git Bash is required.

The Windows installer (`install.ps1`) skips hook installation since bash scripts are not natively supported.
