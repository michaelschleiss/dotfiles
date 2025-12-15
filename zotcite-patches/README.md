# Zotcite Patches

Patches for `jalvesaq/zotcite` to improve LaTeX citation completion.

## Files

- `lsp.lua.patch` / `lsp.lua.patched` - LSP completion improvements
- `bib.lua.patch` / `bib.lua.patched` - Bibliography handling fixes
- `zotero.lua.patch` / `zotero.lua.patched` - Zotero integration fixes

## Fixes Applied

### lsp.lua

**Buffer-local state**
- *Problem*: Global `last_line` and `compl_region` variables caused state pollution when switching between buffers, leading to broken completions
- *Fix*: Per-buffer state table indexed by buffer number, cleaned up on BufDelete

**triggerCharacters `{`**
- *Problem*: Completion only triggered after typing characters, forcing manual `<C-x><C-o>` after `\cite{`
- *Fix*: Register `{` as trigger character so LSP auto-completes immediately after `\cite{`

**Empty prefix handling**
- *Problem*: When cursor is right after `\cite{` with no characters typed, `word` was nil and completion returned empty
- *Fix*: Default `word` to empty string for tex files to show all available citations

**Completion range fix**
- *Problem*: `text_edit_range` only spanned 1 character, causing partial replacement when completing longer prefixes
- *Fix*: Calculate `word_start` as `char - #word` so the entire typed prefix gets replaced

**filterText for fuzzy matching**
- *Problem*: nvim-cmp fuzzy matching used the label (full citation info) instead of the citekey
- *Fix*: Add `filterText = citekey` so typing partial keys filters correctly

**Return after tex check**
- *Problem*: For tex/rnoweb files, `set_compl_region_rnw()` was called but then Markdown logic also ran, overwriting the region state
- *Fix*: Early `return` after handling tex files

### bib.lua

**Skip tex per-buffer updates**
- *Problem*: `M.update()` scans current buffer for citations to build bib, but LaTeX projects span multiple files. Running on a single tex file produces incomplete zotcite.bib
- *Fix*: Skip per-buffer updates for tex filetype; use `:ZbibAll` command instead which processes all project files

### zotero.lua

**seriesEditor support**
- *Problem*: Series editors weren't included in bib output, causing missing contributor info for edited volumes
- *Fix*: Add `seriesEditor` to the author/editor iteration list

**key_type fallback**
- *Problem*: During init, `get_key_type()` could return nil before buffer config was set, causing errors
- *Fix*: Fall back to `config.key_type` when buffer-specific value unavailable

**Refresh on bib update**
- *Problem*: `update_bib()` used stale cached data if Zotero database changed since last read
- *Fix*: Call `copy_zotero_data()` at start of `update_bib()` to refresh cache

## How to Apply

Two options are provided. Try patches first; fall back to full copies if conflicts occur.

### Option 1: Apply patches (preferred)

Patches preserve upstream changes and only apply your modifications on top.
May fail if upstream changed the same lines.

```bash
cd ~/.local/share/nvim/lazy/zotcite
git apply ~/projects/dev/zotcite-patches/lsp.lua.patch
git apply ~/projects/dev/zotcite-patches/bib.lua.patch
git apply ~/projects/dev/zotcite-patches/zotero.lua.patch
```

If a patch fails with conflicts, either:
- Resolve manually, or
- Use Option 2 for that file

### Option 2: Copy patched files (fallback)

Full file copies that overwrite entirely. Guaranteed to work, but you lose
any upstream improvements made since these patches were created.

```bash
cd ~/.local/share/nvim/lazy/zotcite/lua/zotcite
cp ~/projects/dev/zotcite-patches/lsp.lua.patched lsp.lua
cp ~/projects/dev/zotcite-patches/bib.lua.patched bib.lua
cp ~/projects/dev/zotcite-patches/zotero.lua.patched zotero.lua
```

## Notes

- Pin zotcite in lazy.nvim with `pin = true` to prevent updates from overwriting
- Consider submitting these upstream as a PR
