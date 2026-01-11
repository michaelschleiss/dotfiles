---
name: code-simplifier
description: Simplify and refine code for clarity while preserving functionality
---

Launch the code-simplifier agent to analyze and improve recently modified code.

Use the Task tool with subagent_type "code-simplifier:code-simplifier" to run the code simplification agent. The agent will:

1. Identify recently modified code sections
2. Simplify code structure (reduce nesting, eliminate redundancy)
3. Improve naming and readability
4. Apply project standards from CLAUDE.md
5. Preserve all original functionality

If the user provided specific files or code to simplify, focus on those. Otherwise, focus on recently modified code in the current session.

Run the agent now with an appropriate prompt based on the user's request or context.
