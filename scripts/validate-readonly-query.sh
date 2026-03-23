#!/bin/bash
# validate-readonly-query.sh
# Hook script for DataForge agent
# Blocks SQL write operations — only SELECT queries are allowed
# Exit 0 = allow, Exit 2 = block

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

[ -z "$COMMAND" ] && exit 0

if echo "$COMMAND" | grep -iE '\b(INSERT|UPDATE|DELETE|DROP|CREATE|ALTER|TRUNCATE|REPLACE|MERGE|GRANT|REVOKE|EXEC|EXECUTE)\b' > /dev/null; then
  echo "Blocked: Write operations are not allowed. DataForge operates in read-only mode. Report your recommendations instead." >&2
  exit 2
fi

exit 0
