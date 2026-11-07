#!/bin/bash
# Claude Code status line: model | cost | context | cwd (git branch)
input=$(cat)

IFS=$'\t' read -r model cost used size pct cwd < <(
  echo "$input" | jq -r '[
    (.model.display_name // "?"),
    (.cost.total_cost_usd // 0),
    (.context_window.total_input_tokens // 0),
    (.context_window.context_window_size // 0),
    (.context_window.used_percentage // ""),
    (.workspace.current_dir // .cwd // "")
  ] | @tsv'
)

fmt() { # 1234 -> 1.2k, 1500000 -> 1.5M
  awk -v n="$1" 'BEGIN{ if(n>=1000000) printf "%.1fM", n/1000000; else if(n>=1000) printf "%.1fk", n/1000; else printf "%d", n }'
}

cost_s=$(printf '$%.2f' "$cost")
if [ -n "$pct" ]; then
  ctx="$(fmt "$used")/$(fmt "$size") ($(printf '%.0f' "$pct")%)"
else
  ctx="0/$(fmt "$size") (0%)"
fi

branch=""
if [ -n "$cwd" ] && b=$(git -C "$cwd" --no-optional-locks symbolic-ref --short -q HEAD 2>/dev/null || git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null); then
  branch=" ($b)"
fi

printf '\033[36m%s\033[0m | \033[33m%s\033[0m | ctx %s | \033[32m%s\033[0m\033[35m%s\033[0m' \
  "$model" "$cost_s" "$ctx" "${cwd/#$HOME/~}" "$branch"
