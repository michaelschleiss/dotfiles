#!/usr/bin/env bash
# PreToolUse hook to transform sudo commands to macOS GUI prompts
# Only active when ~/.cache/claude/sudo-gui-enabled exists

set -euo pipefail

FLAG_FILE="$HOME/.cache/claude/sudo-gui-enabled"

# Read hook input from stdin
input=$(cat)

# Check if GUI sudo is enabled (default: disabled)
if [[ ! -f "$FLAG_FILE" ]]; then
  # Disabled - pass through unchanged
  echo '{"permissionDecision": "allow"}'
  exit 0
fi

# Extract tool info
tool_name=$(echo "$input" | jq -r '.tool_name')
command=$(echo "$input" | jq -r '.tool_input.command // ""')

# Only transform Bash tool with sudo commands
if [[ "$tool_name" == "Bash" ]] && [[ "$command" =~ (^|[[:space:]])sudo[[:space:]] ]]; then
  # Extract the command after sudo (handle various sudo forms)
  sudo_cmd=$(echo "$command" | sed -E 's/^(.*[[:space:]])?sudo[[:space:]]+(-[^[:space:]]+[[:space:]]+)*//')

  # Transform to osascript with GUI prompt
  new_command="osascript -e \"do shell script \\\"$sudo_cmd\\\" with administrator privileges\""

  # Return modified input with system message
  jq -n \
    --arg cmd "$new_command" \
    '{
      permissionDecision: "allow",
      updatedInput: { command: $cmd },
      systemMessage: "Transformed sudo to macOS GUI prompt"
    }'
else
  # Not a sudo command - pass through unchanged
  echo '{"permissionDecision": "allow"}'
fi
