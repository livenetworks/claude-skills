# Agent Hard Limits — Discipline Patch

## Context

All four domain architects (`js-architect`, `scss-architect`, `backend-architect`, `frontend-architect`) currently have ambiguous rules around self-execution and git. In practice this has already caused one architect to write a plan file, then immediately self-execute it AND call git directly — defeating the whole point of the architect/executor split (keep Opus on thinking, keep Sonnet on mechanical work).

This patch adds a non-negotiable "Hard Limits" section to all four architects and tightens the existing "Decide scope before acting" wording. It also adds a no-git rule to the executor for defensive symmetry.

## Goals

1. Plan files become a strict contract — architect stops after writing one
2. Git is never touched by an architect or executor — always delegated to `@git-push` / `@git-release`
3. "Trivial direct fix" window becomes narrow and unambiguous

## Files to Modify

1. `.claude/agents/js-architect.md`
2. `.claude/agents/scss-architect.md`
3. `.claude/agents/backend-architect.md`
4. `.claude/agents/frontend-architect.md`
5. `.claude/agents/executor.md`

No build verification needed — these are markdown files. No tests.

## Executor Prompt

### Step 1: Add "Hard Limits" section to all four architect files

For each of these files — `js-architect.md`, `scss-architect.md`, `backend-architect.md`, `frontend-architect.md` in `.claude/agents/` — insert the following new section **immediately before the `## Your Role` heading** (i.e., right after the "When the Chief Architect Must Delegate Here" section ends).

**Exact text to insert (verbatim, same block for all 4 files):**

```markdown
## Hard Limits — Non-Negotiable

You were delegated to specifically to keep mechanical work off the chief
architect's Opus context. Three rules preserve that split — breaking any of
them defeats the delegation entirely.

**1. Wrote a plan? Stop — don't execute it yourself.** A `.claude/plans/*.md`
file is your final deliverable. Do NOT then read it back and implement it,
run `npm run build`, or edit the files it describes. That is `@executor`'s
job. Self-executing your own plan burns Opus tokens on mechanical work that
Sonnet should do — the exact inversion of why the chief architect delegated
to you. Your summary should end with "Execute: @executor Implement
.claude/plans/{file}" and nothing more.

**2. Never call git directly.** No `git add / commit / push / tag / reset /
diff / log / status`. Git is handled by dedicated agents:
- Commit + push outstanding changes → `@git-push`
- Tagged semantic release → `@git-release`

If you want to commit what you just did, stop and return control to the
chief architect — they will invoke the git agent. Git is never in your lane.

**3. Trivial direct-fix window is narrow.** You may edit directly (skipping
both the plan file and `@executor`) ONLY when ALL of these hold:

- ≤3 Edit calls on 1-2 tightly related files
- No `npm run build`, test run, or migration needed to verify
- No architectural decision to make (no picking between valid approaches)
- Obviously correct — you would not need to explain the choice to a reviewer

If ANY fails → write a plan file and delegate to `@executor`. When in doubt,
delegate. The cost of an extra `@executor` spawn is far lower than the cost
of you doing mechanical work on Opus.

```

**Placement anchor:** The line immediately above `## Your Role`. In js-architect.md this is `logic changes inline — stop and delegate here instead.` In scss-architect.md this is `drafting a rewrite inline — stop and delegate here instead.` In backend-architect.md this is `and drafting logic changes inline — stop and delegate here instead.` In frontend-architect.md this is `drafting coordinated changes inline — stop and delegate here instead.`

All four share the structure: last line of the "When Chief Architect Must Delegate Here" section, then a blank line, then `## Your Role`. Insert the Hard Limits section into that gap — blank line above, blank line below.

### Step 2: Update "Decide scope before acting" wording in all four architects

In each of the four architect files, find the `### Decide scope before acting` block inside the `## Output` section. It currently reads:

```markdown
### Decide scope before acting

**Small fix (under ~5 changes, no ambiguity):**
Apply directly. Use Edit tool for existing files.
Show what you changed and why.
```

Replace ONLY the "Small fix" paragraph (keeping the heading and the "Unclear or competing approaches" / "Significant work" paragraphs below it intact) with:

```markdown
**Trivial direct fix (see Hard Limits §3 for the full criteria):**
Apply directly. Use Edit tool for existing files.
Show what you changed and why.
No plan file, no `@executor` spawn.
```

The "Unclear or competing approaches" and "Significant work (5+ changes...)" blocks below it stay exactly as they are — do not touch them.

### Step 3: Add git prohibition to executor.md Rules

In `.claude/agents/executor.md`, find the `## Rules` section near the bottom. It currently ends with:

```markdown
- Trust the plan. Trust the architect. Trust the build. The verifier handles the rest.
```

Add ONE new rule immediately before that final "Trust the plan" line:

```markdown
- Never call git directly (`git add / commit / push / tag / reset / diff / log`). If the plan says "push to git", escalate to the chief architect via Open Questions — do not commit yourself. Git is handled by `@git-push` and `@git-release` only.
```

The "Trust the plan…" line remains as the last bullet.

### Boundaries

- Do NOT modify the frontmatter (name, description, tools, model, color, effort, permissionMode, skills) of any file
- Do NOT rewrite the "When the Chief Architect Must Delegate Here" section
- Do NOT change the "Your Process" steps
- Do NOT touch `git-push.md`, `git-release.md`, or `verifier.md` — they are already scoped correctly
- Do NOT run `npm run build` — these are markdown files, there is nothing to build

### Acceptance

1. All 4 architect files now have a `## Hard Limits — Non-Negotiable` section with 3 numbered rules, inserted right before `## Your Role`
2. All 4 architect files have "Trivial direct fix (see Hard Limits §3…)" wording instead of "Small fix (under ~5 changes, no ambiguity)"
3. `executor.md` has a new "Never call git directly" bullet in its Rules section
4. No other changes to any file

### Report format

Just say "PASS — 5 files updated" and list the file names. No file contents needed.
