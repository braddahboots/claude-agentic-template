#!/bin/bash
# PreToolUse hook: Block dangerous commands
# Exit 0 = allow, Exit 2 = block

# Read tool input from stdin
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)

if [ -z "$COMMAND" ]; then
  exit 0
fi

# Universal dangerous patterns
DANGEROUS_PATTERNS=(
  "rm -rf /"
  "rm -rf \."
  "rm -rf \*"
  "git push --force"
  "git push -f"
  "git reset --hard"
  "git clean -fd"
  "git checkout \."
  "DROP TABLE"
  "DROP DATABASE"
  "TRUNCATE TABLE"
  ":(){ :|:& };:"
  "> /dev/sda"
  "mkfs\."
  "dd if="
)

for pattern in "${DANGEROUS_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qiE "$pattern"; then
    echo "{\"decision\": \"block\", \"reason\": \"BLOCKED: Dangerous command detected matching pattern '$pattern'. If you need to run this, get explicit user approval first.\"}" >&2
    exit 2
  fi
done

# ============================================
# PROJECT-SPECIFIC PATTERNS (added by bootstrap)
# Add domain-specific dangerous commands below:
# ============================================

exit 0
