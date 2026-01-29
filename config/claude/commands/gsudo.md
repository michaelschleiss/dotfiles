---
name: gsudo
description: Toggle macOS GUI password prompts for sudo commands
---

Toggle the gsudo feature on or off for this session.

When enabled, all sudo commands will automatically use the native macOS GUI password dialog instead of terminal prompts. When disabled (default), regular sudo behavior is used.

Run this bash command to toggle the setting:

```bash
FLAG_FILE="$HOME/.cache/claude/sudo-gui-enabled"
if [[ -f "$FLAG_FILE" ]]; then
  rm "$FLAG_FILE"
  echo "✗ Sudo GUI transformation disabled (default)"
  echo "Regular sudo will be used"
else
  mkdir -p "$(dirname "$FLAG_FILE")"
  touch "$FLAG_FILE"
  echo "✓ Sudo GUI transformation enabled"
  echo "All sudo commands will use macOS GUI password prompts"
fi
```

Report the result to the user.
