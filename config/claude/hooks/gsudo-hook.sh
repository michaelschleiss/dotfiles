#!/usr/bin/env bash
# PreToolUse hook to transform sudo commands to macOS GUI prompts
# Only active when ~/.cache/claude/sudo-gui-enabled exists

set -euo pipefail

FLAG_FILE="$HOME/.cache/claude/sudo-gui-enabled"

# Read hook input from stdin
input=$(cat)

# Helper: output JSON response in correct hookSpecificOutput format
respond() {
  local decision="$1"
  local reason="${2:-}"
  local updated_cmd="${3:-}"

  if [[ -n "$updated_cmd" ]]; then
    jq -n \
      --arg decision "$decision" \
      --arg reason "$reason" \
      --arg cmd "$updated_cmd" \
      '{
        hookSpecificOutput: {
          hookEventName: "PreToolUse",
          permissionDecision: $decision,
          permissionDecisionReason: $reason,
          updatedInput: { command: $cmd }
        }
      }'
  else
    jq -n \
      --arg decision "$decision" \
      '{
        hookSpecificOutput: {
          hookEventName: "PreToolUse",
          permissionDecision: $decision
        }
      }'
  fi
}

# Check if GUI sudo is enabled (default: disabled)
if [[ ! -f "$FLAG_FILE" ]]; then
  respond "allow"
  exit 0
fi

# Extract tool info safely
tool_name=$(echo "$input" | jq -r '.tool_name // ""')
command=$(echo "$input" | jq -r '.tool_input.command // ""')

# Only transform Bash tool with sudo commands
if [[ "$tool_name" == "Bash" ]] && [[ "$command" =~ (^|[[:space:]])sudo[[:space:]] ]]; then
  # Extract command after sudo (handle flags like -u, -i, etc.)
  sudo_cmd=$(echo "$command" | sed -E 's/^(.*[[:space:]])?sudo[[:space:]]+(-[^[:space:]]+[[:space:]]+)*//')

  # CRITICAL: Escape for osascript's do shell script
  # 1. Escape backslashes first (\ -> \\)
  # 2. Escape double quotes (" -> \")
  escaped_cmd="${sudo_cmd//\\/\\\\}"
  escaped_cmd="${escaped_cmd//\"/\\\"}"

  # Build the osascript command (use single quotes for outer shell)
  new_command="osascript -e 'do shell script \"${escaped_cmd}\" with administrator privileges'"

  respond "allow" "Transformed sudo to macOS GUI prompt" "$new_command"
else
  respond "allow"
fi
