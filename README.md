# Claude Template — Universal .claude Infrastructure

A reusable `.claude/` infrastructure template for bootstrapping AI-assisted development environments from a PRD (Product Requirements Document).

## What This Is

This repo provides a complete `.claude/` configuration that implements a **three-layer enforcement model** to prevent the three core AI coding failure modes:

| Layer | Location | Purpose | Failure Mode Addressed |
|-------|----------|---------|----------------------|
| **Memory** | `.claude/memory/MEMORY.md` | Cross-session learnings (passive knowledge) | Memory loss |
| **Rules** | `.claude/rules/` | Active instructions (always-on + path-matched) | Hallucination |
| **Hooks** | `.claude/scripts/` | Deterministic shell scripts on lifecycle events | Scope creep |

**Escalation path:** If an AI mistake happens once, add to memory. If it recurs, promote to a rule. If it's dangerous, enforce with a hook.

## Quick Start

1. **Clone this repo** into your project root (or copy the `.claude/` directory):
   ```bash
   git clone <this-repo-url> .claude-infra
   cp -r .claude-infra/.claude .
   cp .claude-infra/CLAUDE.md .
   cp .claude-infra/CODEBASE_OVERVIEW.md .
   ```

2. **Write your PRD** — Describe your product, tech stack, architecture, key entities, and risk areas. See `examples/` for format and detail level.

3. **Place PRD at project root** as `PRD.md`

4. **Run Claude Code** and invoke `/bootstrap`

5. The bootstrap agent will:
   - Analyze your PRD
   - Generate domain-specific rules, agents, hooks, and skills
   - Generate a truth file from your SDK's type definitions (if applicable)
   - Configure build/lint/test commands
   - Initialize memory with SDK-specific gotchas

## Directory Structure

```
.claude/
  settings.json          # Permissions + hook definitions
  agents/                # Subagent definitions (orchestrator, reviewer, implementer, devops)
  rules/                 # Contextual instructions (always-on globals + path-matched domain rules)
  skills/                # Slash-command workflows (/bootstrap, /commit, /validate, /plan-feature)
  scripts/               # Hook scripts (pre-tool, post-edit, session lifecycle)
  memory/
    MEMORY.md            # Cross-session learnings (first 200 lines auto-loaded)

templates/               # Scaffolding templates with {{PLACEHOLDER}} markers (used by bootstrap)
examples/                # Example PRDs showing expected input format
scripts/                 # Utility scripts (truth file generator)
```

## How It Works

### The Bootstrap Flow

```
PRD.md → /bootstrap → bootstrap-orchestrator agent
                          ├── Analyzes tech stack, domain, entities, risks
                          ├── Generates domain-specific rules
                          ├── Creates domain-specific implementer agents
                          ├── Configures hooks for your build tools
                          ├── Generates truth file from type definitions
                          ├── Initializes memory with SDK gotchas
                          └── Updates CLAUDE.md with project config
```

### Agent Architecture

| Agent | Role | Model | Access |
|-------|------|-------|--------|
| `bootstrap-orchestrator` | Reads PRD, generates config | Opus | Full write |
| `implementer` | Writes code (main workhorse) | Sonnet | Full write |
| `code-reviewer` | Reviews code, reports issues (never fixes) | Sonnet | Read-only |
| `devops` | Git operations, CI/CD | Haiku | Bash + Read |

### The Truth File Pattern

The truth file is an auto-generated reference extracted from your SDK's type definitions (`.d.ts`, `.pyi`, type stubs). It lists every exported class, method, enum, and type — providing a deterministic source of truth that prevents API hallucination.

**How to use it:**
1. Run `scripts/generate-truth-file.sh <type-defs> <output>` to generate
2. The implementer agent reads the truth file before using any SDK API
3. The post-edit hook cross-references imports against the truth file
4. If an import isn't in the truth file, it's flagged as potentially hallucinated

**Source-of-Truth Hierarchy:**
1. Compiler/type-checker output (highest — deterministic)
2. Truth file (auto-generated from types)
3. Official documentation
4. Project rules
5. Memory
6. AI training knowledge (lowest — may hallucinate)

## Iterating After Bootstrap

After the initial bootstrap, refine your setup as you develop:

- **Add to memory** when you discover SDK gotchas or project patterns
- **Promote to rules** when memory entries aren't being followed consistently
- **Add hooks** when rules aren't sufficient (deterministic enforcement needed)
- **Update the truth file** after SDK upgrades: `scripts/generate-truth-file.sh`
- **Tune coding standards** in `.claude/rules/coding-standards.md`
- **Keep CODEBASE_OVERVIEW.md current** — the agents rely on it for navigation

## Available Skills

| Skill | Description |
|-------|-------------|
| `/bootstrap` | Initialize project from PRD |
| `/commit` | Validate and commit with conventional format |
| `/validate` | Full validation pipeline (type-check + truth file + lint) |
| `/plan-feature` | Decompose a feature into sequenced implementation steps |

## Requirements

- [Claude Code](https://claude.ai/claude-code) CLI
- `jq` (used by hook scripts to parse tool input)
- Git
- Project-specific build tools (configured during bootstrap)
