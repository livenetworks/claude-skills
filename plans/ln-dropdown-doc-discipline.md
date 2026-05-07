# ln-dropdown — Doc-discipline cleanup pass (re-audit)

## Scope

Doc-only pass on two files:

- `/home/ashlar/ln-ashlar/js/ln-dropdown/README.md` (currently 104 lines)
- `/home/ashlar/ln-ashlar/docs/js/dropdown.md` (currently 129 lines)

Source `/home/ashlar/ln-ashlar/js/ln-dropdown/ln-dropdown.js` (174 lines)
is **NOT** changing. It was just refactored to use `ln-core` helpers
(`computePlacement`, `teleportToBody`, `measureHidden`); both docs were
last fully audited in commit `11f1fd2` (older skill version, pre-refactor).
This is a re-audit applying the current skill checklist on top of
whatever the previous bundled pass produced.

Demo `/home/ashlar/ln-ashlar/demo/admin/dropdown.html` and SCSS
`/home/ashlar/ln-ashlar/js/ln-dropdown/ln-dropdown.scss` are out of
scope.

## Why this pass

The source refactor to ln-core helpers means the docs may still
describe the old internal mechanism (private `_teleportToBody`,
private `_positionMenu`) as if dropdown owns them. Current source uses
shared helpers — so:

- README should describe the **observable contract** (menu opens
  positioned below the trigger; flips if no room; closes on outside
  click / resize). Mechanism is out of scope for README.
- docs/js should describe **how dropdown wires the shared helpers
  together** (the per-component lifecycle around them) and stop short
  of re-explaining what `computePlacement` / `teleportToBody` do —
  those are owned by `ln-core`.

The README is also missing a tagline blockquote (every recent
post-pass component has one) and a one-line ARIA contract note (the
source sets `role="menu"`, `role="menuitem"`, `aria-haspopup="menu"`,
`aria-expanded` — none mentioned in either doc).

Both files double-cover the public attribute table, the events table,
the API snippet, and the §Behavior bullets. Per skill §3, that
cross-doc redundancy collapses into README owning the consumer
surface and docs/js owning architecture.

## Issues found — README (`js/ln-dropdown/README.md`)

### Issue 1 — No tagline blockquote at top

Currently opens with a one-line prose paragraph ("Dropdown menu
component — teleports menu to `<body>`...") followed by a separate
"Built on top of `ln-toggle`" line. Recent benchmarks (ln-modal,
ln-popover, ln-accordion) all open with a `> blockquote` tagline that
states the contract in one breath.

**Add a tagline blockquote** that names: (a) what the component is,
(b) the dependency on `ln-toggle` for state (since the contract uses
`data-ln-toggle` attributes literally), (c) the one-line back-link to
docs/js for mechanics.

### Issue 2 — Missing ARIA contract note

Source sets `aria-haspopup="menu"` + `aria-expanded` on trigger,
`role="menu"` on the menu element, `role="menuitem"` on each direct
child of the menu (lines 22-37 of the source). README has zero
mention of any of this.

**Add a one-line note** in §Behavior or as a new §Accessibility row
in the §Attributes table, listing the auto-added ARIA. Keep it tight
(≤4 lines). Don't elaborate on screen-reader semantics — that's not
the contract surface, the auto-add IS the contract.

### Issue 3 — §Behavior > Teleport duplicates docs/js mechanism

Currently:

> When the menu opens, it is moved to `<body>` with `position: fixed`
> to escape CSS stacking contexts (`overflow: hidden`, `z-index`
> layers). A placeholder comment preserves the original DOM position.
> On close, the menu returns to its original location.

The "placeholder comment preserves the original DOM position" detail
is mechanism — that's `teleportToBody`'s contract, owned by ln-core.
docs/js already describes this section better.

**Compress** to one-line consumer-facing statement (e.g. "Open menu
is teleported to `<body>` so it escapes ancestor `overflow: hidden`
and stacking contexts; on close it returns to its original DOM
position.") and drop the placeholder-comment internal detail.

### Issue 4 — §Behavior > Positioning is fine but slightly long

3 bullets describe vertical/horizontal flip + gap. This is consumer
contract (where the menu lands relative to the trigger) — keep, but
collapse to a tighter form. The `--size-xs` token reference is good
to keep — consumers may want to override the gap.

**Compress** the 3 bullets into a single paragraph (≤4 lines), or
keep the bullets but trim each to one line.

### Issue 5 — §Behavior > Scroll → reposition / Resize → close — keep but trim

Both are observable consumer contract (menu moves with the trigger
on scroll; resize closes it). Keep. Each is currently ~2 lines —
already tight. No change.

### Issue 6 — §Behavior > Outside click → close — keep one line

Currently 2 lines. Trim "the trigger wrapper and the teleported menu"
to "the wrapper or the menu". One line is enough.

### Issue 7 — §CSS section — drop or compress hard

Currently 18 lines, with a SCSS code sample showing
`[data-ln-dropdown-menu] { display: none; ... &.open { display:
block; } a, button { ... } }` as if the consumer must write this.

The consumer does NOT write this — `ln-dropdown.scss` (co-located,
out of scope for this pass) ships the default styling. This section
is misleading: it teaches a consumer-side override pattern that isn't
actually how the library is consumed. The auto-added
`data-ln-dropdown-menu` attribute is mentioned in §Attributes already.

**Drop the entire §CSS section.** A consumer who wants to restyle
the menu can read `ln-dropdown.scss` directly (the section's last
line points to it); the SCSS sample teaches the wrong consumption
pattern.

### Issue 8 — §Integration with ln-toggle — collapse into tagline

Currently 3 lines explaining that `ln-dropdown` listens for
`ln-toggle:open` / `ln-toggle:close`. This is a mechanism detail
already covered in docs/js §Dependency on ln-toggle. Once the
tagline (Issue 1) names the ln-toggle dependency, this section is
redundant for the consumer.

**Drop the §Integration with ln-toggle heading and section.** The
tagline absorbs the necessary bit ("delegates state to ln-toggle").

### Issue 9 — §Dynamic elements — generic boilerplate, drop

Currently 1 line: "MutationObserver auto-initializes new
`[data-ln-dropdown]` elements added to the DOM (AJAX, dynamic
content)."

Every `data-ln-*` component in the library has a MutationObserver
auto-init via `registerComponent`. README-level documentation of this
fact for a leaf component is generic boilerplate — readers know.

**Drop the entire §Dynamic elements section.** If preserved, it
should be one bullet inside another section, but since the
information is universal across the library, dropping is cleaner.

### Issue 10 — §Events code example is fine

The event listener snippet (lines 64-68) shows the typical consumer
usage. Keep.

### Issue 11 — §API — keep but tighten

Currently:

```
var el = document.querySelector('[data-ln-dropdown]');
el.lnDropdown.destroy();  // cleanup, remove listeners, teleport back
```

Two minor issues:

- `var` should be `const` (project standard, CLAUDE.md §Coding
  Standards).
- The comment "teleport back" is a mechanism detail; "cleanup,
  remove listeners" is enough.

**Replace** with `const` and trim comment.

Also: dropdown does NOT have `open()` / `close()` / `toggle()` API
methods (state lives in ln-toggle). Per the skill §8 attribute-first
framing, the API section should clarify that to control the menu the
consumer toggles `data-ln-toggle` on the menu element (or clicks the
trigger button). Add 2 lines pointing at the ln-toggle attribute as
the open/close mechanism.

## Issues found — docs/js (`docs/js/dropdown.md`)

### Issue 12 — §HTML / §Attributes / §Events / §API are README's job

Lines 1-46 of docs/js are entirely consumer-facing material that
duplicates README:

- §HTML (lines 6-18) — same example as README §HTML Pattern
- §Attributes (lines 20-26) — table duplicates README's table
- §Events (lines 28-34) — table duplicates README's table
- §API (lines 36-46) — duplicates README §API; also includes the
  "Manual init (Shadow DOM, iframe only)" line which is generic
  registerComponent boilerplate

Per skill §3 ("docs/js = architecture; README = usage"), drop the
duplicated material. Replace the upper section of docs/js with a
brief 2-line pointer ("File: `js/ln-dropdown/ln-dropdown.js`. Public
contract — attributes, events, API examples — lives in
[`js/ln-dropdown/README.md`](../../js/ln-dropdown/README.md). This
document covers internal mechanics.") and let the §Internal
Architecture content begin immediately.

The §Behavior bullet list (lines 49-56) is also consumer-facing
contract — drop.

### Issue 13 — §Internal Architecture — protected, KEEP

Lines 60-130. This is the load-bearing architecture content the
docs/js exists to provide. Specifically protected:

- §State table (lines 62-72) — instance-property reference. Useful
  for contributors. KEEP.
- §Teleport + Placement flow diagram (lines 74-92) — the clearest
  description of how `teleportToBody` + `computePlacement` integrate
  with the per-component lifecycle. KEEP.
- §Positioning Algorithm (lines 94-106) — step list around
  `_reposition`, names the helpers from ln-core, explains
  bottom-end alignment. KEEP. The paragraph after the code block
  about "computePlacement accepts floating-ui-style strings" is
  worth keeping for contributor context.
- §Event Listeners Lifecycle table (lines 108-118) — exact table of
  listener-add / listener-remove timing. KEEP.
- §Dependency on ln-toggle (lines 120-122) — keep, but trim the
  "single source of truth" language since the same fact is in the
  README tagline now.
- §MutationObserver (lines 124-130) — keep; it's the per-component
  observer summary.

### Issue 14 — §Dependency on ln-toggle — trim slightly

Currently 3 lines:

> Dropdown does not manage open/close state itself. It listens to
> `ln-toggle:open` and `ln-toggle:close` events from the inner toggle
> element. The toggle's `data-ln-toggle` attribute remains the single
> source of truth for the menu's open/closed state.

Once the README tagline names the dependency, the third sentence
("single source of truth") is double-coverage. Drop sentence three.
Two-sentence version is enough for docs/js.

### Issue 15 — Cross-doc naming check (`ln-popover`)

The skill §2 cross-component anti-pattern naming rule says comparisons
like "unlike ln-popover…" must go. Verified: NEITHER README nor
docs/js currently mentions `ln-popover`. Nothing to remove on this
axis.

### Issue 16 — Drifted line citations / "X-line" claims

Verified by grep: no `ln-dropdown.js:N` style citations and no
"X-line component" boasts in either file. Nothing to remove on this
axis.

### Issue 17 — Examples match the demo

Cross-checked `demo/admin/dropdown.html` (lines 179-187, 197-211).
Demo dropdowns use exactly the contract the README documents:

```
<div data-ln-dropdown>
    <button data-ln-toggle-for="..." type="button">...</button>
    <ul id="..." data-ln-toggle>
        <li><button>...</button></li>
    </ul>
</div>
```

The README example has anchor (`<a href>`) items rather than
`<button>` items, which is fine — both are documented as supported
in the contract. No example changes needed.

The `docs/js` example uses `<nav>` as the wrapper (line 8). README
uses `<div>` (line 19). Both are valid wrappers (`data-ln-dropdown`
is element-agnostic). Keep both as-is — aligning to one wrapper isn't
a discipline concern.

## Cross-doc consistency

After per-doc trims, the two files split as:

- **README** — tagline, attributes table (with auto-added ARIA),
  HTML example, §Behavior (one paragraph each: teleport, positioning,
  scroll, resize, outside-click), §Events table + listener example,
  §API.
- **docs/js** — 2-line back-link to README, §State, §Teleport +
  Placement flow, §Positioning Algorithm, §Event Listeners Lifecycle,
  §Dependency on ln-toggle (2 sentences), §MutationObserver.

No fact appears in both files except for surface-level repetition
allowed by the role split (e.g. "uses `computePlacement` from
ln-core" appears in docs/js architecture; README mentions `--size-xs`
token gap as consumer-overrideable).

No `ln-popover` mentions, no historical-prose framing ("previously
this used X"), no "X-line component" brags.

## Acceptance criteria

After edits, all of these must hold:

### Negative checks (dead patterns gone)

1. `grep -n "## CSS" js/ln-dropdown/README.md` → no matches
2. `grep -n "## Integration with ln-toggle" js/ln-dropdown/README.md` → no matches
3. `grep -n "## Dynamic elements" js/ln-dropdown/README.md` → no matches
4. `grep -n "## HTML" docs/js/dropdown.md` → no matches
   (the consumer-facing §HTML section that duplicated README is gone)
5. `grep -n "## Behavior" docs/js/dropdown.md` → no matches
6. `grep -nE "^## API$" docs/js/dropdown.md` → no matches
   (the duplicated §API section that copied README is gone)
7. `grep -nE "^## Events$" docs/js/dropdown.md` → no matches
   (the duplicated §Events table is gone)
8. `grep -n "Shadow DOM, iframe only" docs/js/dropdown.md` → no matches
   (boilerplate manual-init comment dropped)
9. `grep -n "ln-popover" js/ln-dropdown/README.md docs/js/dropdown.md` → no matches
10. `grep -n "var el = " js/ln-dropdown/README.md` → no matches
    (`var` replaced with `const`)
11. `grep -n "placeholder comment preserves" js/ln-dropdown/README.md` → no matches
    (Teleport mechanism detail dropped)

### Positive checks (canonical content present)

12. `grep -n "^> " js/ln-dropdown/README.md | head -1` → tagline
    blockquote present at top of file (one or two lines, mirrors
    ln-popover / ln-modal pattern; mentions ln-toggle dependency)
13. `grep -n "^## Attributes" js/ln-dropdown/README.md` → exactly one match
14. `grep -n "^## HTML Pattern" js/ln-dropdown/README.md` → exactly one match
15. `grep -n "^## Behavior" js/ln-dropdown/README.md` → exactly one match
16. `grep -n "^## Events" js/ln-dropdown/README.md` → exactly one match
17. `grep -n "^## API" js/ln-dropdown/README.md` → exactly one match
18. `grep -n "role=\"menu\"" js/ln-dropdown/README.md` → at least one
    match (ARIA contract documented)
19. `grep -n "aria-haspopup" js/ln-dropdown/README.md` → at least one
    match
20. `grep -n "aria-expanded" js/ln-dropdown/README.md` → at least one
    match
21. `grep -n "^## State" docs/js/dropdown.md` → exactly one match
22. `grep -n "^## Teleport" docs/js/dropdown.md` → exactly one match
    (could read "## Teleport + Placement" — the heading currently is
    `### Teleport + Placement` under §Internal Architecture; after
    promotion to top level it's `## Teleport...`)
23. `grep -n "^## Positioning" docs/js/dropdown.md` → exactly one match
24. `grep -n "^## Event Listeners Lifecycle" docs/js/dropdown.md` → exactly one match
25. `grep -n "^## Dependency on ln-toggle" docs/js/dropdown.md` → exactly one match
26. `grep -n "^## MutationObserver" docs/js/dropdown.md` → exactly one match
27. `grep -n "computePlacement\|teleportToBody\|measureHidden" docs/js/dropdown.md` → at least 3 matches
    (the ln-core helpers stay named in the architecture flow)
28. `grep -n "README.md" docs/js/dropdown.md` → at least one match
    (back-link to consumer doc is present at top)

### Line-count targets (drift-resistant — upper bounds)

29. `wc -l < js/ln-dropdown/README.md` → ≤ 90 (target ~75-85; from 104)
30. `wc -l < docs/js/dropdown.md` → ≤ 110 (target ~90-100; from 129)

These targets are guidance, not law (per skill §Benchmarks). README
already 104 lines — small headroom only. docs/js 129 lines, more room
to drop the duplicated upper sections (consumer-facing material).
Underrunning is fine.

### Source untouched (negative check)

31. `git diff --name-only js/ln-dropdown/ln-dropdown.js` → empty output
32. `git diff --name-only js/ln-dropdown/ln-dropdown.scss` → empty output
33. `git diff --name-only demo/admin/dropdown.html` → empty output

No `npm run build` needed — doc-only pass.

## Real bugs / issues in source (flag only — do NOT fix in this pass)

Audit pass on `js/ln-dropdown/ln-dropdown.js` surfaced no real bugs.
The component is clean post-refactor:

- ARIA contract is set on construction (lines 22-37) and `aria-expanded`
  is updated in `_onToggleOpen` / `_onToggleClose` (lines 43, 55).
- All listeners are paired (add/remove) with stored references
  (lines 91-152) — destroy path (lines 156-168) cleans every one.
- Teleport restore closure is captured (line 44) and called on close
  (line 65) and in destroy (line 161) — no leak path.
- `_reposition()` reads `--size-xs` via `getComputedStyle` with `* 16
  || 4` fallback (line 83) — handles missing token gracefully.

Nothing to flag for a follow-up source-code task.

---

## Executor Prompt

### Context

You are doing a doc-discipline cleanup pass on the `ln-dropdown`
component. The component source (`js/ln-dropdown/ln-dropdown.js`,
174 lines) was just refactored to use `ln-core` helpers
(`computePlacement`, `teleportToBody`, `measureHidden`) and is NOT
changing in this pass. Only two doc files change:

- `/home/ashlar/ln-ashlar/js/ln-dropdown/README.md` (currently 104 lines, target ≤90)
- `/home/ashlar/ln-ashlar/docs/js/dropdown.md` (currently 129 lines, target ≤110)

Both files have drifted: the README is missing a tagline blockquote
and an ARIA contract note, has a §CSS section that teaches the wrong
consumption pattern, has an §Integration with ln-toggle section that
docs/js already covers, and a generic §Dynamic elements boilerplate
section. The docs/js has 46 lines of consumer-facing material at the
top (§HTML, §Attributes, §Events, §API, §Behavior) that duplicates
the README — per skill §3 "no double-coverage" the duplicated
content moves out, leaving docs/js with the protected architecture
sections only.

The audit is complete (in this plan). You are executing.

### Constraints

- Doc-only — never edit `js/ln-dropdown/ln-dropdown.js`,
  `js/ln-dropdown/ln-dropdown.scss`, `demo/admin/dropdown.html`, any
  SCSS in `scss/`, or any other component's docs.
- Tabs for indentation in any rewritten markdown blocks (code samples
  inside markdown stay with whatever indentation HTML/JS conventionally
  uses; don't reformat existing code blocks beyond what the section
  rewrite requires).
- `const` for new code samples (project standard, CLAUDE.md §Coding
  Standards).
- No emojis.
- No `npm run build` — there is nothing to build.
- The HTML example in README §HTML Pattern must continue to match the
  demo's structure (`<div data-ln-dropdown>` wrapper, `<button
  data-ln-toggle-for>` trigger, `<ul id data-ln-toggle>` menu, `<li>`
  items). Don't rewrite the example structure.
- After the pass, the README must NOT teach a different pattern from
  what `demo/admin/dropdown.html` shows.

### Prerequisites — read these first

1. `/home/ashlar/ln-ashlar/js/ln-dropdown/ln-dropdown.js` — confirm
   the current contract: `data-ln-dropdown` on wrapper,
   `[data-ln-toggle]` inside as menu, `[data-ln-toggle-for]` trigger
   button. ARIA auto-add (`role="menu"`, `role="menuitem"`,
   `aria-haspopup="menu"`, `aria-expanded`). Lifecycle around
   `ln-toggle:open` / `ln-toggle:close`. Calls `teleportToBody`,
   `computePlacement`, `measureHidden` from `../ln-core`.
2. `/home/ashlar/ln-ashlar/js/ln-dropdown/README.md` — full file (104 lines)
3. `/home/ashlar/ln-ashlar/docs/js/dropdown.md` — full file (129 lines)
4. `/home/ashlar/ln-ashlar/.claude/plans/ln-dropdown-doc-discipline.md` — this plan
5. `/home/ashlar/ln-ashlar/js/ln-popover/README.md` — recent post-pass
   benchmark for the tagline format and the attribute-first framing
   (119 lines)
6. `/home/ashlar/ln-ashlar/docs/js/popover.md` — recent post-pass
   benchmark for docs/js architecture-only content with a back-link
   to README at the top (72 lines)
7. `/home/ashlar/ln-ashlar/demo/admin/dropdown.html` (lines 175-215
   only) — confirm the HTML contract structure matches what README
   teaches

### Steps

#### Step 1 — README: replace top opening with a tagline blockquote

Replace the current top of `js/ln-dropdown/README.md` (lines 1-6,
from `# ln-dropdown` through the blank line after "Built on top of
`ln-toggle` for open/close state management."):

```markdown
# ln-dropdown

Dropdown menu component — teleports menu to `<body>` for correct stacking, positions relative to trigger, repositions on scroll, closes on outside click or resize.

Built on top of `ln-toggle` for open/close state management.
```

With this new top:

```markdown
# ln-dropdown

> Dropdown menu — wraps an `[data-ln-toggle]` menu, teleports it to
> `<body>` on open, positions relative to the trigger, and closes on
> outside click or viewport resize. Open/close state lives on the
> inner `data-ln-toggle` attribute (managed by `ln-toggle`).

For internal mechanics — teleport flow, positioning algorithm, listener
lifecycle — see [`docs/js/dropdown.md`](../../docs/js/dropdown.md).
```

Verify: file now starts with `# ln-dropdown` then a `>` blockquote
tagline, then a one-line back-link to docs/js, then a blank line,
then `## Attributes`. The standalone "Built on top of `ln-toggle`..."
sentence is gone (absorbed into tagline).

#### Step 2 — README: keep §Attributes table, add ARIA row

The §Attributes table (currently lines 9-14) keeps its 4 rows, but
add a brief mention of the auto-added ARIA. The cleanest place is a
new bullet line directly under the table (NOT a new section, NOT a
new column — keep the table's 3-column shape). Insert these two lines
right AFTER the existing table and BEFORE the `## HTML Pattern`
heading:

```markdown
**Auto-added ARIA**: `aria-haspopup="menu"` and `aria-expanded` on the trigger; `role="menu"` on the menu element; `role="menuitem"` on each direct child of the menu.
```

(One single line of bold-prefixed inline content. Keep tabs for any
indentation, but inline markdown lines have no indentation.)

#### Step 3 — README: keep §HTML Pattern intact

The §HTML Pattern section (currently lines 16-28) shows the canonical
contract with `<div data-ln-dropdown>` → trigger button → `<ul
data-ln-toggle>` → `<li><a>` items. Keep this section unchanged.

#### Step 4 — README: compress §Behavior

Replace the entire `## Behavior` section (currently lines 30-54,
including subsections §Teleport, §Positioning, §Scroll → reposition,
§Resize → close, §Outside click → close) with this compressed
version:

```markdown
## Behavior

- **Teleport** — on open, the menu is moved to `<body>` so it escapes ancestor `overflow: hidden` and stacking contexts; on close it returns to its original DOM position.
- **Positioning** — menu opens below the trigger, right-aligned to it; flips above if there is no room below; flips left-aligned if there is no room on the right. Gap is the `--size-xs` token (override on the menu to tune).
- **Scroll** — while open, the menu repositions on every scroll (including nested scrollable containers) so it tracks the trigger.
- **Resize** — viewport resize closes the menu (layout reflow makes repositioning unreliable).
- **Outside click** — clicking outside the wrapper or the menu closes it.
```

Verify: the five subsection headings (`### Teleport`, `### Positioning`,
etc.) are gone; the section is a flat 5-bullet list of one line each;
the "placeholder comment preserves the original DOM position"
mechanism detail is gone; the 3 positioning bullets are collapsed
into one line.

#### Step 5 — README: keep §Events table and listener example, drop trailing whitespace

§Events (currently lines 56-68) keeps the table and the
`document.addEventListener('ln-dropdown:open', ...)` snippet. No
content change.

#### Step 6 — README: replace §API to use `const` and clarify state control

Replace the current §API section (currently lines 70-75):

```markdown
## API

```javascript
var el = document.querySelector('[data-ln-dropdown]');
el.lnDropdown.destroy();  // cleanup, remove listeners, teleport back
```
```

With:

```markdown
## API

Each `[data-ln-dropdown]` element gets an instance at
`element.lnDropdown`. The dropdown does not have its own
`open()` / `close()` methods — open/close lives on the inner
`[data-ln-toggle]` element. To open or close programmatically,
toggle the `data-ln-toggle` attribute on the menu (or click the
trigger).

```javascript
const el = document.querySelector('[data-ln-dropdown]');
const menu = el.querySelector('[data-ln-toggle]');

// Open / close via attribute on the menu:
menu.setAttribute('data-ln-toggle', 'open');
menu.setAttribute('data-ln-toggle', 'close');

// Cleanup the dropdown instance:
el.lnDropdown.destroy();
```
```

Verify: `var` is gone; `const` is used; the state-control mechanism
(toggle attribute on inner menu) is documented; `destroy()` is
preserved.

#### Step 7 — README: drop §CSS section entirely

Delete the entire `## CSS` section (currently lines 77-96, including
the SCSS code sample and the "See `ln-dropdown.scss` for the default
implementation" line).

After this delete, what was `## Integration with ln-toggle` (currently
line 98) is the next section — but Step 8 removes that too.

#### Step 8 — README: drop §Integration with ln-toggle entirely

Delete the entire `## Integration with ln-toggle` section (currently
lines 98-100). The tagline (Step 1) absorbs the necessary fact.

After this delete, what was `## Dynamic elements` (currently line
102) is the next section — but Step 9 removes that too.

#### Step 9 — README: drop §Dynamic elements entirely

Delete the entire `## Dynamic elements` section (currently lines
102-104). MutationObserver auto-init is universal across the library
and not worth a leaf README section.

After this delete, the README ends after §API. Verify the file ends
cleanly with no trailing orphan heading and exactly one trailing
newline.

#### Step 10 — docs/js: replace the consumer-facing top with a back-link

Replace the entire top portion of `docs/js/dropdown.md` (currently
lines 1-58, from `# Dropdown` through the `---` separator that
precedes `## Internal Architecture`) with this compact opening:

```markdown
# Dropdown

Implementation notes for `ln-dropdown`. The user-facing contract —
attributes, events, API examples — lives in
[`js/ln-dropdown/README.md`](../../js/ln-dropdown/README.md). This
document covers internal mechanics: per-component lifecycle around
the shared `ln-core` helpers (`computePlacement`, `teleportToBody`,
`measureHidden`).

File: `js/ln-dropdown/ln-dropdown.js`
```

Verify: the §HTML, §Attributes, §Events, §API, §Behavior consumer-
facing sections (lines 6-58 of the original file) are gone. The next
heading after the back-link is `## State` (promoted from `### State`
in the next step).

#### Step 11 — docs/js: promote the §Internal Architecture subsections to top-level sections

The current file has `## Internal Architecture` (line 60) with
sub-sections `### State`, `### Teleport + Placement`,
`### Positioning Algorithm`, `### Event Listeners Lifecycle`,
`### Dependency on ln-toggle`, `### MutationObserver`. After Step 10
removed the consumer-facing top, the `## Internal Architecture`
heading is now redundant — the whole file IS internal architecture.

Promote each subsection from `###` to `##` and remove the
`## Internal Architecture` wrapper heading. Specifically:

1. Delete the line `## Internal Architecture` and the blank line
   after it (currently around lines 60-61, but line numbers will have
   shifted after Step 10).
2. Change `### State` → `## State`.
3. Change `### Teleport + Placement (delegated to ln-core)` →
   `## Teleport + Placement (delegated to ln-core)`.
4. Change `### Positioning Algorithm` → `## Positioning Algorithm`.
5. Change `### Event Listeners Lifecycle` → `## Event Listeners Lifecycle`.
6. Change `### Dependency on ln-toggle` → `## Dependency on ln-toggle`.
7. Change `### MutationObserver` → `## MutationObserver`.

The body content of each section stays unchanged at this step.

#### Step 12 — docs/js: trim §Dependency on ln-toggle

In the now-promoted `## Dependency on ln-toggle` section, the body is
currently:

```
Dropdown does not manage open/close state itself. It listens to
`ln-toggle:open` and `ln-toggle:close` events from the inner toggle
element. The toggle's `data-ln-toggle` attribute remains the single
source of truth for the menu's open/closed state.
```

Replace with this 2-sentence version:

```
Dropdown does not manage open/close state. It listens for
`ln-toggle:open` and `ln-toggle:close` on the inner
`[data-ln-toggle]` element and runs its teleport / positioning /
listener-lifecycle steps in response.
```

The "single source of truth" phrasing is dropped — the README
tagline owns that fact now.

#### Step 13 — Verify acceptance criteria

Run the negative checks (greps must produce no matches):

```
grep -n "## CSS" js/ln-dropdown/README.md
grep -n "## Integration with ln-toggle" js/ln-dropdown/README.md
grep -n "## Dynamic elements" js/ln-dropdown/README.md
grep -n "## HTML" docs/js/dropdown.md
grep -n "## Behavior" docs/js/dropdown.md
grep -nE "^## API$" docs/js/dropdown.md
grep -nE "^## Events$" docs/js/dropdown.md
grep -n "Shadow DOM, iframe only" docs/js/dropdown.md
grep -n "ln-popover" js/ln-dropdown/README.md docs/js/dropdown.md
grep -n "var el = " js/ln-dropdown/README.md
grep -n "placeholder comment preserves" js/ln-dropdown/README.md
```

All eleven must produce no matches.

Run the positive checks:

```
head -8 js/ln-dropdown/README.md
grep -n "^## Attributes" js/ln-dropdown/README.md
grep -n "^## HTML Pattern" js/ln-dropdown/README.md
grep -n "^## Behavior" js/ln-dropdown/README.md
grep -n "^## Events" js/ln-dropdown/README.md
grep -n "^## API" js/ln-dropdown/README.md
grep -n "role=\"menu\"" js/ln-dropdown/README.md
grep -n "aria-haspopup" js/ln-dropdown/README.md
grep -n "aria-expanded" js/ln-dropdown/README.md
grep -n "^## State" docs/js/dropdown.md
grep -n "^## Teleport" docs/js/dropdown.md
grep -n "^## Positioning" docs/js/dropdown.md
grep -n "^## Event Listeners Lifecycle" docs/js/dropdown.md
grep -n "^## Dependency on ln-toggle" docs/js/dropdown.md
grep -n "^## MutationObserver" docs/js/dropdown.md
grep -n "computePlacement\|teleportToBody\|measureHidden" docs/js/dropdown.md
grep -n "README.md" docs/js/dropdown.md
```

`head -8 js/ln-dropdown/README.md` must show:
- `# ln-dropdown` on line 1
- A `>` blockquote tagline starting around line 3
- A back-link mentioning `docs/js/dropdown.md` near the top

All other greps should produce at least one match (the section
heading greps should produce exactly one match; the helper-name grep
should produce at least 3 matches; the back-link grep at least one).

Line counts:

```
wc -l < js/ln-dropdown/README.md   # expect ≤ 90 (target ~75-85)
wc -l < docs/js/dropdown.md        # expect ≤ 110 (target ~90-100)
```

Source untouched:

```
git diff --name-only js/ln-dropdown/ln-dropdown.js
git diff --name-only js/ln-dropdown/ln-dropdown.scss
git diff --name-only demo/admin/dropdown.html
```

All three must produce empty output.

### Acceptance criteria — summary

- All 11 negative greps from Step 13 produce no matches.
- All positive greps from Step 13 produce the expected match counts
  (or the head check shows the new tagline structure).
- `wc -l` for both files at or below the targets (≤90 / ≤110).
- `js/ln-dropdown/ln-dropdown.js`, `js/ln-dropdown/ln-dropdown.scss`,
  and `demo/admin/dropdown.html` are byte-identical to their
  pre-edit state.

### Boundaries — what NOT to touch

- `js/ln-dropdown/ln-dropdown.js` — read-only.
- `js/ln-dropdown/ln-dropdown.scss` — out of scope.
- `demo/admin/dropdown.html` — out of scope (don't even read it
  beyond the prerequisites; spot-check the README HTML example
  matches if confused).
- `js/ln-core/positioning.js` — out of scope (this is where
  `computePlacement`, `teleportToBody`, `measureHidden` live; both
  docs reference them by name only and that's correct).
- The HTML example inside README §HTML Pattern — do NOT modify the
  structure, attributes, or item content. This is the canonical
  reference shape.
- §Events table in the README — keep all three rows; do not rename
  events, do not change Bubbles / Cancelable / Detail columns.
- §State, §Teleport + Placement, §Positioning Algorithm, §Event
  Listeners Lifecycle, §MutationObserver in `docs/js/dropdown.md` —
  these are the load-bearing architecture content. Do not modify
  the body content beyond what Steps 11-12 explicitly call for
  (heading promotion + §Dependency on ln-toggle 2-sentence trim).

### Notes for executor

- This is mechanical doc work: section deletions, tagline insertion,
  one §Behavior compression, one §API rewrite, heading promotion in
  docs/js, one §Dependency on ln-toggle trim. No build, no test, no
  architectural decisions.
- When deleting a section, remove the heading and everything under
  it through to the line immediately before the next `##` heading,
  preserving exactly one blank line before the next heading (or
  exactly one trailing newline at end of file).
- After all edits, re-read both files top-to-bottom once. Look for
  orphan headings, double blank lines, broken markdown tables, and
  references to deleted sections (e.g. "see §Integration with
  ln-toggle"). The README ends after §API; the docs/js ends after
  §MutationObserver.
- If line-count target is unreachable while respecting boundaries,
  report the discrepancy — that is a plan estimation error per
  skill §Benchmarks, not a discipline failure.
