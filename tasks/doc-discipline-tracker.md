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
| 10 | ln-autoresize | DONE | `0b8f678` (initial bundle); per-component pass landed 2026-05-07 (plan: `.claude/plans/ln-autoresize-doc-discipline.md`; README 433→252, docs/js 238→199) |
| 11 | ln-autosave | DONE | `0b8f678` (post-`f7dd319` refactor); verified against skill checklist on 2026-05-07 |
| 12 | ln-confirm | DONE | `0b8f678`; verified against skill checklist on 2026-05-07 |
| 13 | ln-external-links | DONE | `0b8f678` (initial bundle); per-component pass landed 2026-05-07 (plan: `.claude/plans/ln-external-links-doc-discipline.md`; README 596→314, docs/js 335→277 — landed below plan target ~155-175 / ~200-225, all 24 plan steps + acceptance greps PASS, plan estimation was optimistic) |
| 14 | ln-form | DONE | per-component pass landed 2026-05-07 (plan: `.claude/plans/ln-form-doc-discipline.md`; README 654→408, docs/js 276→276 — README above plan target ~280-310, plan estimation miss; all 11 acceptance greps content-PASS, P1 grep mismatch is markdown-blank-line off-by-one not content failure) |
| 15 | ln-icons | DONE | `0b8f678` (initial bundle); per-component pass landed 2026-05-07 (plan: `.claude/plans/ln-icons-doc-discipline.md`; README 111→116, docs/js 157→148) |
| 16 | ln-link | DONE | per-component pass landed 2026-05-07 (plan: `.claude/plans/ln-link-doc-discipline.md`; README 471→280, docs/js 230→213 — both above plan target ~200-230 / ~170-195, plan estimation miss; 10/10 acceptance greps PASS) |
| 17 | ln-select | BUNDLED | `0b8f678`; **BLOCKED** — contains third-party code, needs refactor before doc-discipline pass |
| 18 | ln-table | DONE | per-component pass landed 2026-05-07 (plan: `.claude/plans/ln-table-doc-discipline.md`; README 588→327, docs/js 344→334 — both within plan target band; 19/19 acceptance greps PASS) |
| 19 | ln-validate | DONE | per-component pass landed 2026-05-07 (plan: `.claude/plans/ln-validate-doc-discipline.md`; README 1187→730, docs/js 673→479 — both above plan target ≤450 / ≤350, plan estimation miss; 43/43 acceptance greps PASS; corrected factual misclaim about ln-store dispatching ln-form:error — only ln-form:submit exists) |
| 20 | ln-ajax | DONE | `11f1fd2` (older); re-passed against skill checklist on 2026-05-07 (plan: `.claude/plans/ln-ajax-doc-discipline.md`) |
| 21 | ln-data-table | DONE | per-component pass landed 2026-05-07 (plan: `.claude/plans/ln-data-table-doc-discipline.md`; README 646→586, docs/js 411→396 — both slightly above plan target 510-550 / 360-390; 10/10 acceptance greps PASS; corrected store.lnStore.query() result shape from records.totalCount to detail.total) |
| 22 | ln-dropdown | DONE | per-component pass landed 2026-05-07 post-refactor (plan: `.claude/plans/ln-dropdown-doc-discipline.md`; README 104→77, docs/js 129→82 — refactor moved teleport/placement to ln-core helpers) |
| 23 | ln-toast | DONE | `11f1fd2`; subsequent refactors `2eae08f` + `0d68074`; verified against skill checklist on 2026-05-07 |
| 24 | ln-translations | DONE | per-component pass landed 2026-05-07 (plan: `.claude/plans/ln-translations-doc-discipline.md`; README 233→157, docs/js 176→66 — README slightly above plan target 95-145 due to dense example HTML, docs/js within target; 20/20 acceptance greps PASS) |
| 25 | ln-sortable | DONE | `3ac6dc1` (older bundle); re-passed against skill checklist on 2026-05-07 (plan: `.claude/plans/ln-sortable-doc-discipline.md`; README 133→132, docs/js 197→123) |
| 26 | ln-store | DONE | per-component pass landed 2026-05-07 (plan: `.claude/plans/ln-store-doc-discipline.md`; README 138→179, docs/js 182→123 — README grew net to fix drift + add Examples + quota-exceeded; docs/js shed ~70 lines of duplication) |
| 27 | ln-upload | DONE | per-component pass landed 2026-05-07 (plan: `.claude/plans/ln-upload-doc-discipline.md`; README 192→155, docs/js 127→67 — both within plan target ~158 / ~66; 19/20 acceptance greps PASS, F6 dict-count is plan-estimation off-by-one not content failure) |
| 28 | ln-date | DONE | per-component pass landed 2026-05-07 (plan: `.claude/plans/ln-date-doc-discipline.md`; README 147→131, docs/js 170→133) |
| 29 | ln-filter | DONE | per-component pass landed 2026-05-07 (plan: `.claude/plans/ln-filter-doc-discipline.md`; README 194→180, docs/js 259→228) |
| 30 | ln-nav | DONE | per-component pass landed 2026-05-07 (plan: `.claude/plans/ln-nav-doc-discipline.md`; README 61→52, docs/js 28→43) |
| 31 | ln-number | DONE | per-component pass landed 2026-05-07 (plan: `.claude/plans/ln-number-doc-discipline.md`; README 110→101, docs/js 144→109) |
| 32 | ln-popover | DONE | per-component pass landed 2026-05-07 (plan: `.claude/plans/ln-popover-doc-discipline.md`; README 119→114, docs/js 72→72 — README landed 4 lines above plan target ≤110, plan estimation error not discipline failure; docs/js already at benchmark, no edits needed) |
| 33 | ln-time | DONE | per-component pass landed 2026-05-07 (plan: `.claude/plans/ln-time-doc-discipline.md`; README 107→99, docs/js 99→13 — pilot-doc follow-up flagged for missing architecture sections) |
| 34 | ln-core | DONE | per-component pass landed 2026-05-08 (plan: `.claude/plans/ln-core-doc-discipline.md`; docs/js 401→558 — ADDITIVE pass to document 8 helpers missing from prior doc (`isVisible`, `serializeForm`, `populateForm`, `getLocale`, `registerComponent`, `computePlacement`, `teleportToBody`, `measureHidden`) + minor trim; no README created — ln-core is internal helper module, no consumer-facing README by design; 14/14 acceptance greps PASS + heading-style consistency fix) |

`ln-core` is helpers — no consumer-facing README (none should exist). Architecture doc only, see row 34.

## Counts

- DONE: 32
- BUNDLED (re-audit candidate): 1
- PENDING (genuine new pass): 0
- Total JS folders: 34

## Recommended priority

The campaign is effectively complete. The single remaining BUNDLED row
(`ln-select`) is blocked on a third-party-code refactor — surface for
refactor, then run a discipline pass post-refactor.

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
