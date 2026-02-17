---
name: bootstrap
description: Analyze a PRD (Product Requirements Document) and generate domain-specific .claude configuration for the project. Run this when initializing a new project.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, WebFetch, WebSearch, Task
---

# Bootstrap Project from PRD

## Prerequisites
- A file named `PRD.md` must exist in the project root
- Or pass the PRD path as an argument: `/bootstrap path/to/my-prd.md`

## Steps

1. **Locate PRD**: Read `PRD.md` from the project root (or the path provided as `$ARGUMENTS`)

2. **Delegate to Bootstrap Orchestrator**: Use the Task tool to spawn the `bootstrap-orchestrator` agent with the following prompt:

   > Read the PRD at [path] and generate a complete domain-specific .claude configuration. Follow your full workflow: Analysis → Rules → Agents → Hooks → Truth File → Skills → Memory → CLAUDE.md → CODEBASE_OVERVIEW.md

3. **Review Output**: After the orchestrator completes, verify:
   - [ ] Domain rules were created in `.claude/rules/`
   - [ ] Domain agents were created/updated in `.claude/agents/`
   - [ ] Hook scripts were configured in `.claude/scripts/`
   - [ ] Truth file was generated (if applicable)
   - [ ] `CLAUDE.md` was updated with project-specific configuration
   - [ ] `CODEBASE_OVERVIEW.md` was created
   - [ ] `MEMORY.md` was initialized

4. **Report**: Print a summary of what was generated and any manual steps needed.
