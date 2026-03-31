#!/usr/bin/env bash
# RTK Claude Code hook — rewrites supported shell commands to use rtk.
# This stays thin on purpose so rewrite logic remains in the rtk binary.

if ! command -v jq >/dev/null 2>&1; then
  echo "[rtk] WARNING: jq is not installed. Hook cannot rewrite commands." >&2
  exit 0
fi

if ! command -v rtk >/dev/null 2>&1; then
  echo "[rtk] WARNING: rtk is not installed or not in PATH. Hook cannot rewrite commands." >&2
  exit 0
fi

# rtk rewrite was added in 0.23.0.
rtk_version="$(rtk --version 2>/dev/null | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+' | head -n 1)"
if [[ -n "${rtk_version}" ]]; then
  major="$(echo "${rtk_version}" | cut -d. -f1)"
  minor="$(echo "${rtk_version}" | cut -d. -f2)"
  if [[ "${major}" -eq 0 && "${minor}" -lt 23 ]]; then
    echo "[rtk] WARNING: rtk ${rtk_version} is too old (need >= 0.23.0)." >&2
    exit 0
  fi
fi

input="$(cat)"
command="$(echo "${input}" | jq -r '.tool_input.command // empty')"

if [[ -z "${command}" ]]; then
  exit 0
fi

rewritten="$(rtk rewrite "${command}" 2>/dev/null)"
exit_code=$?

case "${exit_code}" in
  0)
    [[ "${command}" == "${rewritten}" ]] && exit 0
    ;;
  1|2)
    exit 0
    ;;
  3)
    ;;
  *)
    exit 0
    ;;
esac

original_input="$(echo "${input}" | jq -c '.tool_input')"
updated_input="$(echo "${original_input}" | jq --arg cmd "${rewritten}" '.command = $cmd')"

if [[ "${exit_code}" -eq 3 ]]; then
  jq -n \
    --argjson updated "${updated_input}" \
    '{
      "hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "updatedInput": $updated
      }
    }'
else
  jq -n \
    --argjson updated "${updated_input}" \
    '{
      "hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "allow",
        "permissionDecisionReason": "RTK auto-rewrite",
        "updatedInput": $updated
      }
    }'
fi
