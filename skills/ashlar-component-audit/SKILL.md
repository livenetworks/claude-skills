---
name: ashlar-component-audit
description: >
  Runs the per-component audit loop for the ln-ashlar 50-component refactor:
  spawn ln-auditor on one component, submit its audit to review_audit via MCP,
  relay the critique back to the same agent, repeat to APPROVE or iteration 3,
  then move to the next component with a fresh agent. Use when auditing a
  component ("аудитирај ln-toggle", "почни аудит на ln-modal"), or when
  continuing the audit campaign. Step 2 of the refactor process.
---

# Component Audit Loop

This is **step 2** of the refactor process (see memory
`project_refactor-process-2026-09`). You are the orchestrator. You do not audit.

## Prerequisite

`plans/audit/_doctrine.md` must exist. It is the measuring stick. If it is
missing, stop — step 1 is not done.

## The loop, per component

### 1. Spawn a fresh `ln-auditor`

```
Agent(subagent_type: "ln-auditor", model: "opus", run_in_background: false)
```

Pass the explicit model — frontmatter pins are not reliably honored here.

The prompt is short. The agent's definition carries the procedure; do not
restate it. Give it: the component name, and the path to the doctrine.

**One component per agent. Never two.** Batch reading is what produces
hallucination — it is the reason this process exists.

### 2. Read the audit and submit it for review

```
mcp__claude_ai_Live_Networks__review_audit({
  component: "ln-{name}",
  audit: <full text of plans/audit/ln-{name}.md>,
  project_files: <full text of every file in scope, each preceded by its
                  path and real line count>,
  caller: "claude",
  iteration: 1,
  async: true          ← ALWAYS. Sync calls time out during generation.
})
```

Then poll `get_review_result({ job_id })` until it completes.

**`project_files` is the part that goes wrong.** On the `ln-toggle` review the
reviewer claimed the README had no Internals section (it did, at line 140),
misquoted the §4 heading, and called a 27-line file "~20 lines". Two of its six
issues were pure noise from bad ground truth. Pass the files **complete and
untruncated**, and label each with its real `wc -l` count so truncation is
detectable. This costs nothing and buys back review cycles.

### 3. Relay the critique — do not act on it yourself

On `REVISE`, send the critique to **the same agent** via `SendMessage`. Its
context is intact; it revises rather than restarting.

Resubmit with `iteration` incremented and `previous_feedback` set to the
critique you just received. Always `async: true`.

**Stop at `APPROVE`, or when `iteration: 3` is reached.** Three is the server's
default cap; it will reject higher.

### 4. Next component

Spawn a **new** `ln-auditor`. Do not reuse the previous one — its context is
full of another component and that is exactly the contamination this process
avoids.

## When to stop and ask the user

The reviewer's critiques are where **new doctrinal forks surface**. This is the
main reason the critique passes through you rather than going straight to the
agent.

If a critique raises a question the doctrine does not answer — a rule that
contradicts itself, a benchmark that violates its own standard, a pattern with
no precedent — **stop the loop and bring it to the user.** Do not let the agent
resolve it, and do not resolve it yourself. Rulings are the user's.

Precedent: the `ln-toggle` review surfaced that `.open` is required by the
canonical `@mixin collapsible` while doctrine forbade bare state classes. That
became ruling П1. It would have been lost if the agent had quietly "fixed" it.

## After the loop, per component

- Confirm nothing outside `plans/audit/` changed. The auditor has `Write` for
  its own file only; verify it stayed in its lane.
- Report to the user in one or two lines: the receipt, plus anything that needs
  their attention.

## Running the full campaign

Run every component end to end. **`APPROVE` from `review_audit` is the gate** —
when a component passes it (or hits `iteration: 3`), move straight to the next.
Do not stop to ask the user between components.

Both the audit text and each critique pass through your context, so keep the
per-component footprint minimal: the agent returns a one-line receipt, and you
report one line per component. Never paste an audit body into the conversation.
When context gets summarized mid-campaign, nothing is lost — every audit is on
disk in `plans/audit/`, and the next component starts with a fresh agent anyway.

The one thing that **does** stop the loop is a new doctrinal fork (see below).
## Anti-patterns

- **Auditing yourself.** You orchestrate. The moment you start reading component
  source to form your own opinion, you have become a second auditor with a
  different standard.
- **Letting the agent read an old audit.** They are deleted for a reason; old
  framing imports old blind spots.
- **Fixing anything.** Step 2 produces findings. Fixes happen in steps 5-6,
  after findings are grouped. Not before, not "while we're here".
- **Ruling on an open fork** because it came up mid-audit. Report it, ask the user.
- **Reporting a review as APPROVE when the MCP server was unreachable.** Say
  plainly that it shipped unreviewed, and why.

## Related

- `plans/audit/_doctrine.md` — the standard, including the five rulings and §8
- `.claude/agents/ln-auditor.md` — what the agent does
- memory `project_refactor-process-2026-09` — the six-step process this sits in
