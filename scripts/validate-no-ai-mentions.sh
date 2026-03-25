#!/bin/bash
# validate-no-ai-mentions.sh
# Hook script for HumanForge agent
# Blocks git commands that would push commits containing AI mentions
# Exit 0 = allow, Exit 2 = block

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

[ -z "$COMMAND" ] && exit 0

# Block git push if recent commits contain AI mentions
if echo "$COMMAND" | grep -iE '\bgit\s+push\b' > /dev/null; then
  # Check last 10 commits for AI mentions
  AI_MENTIONS=$(git log -10 --format='%s %b' 2>/dev/null | grep -iE 'co-authored-by.*(claude|copilot|gpt|bot|ai|assistant|anthropic|openai)|generated.by.*(ai|claude|gpt|copilot)|chatgpt|language.model' || true)
  if [ -n "$AI_MENTIONS" ]; then
    echo "Blocked: Recent commits contain AI mentions. Clean git history before pushing." >&2
    echo "Found: $AI_MENTIONS" >&2
    exit 2
  fi
fi

# Block git commit if the message contains AI mentions
if echo "$COMMAND" | grep -iE '\bgit\s+commit\b' > /dev/null; then
  if echo "$COMMAND" | grep -iE 'co-authored-by.*(claude|copilot|gpt|bot|ai|assistant|anthropic|openai)|generated.by.*(ai|claude|gpt|copilot)|chatgpt|language.model|as.an.ai' > /dev/null; then
    echo "Blocked: Commit message contains AI mentions. Remove AI references before committing." >&2
    exit 2
  fi
fi

exit 0
