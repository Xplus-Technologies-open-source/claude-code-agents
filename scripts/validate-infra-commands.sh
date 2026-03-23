#!/bin/bash
# validate-infra-commands.sh
# Hook script for InfraForge agent
# Blocks high-risk infrastructure commands that could cause outages
# Exit 0 = allow, Exit 2 = block

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

[ -z "$COMMAND" ] && exit 0

if echo "$COMMAND" | grep -iE '(docker\s+system\s+prune|docker\s+rm\s+-f|docker\s+stop\s+\$|kubectl\s+delete\s+(namespace|ns|cluster)|terraform\s+destroy|helm\s+uninstall|rm\s+-rf\s+/(etc|var|opt|srv)|systemctl\s+(stop|disable)\s+(docker|nginx|postgresql|mysql)|iptables\s+-F|ufw\s+disable)' > /dev/null; then
  echo "Blocked: High-risk infrastructure command detected. Review the command and confirm with the user before executing." >&2
  exit 2
fi

exit 0
