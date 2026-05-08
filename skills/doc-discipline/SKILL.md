---
name: doc-discipline
description: "Doc-discipline pass workflow for ln-ashlar JS components. Use this skill when running a documentation cleanup/tightening pass on a `js/ln-{name}/README.md` and its companion `docs/js/{name}.md`. Covers: the standard checklist, completed-component benchmarks, the architect → executor → spot-check flow, and hard rules about untouched source/demo files. Triggers on phrases like 'doc-discipline pass', 'почни ln-{name}', or any cleanup of an existing component's docs."
---

# Doc-Discipline Pass

> Role: tighten an already-written component's docs without rewriting them.
> A pilot-doc rewrite produces the doc; a discipline pass trims drift, speculation,
> and double-coverage AFTER the doc has been in use for a while.

This skill exists because the same checklist has now been applied across
ln-search, ln-accordion, and ln-modal. The pattern is stable enough to
codify; further passes should follow this skill, not re-derive from
CLAUDE.md + commit history each time.

---

## When to invoke

Trigger phrases:

- "doc-discipline pass on ln-{name}"
- "почни ln-{name}" (project workflow shorthand for "next component on
  the doc-discipline task list — see TaskList")
- "trim ln-{name} docs" / "clean ln-{name} README"

NOT for: pilot-doc rewrites of components that don't yet have a README
(use the pilot-doc plan template instead — see
`.claude/plans/ln-validate-pilot-doc.md` as the original template).

---

## Files in scope

For component `ln-{name}`:

- `js/ln-{name}/README.md` — usage-facing doc (attributes, events, API,
  examples)
- `docs/js/{name}.md` — architecture-facing doc (lifecycle, internal
  flow, state, mechanism)

ALWAYS untouched (hard rule):

- `js/ln-{name}/ln-{name}.js` — source. If a real bug is found during
  audit, FLAG it but do NOT fix in this pass — open a separate task.
- `js/ln-{name}/ln-{name}.scss` — co-located CSS.
- `demo/admin/{name}.html` — the testing playground. Doc accuracy
  means matching what the demo shows, NOT changing the demo.
- Any other component's docs.

---

## The Checklist

Apply to BOTH `README.md` and `docs/js/{name}.md`:

### 1. No speculative edge cases

Drop "what if you do X" subsections that describe scenarios users
wouldn't actually attempt. Document the contract, not every possible
misuse. §Edge cases sections are usually a violation; assess each
bullet — most go.

### 2. No naming wrong patterns

Don't keep §Why not X? blocks that name alternatives the component
intentionally rejects, unless the rejection is a frequent
real-reader question. Most §Why not X? subsections are noise.
Drop the section heading entirely once subsections empty out.

Cross-component anti-pattern naming (e.g. "unlike ln-popover, this
component does X") usually goes too — it dates fast, and readers
arriving from `ln-popover` know the difference already.

### 3. No double-coverage

README and `docs/js/{name}.md` MUST split roles cleanly:

- **README** = usage. Attributes, events, examples, API, sizing
  variants, cross-component composition (when the component is
  meant to be composed). What a CONSUMER needs.
- **docs/js** = architecture. Lifecycle, internal state,
  MutationObserver flow, focus management mechanism, DOM mutations
  performed, z-index stack, persistence path. What an INTERNAL
  reader / contributor needs.

If both files explain the same thing (e.g. focus management mechanism
in README's §Philosophy AND in docs/js's §Focus management), the
README copy is redundant — trim or replace with a one-line back-link
to docs/js.

### 4. No historical prose after refactor

Drop:

- "previously this used X but now it uses Y" framing
- "In the original implementation..." paragraphs
- Migration narratives once the migration is done
- "X-line component" / specific-line-count brags (drift bait — line
  counts change with every commit)

### 5. No drifted line citations

`ln-{name}.js:42` style references must match current code or be
removed. Verify by reading the cited line. If the file has
restructured significantly, drop the citations entirely — readers
can grep.

### 6. Tagline / philosophy sections must be tight

- README tagline: 1 short paragraph (≤3 lines), ideally one sentence,
  stating the contract in one breath. The accordion and modal taglines
  are the benchmark.
- §Philosophy (if kept): ≤2-3 paragraphs of contract content. NOT 7
  subsections covering every possible reader concern.

### 7. Examples must match the actual contract

Cross-check every HTML example against:

- The actual code in `js/ln-{name}/ln-{name}.js`
- The demo at `demo/admin/{name}.html`
- The CLAUDE.md project section if the component has one (Modal,
  Button, Pill, etc.)

If an example teaches an old class name (`.ln-modal__content`), an
old API path, or a wrapper element no longer required — fix the
example.

### 8. Attribute-first vs imperative-first framing

Components with `data-ln-{name}` as the documented "single source of
truth" (per CLAUDE.md or the component's contract) MUST lead with the
attribute pattern, not the imperative API. The JS API is a "thin
convenience layer over `setAttribute`."

Recent precedent: `d274674 refactor(toggle): drop imperative API;
enforce attribute-only contract` flipped the framing for ln-toggle.
Subsequent passes (ln-modal) followed suit. Check the source — if
`setAttribute('data-ln-{name}', ...)` and the API are functionally
equivalent (API just calls setAttribute under the hood), the doc
must lead with the attribute.

---

## Cross-doc consistency

After per-doc trims, do a final pass comparing the two files:

- Same fact stated twice → keep in the better-fitting doc per the
  README/docs/js role split (rule §3).
- Contradicting facts → trust the source code, fix both docs to
  match.
- README mentions an architecture detail with no docs/js back-link
  → either remove (if internal-only) or add a one-liner `see
  [docs/js/{name}.md](../../docs/js/{name}.md#section)`.

---

## Benchmarks (completed passes)

| Component | README lines | docs/js lines | Commit |
|---|---|---|---|
| ln-search | (post-pass figures pending) | — | `7a64917` |
| ln-accordion | 414 | 264 | `b969d69` |
| ln-modal | 269 | 288 | (uncommitted at time of skill creation) |

**Targets**: there is NO universal line-count target. Aim for "as tight
as the contract allows." If `docs/js` has many genuinely-protected
sections (full §Lifecycle for a 4-state component, full §Focus
management mechanism, full §State table), the file will land at
~280-300; that's fine. Reaching for an unrealistic target across all
components causes either scope creep into protected sections or
discipline drift.

The architect step's job is to PROPOSE a target based on the audit;
the executor's job is to hit the architect's targets WITHIN the
plan's edit boundaries. If the target is unreachable while respecting
boundaries, the executor reports the discrepancy — that is a plan
estimation error, not a discipline failure.

---

## Workflow

This pass uses the standard chief-architect → domain-architect →
executor → spot-check chain.

### Step 1 — Delegate audit + plan to `js-architect`

Spawn `js-architect` with:

- The component name (`ln-{name}`)
- A pointer to this skill (`.claude/skills/doc-discipline/SKILL.md`)
- Reference to the previous benchmarks (ln-accordion, ln-modal)
- The standard scope boundaries (source/demo untouched)
- Special considerations for THIS component:
  - Recent code refactors that should be reflected in framing
    (e.g. ln-toggle's `d274674`)
  - Any CLAUDE.md project section relevant to the component
  - Known cross-component coordination (e.g. ln-toggle is used by
    ln-accordion, ln-dropdown — note in case docs need cross-link)

The architect produces `.claude/plans/ln-{name}-doc-discipline.md`
with:

- Numbered audit findings per file
- Concrete edits (drop §X, compress §Y to N lines, replace prose
  with snippet, etc.)
- Cross-doc consistency notes
- Acceptance-criteria greps (negative + positive)
- Self-contained executor prompt at the end

### Step 2 — Spawn `@executor` with the plan

Standard executor invocation. Key constraints in the prompt:

- Touch only the two doc files named in the plan
- Do NOT modify `ln-{name}.js`, `ln-{name}.scss`, `demo/admin/{name}.html`
- Do NOT touch other components' docs
- Run the plan's acceptance-criteria greps and report PASS/FAIL each
- Report final line counts vs targets
- Confirm via `git diff` that source files are untouched

### Step 3 — Spot-check (skip verifier)

Per Verifier Gating (`.claude/CLAUDE.md` §Verifier Gating for Direct
Executor Delegations), this is mechanical doc work — verifier
SKIPPED. Run ≤5 targeted greps yourself:

- ≥1 positive (canonical content present, e.g. tagline at top)
- ≥1 negative (dead pattern gone, e.g. `## Why not X?` absent)
- Confirm source files in `git diff` are unchanged
- Log the greps explicitly in the user-facing summary

If any spot-check fails → spawn `@verifier`, do NOT paper over.

### Step 4 — Mark task completed

Update the component's row in
`.claude/tasks/doc-discipline-tracker.md` from `PENDING` (or
`BUNDLED`) to `DONE`, with the new commit SHA. The tracker is the
persistent campaign-wide source of truth — session TodoWrite dies
on `/clear`, the tracker survives.

### Step 5 — Commit

Delegate to `@git-push` with a tight commit message in the form:
`docs(ln-{name}): doc-discipline pass`

If multiple components were trimmed in one pass, consolidate into a
single commit; otherwise one component per commit.

---

## Anti-patterns (do NOT do during a discipline pass)

- **Don't refactor source code** mid-pass. Audit may surface real
  bugs; flag them in the plan and stop. Open a separate task.
- **Don't add new sections.** A discipline pass REMOVES drift; it
  doesn't introduce new architectural docs. New material goes in a
  pilot-doc rewrite.
- **Don't restructure heading order** unless the current order is
  actively wrong. Keep the reader's mental map stable across passes.
- **Don't trim "protected" sections** in `docs/js` (§Lifecycle,
  §Focus management mechanism, §State, §MutationObserver,
  §Body scroll lock, §DOM mutations). These are the architecture
  doc's reason to exist. Trim drift in §Why-not-X / §Cross-component /
  §Known-gaps / §Performance-considerations sections instead.
- **Don't unify with other components' docs.** Each component's docs
  are scope-isolated.
- **Don't bump the line-count target if the architect's plan was
  unreachable.** Accept the architect's miss as a plan-estimation
  error, ship the pass at whatever line count was achievable within
  the plan's boundaries. (Ref memory: "No endless refactor reasons —
  ship the planned scope and stop.")

---

## Frequently-asked discipline-pass questions

**Q: The component already has a clean README — only `docs/js` needs
trim. Skip the architect?**

No. The architect step also produces the plan file that the executor
needs. Even if the audit is short ("README clean, docs/js has §Why
not X? bloat"), the plan still needs concrete edits and acceptance
greps. Architect cost is small for clean components.

**Q: There's no `docs/js/{name}.md` file. Discipline pass on README
only?**

Yes. Some components (helpers, very small components) only have a
README. Apply checklist to the single file. Do NOT create a new
`docs/js` file during a discipline pass — that's pilot-doc territory.

**Q: The component's source has changed significantly since the last
README touch. How much can I update?**

Examples and contract descriptions MUST match current source —
update them. New API methods that exist in code but aren't documented
get added. NEW SECTIONS introduced because the component grew (e.g.
new event lifecycle) are pilot-doc territory; surface as a follow-up
task.

**Q: The user said `почни ln-{name}` and the task is already
in_progress. What's the state?**

Most likely a previous session crashed or the user re-asked. Check
git diff for the affected files; check `.claude/plans/` for an
existing plan file. If a plan exists → skip architect, jump to
executor. If no plan → restart at architect step.

---

## Related

- `.claude/CLAUDE.md` §Verifier Gating — when to skip verifier
- `.claude/CLAUDE.md` §The Chief Architect Role — delegation discipline
- Recent passes:
  - `7a64917` ln-search
  - `b969d69` ln-accordion (set the §Coordinator-glossary precedent)
  - ln-modal (most recent — see `.claude/plans/ln-modal-doc-discipline.md`
    for the current plan template)
