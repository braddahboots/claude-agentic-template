---
name: validate
description: Run the full validation pipeline — type-checking, linting, truth file cross-reference, and optionally trigger the code-reviewer agent.
allowed-tools: Read, Bash, Glob, Grep, Task
---

# Validation Pipeline

## Steps

1. **Type-check / Compile**: Run the project's build command (from CLAUDE.md)
   - Report all errors with file paths and line numbers

2. **Lint**: Run the project's lint command (from CLAUDE.md) if configured
   - Report all warnings and errors

3. **Truth File Cross-Reference** (if truth file exists):
   - Scan all source files for imports from the primary SDK/framework
   - Cross-reference each import against the truth file
   - Report any imports not found in the truth file

4. **Code Review** (optional):
   - If the user requests a full review, spawn the `code-reviewer` agent on changed files
   - Report the reviewer's findings

5. **Summary**: Print a pass/fail summary:
   ```
   Type-check: PASS
   Lint: PASS (2 warnings)
   Truth file: 1 unknown import
   Review: Not requested (use /validate --review to include)
   ```
