# RTK

RTK is installed and available on PATH.

Use `rtk` for shell commands that can produce large or noisy output.

Examples:

```bash
rtk git status
rtk git diff
rtk git log -n 10
rtk rg pattern .
rtk read path/to/file
rtk cargo test
rtk pytest -q
rtk npm run build
rtk docker ps
```

Use raw commands when output is already tiny or when `rtk` does not support the command.

Meta commands:

```bash
rtk gain
rtk gain --history
rtk proxy <cmd>
```
