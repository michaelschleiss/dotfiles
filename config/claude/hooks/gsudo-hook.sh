#!/usr/bin/env bash
# PreToolUse hook to transform sudo commands to GUI prompts
# macOS: osascript dialog, Linux: zenity via SUDO_ASKPASS
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
# Match sudo only as a command (start of line or after shell operators), not within strings
if [[ "$tool_name" == "Bash" ]] && [[ "$command" =~ (^|[[:space:]\&\|\;])sudo[[:space:]] ]]; then
  # Verify it's not inside quotes (simple heuristic: odd number of quotes before "sudo")
  before_sudo="${command%%sudo*}"
  single_quotes="${before_sudo//[^\']/}"
  double_quotes="${before_sudo//[^\"]/}"

  # If inside quotes, don't transform
  if (( ${#single_quotes} % 2 == 1 )) || (( ${#double_quotes} % 2 == 1 )); then
    respond "allow"
    exit 0
  fi

  if [[ "$(uname -s)" == "Darwin" ]]; then
    # macOS: use osascript GUI dialog
    sudo_cmd=$(echo "$command" | sed -E 's/^(.*[[:space:]&|;])?sudo[[:space:]]+(-[^[:space:]]+[[:space:]]+)*//')
    escaped_cmd="${sudo_cmd//\\/\\\\}"
    escaped_cmd="${escaped_cmd//\"/\\\"}"
    new_command="osascript -e 'do shell script \"${escaped_cmd}\" with administrator privileges'"
    respond "allow" "Transformed sudo to macOS GUI prompt" "$new_command"
  else
    # Linux: use SUDO_ASKPASS with zenity
    new_command="SUDO_ASKPASS=\"\${XDG_CONFIG_HOME:-\$HOME/.config}/claude/hooks/askpass-zenity.sh\" ${command//sudo/sudo -A}"
    respond "allow" "Transformed sudo to zenity GUI prompt" "$new_command"
  fi
else
  respond "allow"
fi
