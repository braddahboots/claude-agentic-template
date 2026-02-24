---
name: feedback
description: Intake feedback, analyze viability, and route to the correct file (MEMORY.md, rules, ROADMAP.md) following the escalation path. Use when receiving external feedback about the project or template.
allowed-tools: Read, Edit, Write, Glob, Grep
---

# Feedback — Intake, Triage, and Route

Takes raw feedback and determines where it belongs in the project's information architecture.

## Input

Paste the feedback as `$ARGUMENTS`. Can be any length — a one-liner, a bullet list, or a full post-mortem document.

## Handling Variable-Length Input

Feedback varies from a single sentence to a structured post-mortem with many items. Adapt the workflow:

### Single item (1-2 paragraphs)
Process directly — full analysis, routing, and proposed change in one pass.

### Multiple items (list, post-mortem, review with several points)
1. **Triage all items first** — read everything, classify each item in a summary table
2. **Present the triage table** with priority, classification, routing, and effort for each
3. **Ask the user** which items to proceed with (all, a subset, or one at a time)
4. **Process approved items** in priority order, presenting proposed changes for each

The triage table format:

```
| # | Item | Classification | Route | Effort | Already Exists? |
|---|------|---------------|-------|--------|-----------------|
| 1 | [short name] | [type] | [file] | S/M/L | No / Partial / Yes |
```

## Steps

1. **Read current state** to understand what already exists:
   - `.claude/memory/MEMORY.md` — existing learnings
   - `.claude/rules/` — existing behavioral constraints
   - `ROADMAP.md` — current status, open questions, decisions
   - `CLAUDE.md` — file ownership table and escalation path

2. **Analyze the feedback** — for each item, answer:
   - **What type is it?** (learning, constraint, feature request, process improvement, bug report, irrelevant)
   - **Is it already captured?** Check MEMORY.md, rules, and ROADMAP.md for duplicates or overlapping content
   - **Is it viable?** Does it apply to this project/template? Is it actionable?
   - **Is it a constraint or a requirement?** Constraints say what NOT to do. Requirements say what TO build. This distinction determines routing.

3. **Classify and route** using the file ownership model:

   | Classification | Route to | Action |
   |---------------|----------|--------|
   | One-off learning or gotcha | `MEMORY.md` | Append to appropriate section |
   | Recurring pattern / behavioral constraint | `.claude/rules/` | Create or update a rule file |
   | Feature request or requirement | `PRD.md` | **Flag only** — present to user, do not modify PRD.md |
   | Status update, decision, or open question | `ROADMAP.md` | **Flag only** — recommend using `/milestone` to update |
   | Process or template improvement | Direct edit | Edit the relevant infrastructure file (scripts, skills, etc.) |
   | Already captured | None | Report where it already exists |
   | Not relevant or not actionable | None | Explain why and skip |

4. **Present the analysis** before making any changes.

   For single items:
   ```
   ## Feedback Analysis

   ### Input
   > [quoted feedback]

   ### Classification: [type]
   **Viable**: Yes / No
   **Reason**: [1-2 sentences on why this is or isn't viable]

   ### Routing
   **Destination**: [file path or "No action needed"]
   **Action**: [what will be written/changed]
   **Already exists**: [No / Yes — where]

   ### Proposed Change
   [Show the exact text that will be added or changed]
   ```

   For multiple items: use the triage table (see above), then expand details per item as the user approves them.

5. **Wait for user confirmation** before applying changes. If the user approves:
   - For MEMORY.md: Append to the appropriate section using Edit
   - For rules: Create a new file or append to an existing rule using Write/Edit
   - For infrastructure (scripts, skills, hooks): Edit the file directly
   - For PRD.md / ROADMAP.md / CLAUDE.md: Remind the user to use the appropriate skill or make the change manually

6. **Escalation check** — After adding to MEMORY.md, check if similar learnings already exist there:
   - If 2+ related learnings exist on the same topic → suggest promoting to a rule
   - If the learning is about something dangerous → suggest enforcing with a hook
   - Present the escalation recommendation but don't act without approval

## Constraints

- **Never modify PRD.md** — requirements are user-owned
- **Never modify ROADMAP.md directly** — use `/milestone` for that
- **Never modify CLAUDE.md directly** — flag for manual update
- **Always present analysis before writing** — no silent changes
- **Follow the escalation path** — default to MEMORY.md unless there's clear justification for a rule
- **Reject vague feedback** — if the feedback isn't specific enough to act on, ask for clarification rather than guessing
