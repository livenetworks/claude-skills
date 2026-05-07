# Doc-Discipline Campaign — Tracker

> Persistent tracker for the doc-discipline campaign across all
> ln-ashlar JS components. Survives `/clear`. Update when a
> component's status changes.
>
> Workflow: see `.claude/skills/doc-discipline/SKILL.md`.
> Per-component plans: `.claude/plans/ln-{name}-doc-discipline.md`
> (where they exist).

## Status legend

- **DONE** — dedicated `docs(ln-{name}): doc-discipline pass` commit,
  OR landed in a broader discipline-class commit AND verified
  against the current skill checklist (line counts on target,
  acceptance greps pass, etc.).
- **BUNDLED** — landed in a broader discipline-class commit
  (`0b8f678` prose-discipline, `11f1fd2` full audit, etc.) but not
  separately re-verified against the current skill checklist. May
  satisfy standards, may not — re-audit when revisited.
- **PENDING** — no doc-discipline-class commit; component is in
  its original or initial-create doc state.

## Components

| # | Component | Status | Commit / notes |
|---|---|---|---|
| 1 | ln-search | DONE | `7a64917` |
| 2 | ln-accordion | DONE | `b969d69` (set coordinator-glossary precedent) |
| 3 | ln-modal | DONE | `76e2a46` + `52e876b` |
| 4 | ln-toggle | DONE | `705985b` |
| 5 | ln-tabs | DONE | `7a3437c` |
| 6 | ln-tooltip | DONE | `a162c13` |
| 7 | ln-circular-progress | DONE | `eb284fe` + `0ab03c0` |
| 8 | ln-http | DONE | folded into `0b8f678`; line counts (332/557) hit plan targets, 22/22 acceptance greps PASS |
| 9 | ln-progress | DONE | folded into `0b8f678`; user-confirmed 2026-05-06 |
| 10 | ln-autoresize | DONE | `0b8f678`; verified against skill checklist on 2026-05-07 |
| 11 | ln-autosave | DONE | `0b8f678` (post-`f7dd319` refactor); verified against skill checklist on 2026-05-07 |
| 12 | ln-confirm | DONE | `0b8f678`; verified against skill checklist on 2026-05-07 |
| 13 | ln-external-links | BUNDLED | `0b8f678` |
| 14 | ln-form | BUNDLED | `0b8f678`; pilot-doc plan exists at `.claude/plans/ln-form-pilot-doc-and-cleanup.md` |
| 15 | ln-icons | BUNDLED | `0b8f678` |
| 16 | ln-link | BUNDLED | `0b8f678`; pilot-doc plan exists at `.claude/plans/ln-link-pilot-doc.md` |
| 17 | ln-select | BUNDLED | `0b8f678`; **BLOCKED** — contains third-party code, needs refactor before doc-discipline pass |
| 18 | ln-table | BUNDLED | `0b8f678`; pilot-doc plan exists at `.claude/plans/ln-table-pilot-doc.md` |
| 19 | ln-validate | BUNDLED | `0b8f678` |
| 20 | ln-ajax | DONE | `11f1fd2` (older); re-passed against skill checklist on 2026-05-07 (plan: `.claude/plans/ln-ajax-doc-discipline.md`) |
| 21 | ln-data-table | BUNDLED | `11f1fd2` (older full-audit) |
| 22 | ln-dropdown | BUNDLED | `11f1fd2` (older full-audit) |
| 23 | ln-toast | DONE | `11f1fd2`; subsequent refactors `2eae08f` + `0d68074`; verified against skill checklist on 2026-05-07 |
| 24 | ln-translations | BUNDLED | `11f1fd2` (older full-audit) |
| 25 | ln-sortable | BUNDLED | `3ac6dc1` |
| 26 | ln-store | BUNDLED | `5753209` |
| 27 | ln-upload | BUNDLED | `18d4a3e` |
| 28 | ln-date | PENDING | — |
| 29 | ln-filter | PENDING | — |
| 30 | ln-nav | PENDING | — |
| 31 | ln-number | PENDING | — |
| 32 | ln-popover | PENDING | — |
| 33 | ln-time | PENDING | — |

`ln-core` is helpers (no README); not in scope for discipline pass.

## Counts

- DONE: 14
- BUNDLED (re-audit candidate): 13
- PENDING (genuine new pass): 6
- Out of scope (helpers): 1 (`ln-core`)
- Total JS folders: 34

## Recommended priority

1. **PENDING first** — six components with NO doc-discipline-class
   commit at all: ln-date, ln-filter, ln-nav, ln-number, ln-popover,
   ln-time.
2. **BUNDLED `11f1fd2`** (older full-audit, predates current skill)
   — five re-audit candidates: ln-ajax, ln-data-table, ln-dropdown,
   ln-toast, ln-translations.
3. **BUNDLED `0b8f678`** (prose-discipline pass) — assume DONE
   unless a specific drift / spec change calls for re-audit. Don't
   re-process speculatively.

## Operating rules

- **Update this file when a pass lands.** Don't rely on session
  TodoWrite — that dies on `/clear`.
- **PENDING → DONE flow:** (a) plan file at
  `.claude/plans/ln-{name}-doc-discipline.md`, (b) commit message
  `docs(ln-{name}): doc-discipline pass`, (c) flip status row here.
- **BUNDLED → DONE flow:** when a BUNDLED component is re-verified
  against the current skill checklist, add note
  `verified against skill checklist on YYYY-MM-DD` in the row.
- **Pilot-doc workflow** is separate from doc-discipline. Three
  components have pilot-doc plans (ln-form, ln-link, ln-table) but
  also already have BUNDLED docs from `0b8f678` — clarify with the
  user which workflow applies before acting.
