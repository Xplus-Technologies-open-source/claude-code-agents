#!/bin/bash
# validate-no-destructive.sh
# Hook script for CyberSentinel agent
# Blocks destructive shell commands during security audits
# Exit 0 = allow, Exit 2 = block

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

[ -z "$COMMAND" ] && exit 0

if echo "$COMMAND" | grep -iE '\b(rm\s+-rf\s+/|mkfs\.|dd\s+if=|format\s+[a-z]:|shutdown|reboot|init\s+[0-6]|kill\s+-9\s+-1|:(){ :|systemctl\s+(stop|disable)\s+(sshd|network|firewall))\b' > /dev/null; then
  echo "Blocked: Destructive commands are not permitted during security audits. Report the finding instead." >&2
  exit 2
fi

exit 0
