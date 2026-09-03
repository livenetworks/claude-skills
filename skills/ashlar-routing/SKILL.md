---
name: ashlar-routing
description: "Routing skill for work on a project that uses the ln-ashlar frontend library. Does not contain library facts — it tells you which documentation source to query for markup, attributes, events, tokens, mixins and doctrine, in what order, and which agent and review gate each kind of task goes through. Use it whenever a task touches ln-ashlar CSS, JS or markup."
---

# ln-ashlar — Routing & Process

> **This skill carries no library facts.** No markup, no attribute names, no mixin
> names, no component lists, no doctrine. All of that changes with every refactor,
> and a copy of it here would be wrong within weeks.
>
> What this skill does: tell you **where to look** and **who does what**.

---

## The one rule

This is **Rule Zero** (project `CLAUDE.md`) applied to library surfaces. The law is
defined there; this is what it means here.

**Never author ln-ashlar markup, attributes, events, class names, mixins or tokens
from memory or from this file.** Query the source below first, every time — including
when you are confident, and including when a name "obviously" follows the convention.

The library is refactored continuously. Anything you remember from a previous session
may have been renamed, lifted into a shared module, or deleted.

---

## Where to look

**Always use the ln-ashlar MCP server first.** The MCP server exposes tools to query the documentation RAG (Retrieval-Augmented Generation) for markup, attributes, events, components, and doctrine. Review the available tools provided by the MCP server and use the most appropriate ones to find the exact rules and syntax. Stop at the first source that answers your question.

**If the MCP server is unreachable**, fall back to the repository itself, in this order:

1. The component's own README — the contract for that component.
2. The shared-primitives module's barrel export file — the authoritative list of what
   is shared rather than component-local.
3. The component's source directory — the DOM shell and, when present, its model file.
4. The theme's mixin and token directories — for anything visual.
5. The demo pages — for working markup in context.

Never fall back to a compiled bundle. Never fall back to this file.

---

## Reading order for a new task

1. **Doctrine before code.** Fetch the architecture rules before proposing or writing
   anything. They are binding and they change.
2. **Router before markup.** Pick the component before you write HTML for it.
3. **Contract before wiring.** Fetch attributes and events before connecting components.
4. **Grep before claiming.** If you are about to state that a behaviour, method, event
   or attribute exists — search the source first. Trust the code, not your model of it.

---

## Who does the work

| Situation | Route to |
|---|---|
| Discussion, architecture question, spec review | handle directly — thinking is not delegated |
| Trivial fix, tightly scoped, obviously correct | edit directly |
| Single-domain task (styling only / JS only / backend only) | the matching domain architect |
| Task spanning markup, styling and behaviour together | the cross-cutting frontend architect |
| Frontend and backend together | split by domain; sequence them yourself |
| A plan file that already exists | straight to the implementation agent |
| Commit, push, release | the dedicated git agents — never run git directly |

Domain architects produce plans. They do not execute them. The implementation agent
executes. Verification follows execution. Git is last.

---

## Gates

**A plan must pass review before it is executed.** Submit the finished plan file to the
MCP plan-review tool and act on the verdict: revise and resubmit on a revise verdict,
with the iteration counter incremented and the previous feedback attached; hand off only
on approval, or once the iteration ceiling is reached. A revised plan is a new plan —
review it again. There is no exemption for small or obvious.

If no reviewer is reachable, the gate does not block the work — but say so plainly in
the summary. Never report an unreachable reviewer as an approval.

**Finished code can be reviewed the same way** via the MCP code-review tool when the
change is large or its correctness is not verifiable by inspection.

---

## When a source is wrong

Documentation drifts behind the code. When a source contradicts the source:

- Code wins over documentation. Always.
- Report the drift — say which document is stale and what the code actually does.
- Do not silently work around it, and do not copy the stale fact forward into new work.
- Do not fix it inline as part of an unrelated task unless asked.

---

## What must never be added to this file

Markup examples. Attribute or event names. Component names. Mixin or token names.
File paths inside the library. Doctrine or rules of any kind. Version-specific facts.

If you find yourself wanting to write one of those here, it belongs in the documentation
corpus instead, and this file should route to it. A skill that mirrors the library needs
updating every time the library changes; a skill that routes does not.
