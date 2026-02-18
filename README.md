# Claude Template — Universal .claude Infrastructure

A reusable `.claude/` infrastructure template for bootstrapping AI-assisted development environments from a PRD (Product Requirements Document).

## What This Is

This repo provides a complete `.claude/` configuration that implements a **three-layer enforcement model** to prevent the three core AI coding failure modes:

| Layer | Location | Purpose | Failure Mode Addressed |
|-------|----------|---------|----------------------|
| **Memory** | `.claude/memory/MEMORY.md` | Cross-session learnings (passive knowledge) | Memory loss |
| **Rules** | `.claude/rules/` | Active instructions (always-on + path-matched) | Hallucination |
| **Hooks** | `.claude/scripts/` | Deterministic shell scripts on lifecycle events | Scope creep |

**Escalation path — rules are earned, not pre-generated:**
```
AI mistake happens once       → add to MEMORY.md
Same mistake recurs           → promote to a rule in .claude/rules/
Mistake is dangerous/critical → enforce with a hook in .claude/scripts/
```

The bootstrap intentionally generates only universal rules + one SDK constraint file. Domain-specific rules emerge organically as patterns prove they need enforcement.

## Prerequisites

- [Claude Code](https://claude.ai/claude-code) CLI
- **`jq`** — Required by hook scripts to parse JSON tool input
  - macOS: `brew install jq`
  - Ubuntu/Debian: `sudo apt install jq`
  - Windows: `choco install jq` or download from [jqlang/jq](https://github.com/jqlang/jq/releases)
- Git
- Project-specific build tools (configured during bootstrap)

## Quick Start

> **Important workflow order:** Initialize your project first → Copy template → Write PRD → **Start a new Claude Code session** → Run `/bootstrap`. The bootstrap agent needs your installed dependencies to locate type definitions and generate the truth file.

### Phase 1: Project Setup (in your terminal)

1. **Initialize your project** — Set up your project using your framework's CLI (e.g., `hytopia init`, `npx create-next-app`, `cargo init`). The template should be applied *after* your project scaffolding exists.

2. **Clone this template** and copy the infrastructure into your project:
   ```bash
   git clone <this-repo-url> .claude-infra
   cp -r .claude-infra/.claude .
   cp .claude-infra/CLAUDE.md .
   cp .claude-infra/CODEBASE_OVERVIEW.md .
   cp -r .claude-infra/templates .
   cp -r .claude-infra/scripts .
   ```

3. **Write your PRD** — Describe your product, tech stack, architecture, key entities, and risk areas. Place it at your project root as `PRD.md`. See `examples/` for format and detail level.

4. **(Optional) Verify setup** — Run the verification script to confirm files are in place:
   ```bash
   bash scripts/verify-setup.sh
   ```

### Phase 2: Bootstrap (in a new Claude Code session)

> **Critical:** Skills and hooks are loaded at session startup. If you copied the `.claude/` directory during an active session, those skills and hooks **will not be available** until you start a new session. Always start a fresh Claude Code session before running `/bootstrap`.

5. **Start a new Claude Code session** in your project directory.

6. **Run `/bootstrap`** — The bootstrap agent will:
   - Analyze your PRD
   - Generate universal rules + one SDK constraint file (not per-domain rules)
   - Create domain-specific implementer agents
   - Configure hooks for your build tools
   - Auto-detect your SDK's type definition file (`.d.ts`, `.pyi`, etc.) and generate a truth file
   - Configure build/lint/test commands
   - Initialize `ROADMAP.md` with milestones, decisions, and open questions
   - Initialize memory with SDK-specific gotchas

## File Ownership

Each type of content has exactly one owner file. This prevents duplication and drift:

| Content | Owned by | Read by |
|---------|----------|---------|
| Requirements (what to build) | `PRD.md` | agents, `/plan-feature` |
| Status, milestones, decisions, open questions | `ROADMAP.md` | agents, `/status`, `/plan-feature` |
| Behavioral constraints (what NOT to do) | `.claude/rules/` | agents during implementation |
| Cross-session learnings | `.claude/memory/MEMORY.md` | agents (auto-loaded first 200 lines) |
| File structure & purposes | `CODEBASE_OVERVIEW.md` | agents before any file modification |
| SDK/framework API reference | `*-truth.md` | agents, post-edit hooks |
### Troubleshooting

<details>
<summary><strong><code>/bootstrap</code> fails with "Unknown skill: bootstrap"</strong></summary>

This means the skill wasn't loaded at session startup. Common causes:

1. **You didn't restart Claude Code** after copying the `.claude/` directory. Close your session and start a new one.
2. **The `.claude/skills/bootstrap/SKILL.md` file wasn't copied correctly.** Run `bash scripts/verify-setup.sh` to check.

**Manual fallback:** If you can't get the skill to load, paste this into Claude Code:

```
Read the PRD at PRD.md and the bootstrap orchestrator spec at .claude/agents/bootstrap-orchestrator.md.
Follow the orchestrator's full workflow to generate domain-specific .claude configuration:
Analysis → Rules → Agents → Hooks → Truth File → Skills → Memory → CLAUDE.md → CODEBASE_OVERVIEW.md
```

Alternatively, you can invoke the orchestrator directly as a Task agent:

```
Use the Task tool to spawn the bootstrap-orchestrator agent with this prompt:
"Read the PRD at PRD.md and generate a complete domain-specific .claude configuration."
```

See `scripts/bootstrap-manual.md` for the full manual bootstrap guide.

</details>

<details>
<summary><strong>Hooks aren't firing after setup</strong></summary>

Hooks (like dangerous command blocking and post-edit type checking) are also loaded at session startup. If you copied `.claude/` during an active session, hooks won't be active until you restart. This is especially important during bootstrap — the safety net isn't protecting you until you're in a fresh session.

</details>

## Directory Structure

```
.claude/
  settings.json          # Permissions + hook definitions
  agents/                # Subagent definitions (orchestrator, reviewer, implementer, devops)
  rules/                 # Behavioral constraints (always-on globals + path-matched)
  skills/                # Slash-command workflows (/bootstrap, /commit, /validate, /status, etc.)
  scripts/               # Hook scripts (pre-tool, post-edit, session lifecycle)
  memory/
    MEMORY.md            # Cross-session learnings (first 200 lines auto-loaded)

ROADMAP.md               # Project status, milestones, decisions, open questions
templates/               # Scaffolding templates with {{PLACEHOLDER}} markers (used by bootstrap)
examples/                # Example PRDs showing expected input format
scripts/                 # Utility scripts (truth file generator)
```

## How It Works

### The Bootstrap Flow

```
PRD.md → /bootstrap → bootstrap-orchestrator agent
                          ├── Analyzes tech stack, domain, entities, risks
                          ├── Generates universal rules + ONE SDK constraint file
                          ├── Creates domain-specific implementer agents
                          ├── Configures hooks for your build tools
                          ├── Generates truth file from type definitions
                          ├── Initializes memory with SDK gotchas
                          ├── Initializes ROADMAP.md (milestones, decisions, open questions)
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

- **Use `/status`** to check your current milestone, open questions, and recent activity
- **Update ROADMAP.md** as you complete tasks, make decisions, and resolve questions
- **Add to memory** when you discover SDK gotchas or project patterns
- **Promote to rules** when memory entries aren't being followed consistently — rules are earned through the escalation path, not pre-generated
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
| `/review` | Trigger code-reviewer agent on recent changes |
| `/status` | Show current milestone, activity, and open questions from ROADMAP.md |
