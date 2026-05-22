# ln-ashlar Doctrine

> **Read this first, every time you write SCSS or HTML for an ln-ashlar consumer.**
> Rules are ordered by how much damage breaking them does, not by topic.

---

## The 3 rules that prevent 80% of mistakes

### Rule 1 — Mixin bodies read PRIMITIVES, never scale tokens

ln-ashlar has a 3-layer token system:

```
Scale         →  --size-*, --color-neutral-*, --shadow-sm/md/xl
                 (back-end plumbing — NEVER read in mixin body)
   ↓ wired at :root
Vocabulary    →  --bg-base, --fg-default, --border-subtle, --shadow-resting
                 (named value choices — themes rebind these)
   ↓ wired at :root
Primitives    →  --color-bg, --color-fg, --color-border, --shadow,
                 --padding-x, --padding-y, --gap, --radius
                 (what mixin bodies read)
```

**Mixin bodies read primitives. Components rebind primitives on their own scope to choose a vocabulary value. Themes rebind vocabulary at theme `:root`.**

```scss
// RIGHT — mixin reads primitives, component rebinds primitive to vocabulary
@mixin card {
    padding: var(--padding-y) var(--padding-x);
    background: var(--color-bg);
    color: var(--color-fg);
    border: var(--border-width) solid var(--color-border);
    border-radius: var(--radius);
    box-shadow: var(--shadow);
}

@mixin floating-panel {
    --color-bg:     var(--bg-elevated);   // rebind primitive on own scope
    --color-border: var(--border-subtle);
    --shadow:       var(--shadow-floating);
    background: var(--color-bg);          // read primitive
}

// WRONG — mixin reaches through to scale or vocabulary directly
@mixin card {
    padding: var(--size-xs-up) var(--size-md-up);              // scale
    background: hsl(var(--color-bg-primary));                    // old alias
    border: 1px solid hsl(var(--color-neutral-200));             // scale + literal
    box-shadow: var(--shadow-sm);                                 // scale
}
```

**Why:** the primitives are the only stable contract. Themes flip vocabulary; density-compact rebinds scale. If a mixin reads scale directly, theme/density changes break the mixin. If it reads primitives, everything cascades automatically.

### Rule 2 — Every visual pattern has TWO layers: mixin + component

```
scss/config/mixins/_card.scss     →  @mixin card { ... }       ← recipe (no CSS output)
scss/components/_card.scss        →  .card { @include card; }  ← applied default (CSS output)
```

Never blur them. A mixin defines HOW. A component applies WHERE.

When adding a new visual pattern:
1. Mixin file `scss/config/mixins/_<name>.scss`
2. Register in `scss/config/mixins/_index.scss` with `@forward '<name>'`
3. Component file `scss/components/_<name>.scss` applying mixin to default selector
4. Add `@use 'components/<name>'` to `scss/ln-ashlar.scss`

**Why:** projects consume mixins on their own semantic selectors. If the recipe is locked inside a component CSS block, projects cannot reuse it without copy-paste. Two layers means one source of truth + flexible application.

### Rule 3 — Semantic selectors in HTML, `@include` in SCSS

Production HTML never carries presentational classes. The selector describes WHAT the element is; the mixin describes HOW it looks.

```html
<!-- RIGHT -->
<table id="audit-log">
  <thead>...</thead>
  <tbody>...</tbody>
</table>

<!-- WRONG — Tailwind reflex -->
<table class="table table-striped table-bordered w-full">
  ...
</table>
```

```scss
// RIGHT — project SCSS
#audit-log {
    @include table-base;
    @include table-striped;
}

// WRONG — using class in HTML and styling the class
.table-striped { ... }
```

**Exceptions:** `.btn`, `.card`, `.btn-group` etc. exist as **prototype-tier** classes for inspector experimentation. Production code always uses semantic selectors.

**Why:** semantic selectors decouple structure from style. Tomorrow `#audit-log` may need a different style — change the project SCSS, not the HTML. Markup describes meaning, not appearance.

---

## Semantic markup rules

These rules govern **what HTML you write**, before any styling decisions. They are non-negotiable — visual appearance follows markup, not the reverse.

### S1 — Markup describes WHAT, not HOW

The element type is a structural decision, independent of styling. A checkbox is a checkbox even when it looks like a pill. A radio is a radio even when it looks like a tab. Custom styling sits on top of standard form elements; it never replaces them.

```html
<!-- RIGHT — pill-style filter is still a checkbox -->
<fieldset>
    <legend>Status</legend>
    <ul>
        <li><label><input type="checkbox" data-ln-filter-key="status" data-ln-filter-value="active"> Active</label></li>
        <li><label><input type="checkbox" data-ln-filter-key="status" data-ln-filter-value="archived"> Archived</label></li>
    </ul>
</fieldset>

<!-- WRONG — "looks like" pills, so markup pretends they're list items with state -->
<ul>
    <li data-active="true">Active</li>
    <li>Archived</li>
</ul>
```

**Why:** keyboard navigation, screen readers, form submission, browser autofill, native `:checked` styling, and `<form>` reset all depend on real form elements. Faking the semantics breaks accessibility and reinvents browser functionality badly. Styling is cheap; rebuilding form semantics is not.

### S2 — Multiple elements of the same type → always `<ul>`/`<ol>` with `<li>`

Whenever two or more elements of the same type sit side by side, they are a list. Wrap them. No exceptions for "it doesn't look like a list" — list-ness is structural, not visual.

```html
<!-- Filter checkboxes -->
<ul>
    <li><label><input type="checkbox" ...> Admin</label></li>
    <li><label><input type="checkbox" ...> Editor</label></li>
</ul>

<!-- Button group / row actions -->
<ul>
    <li><button type="button">Edit</button></li>
    <li><button type="button">Delete</button></li>
</ul>

<!-- Error messages under an input -->
<ul data-ln-errors>
    <li>Email must be valid</li>
</ul>

<!-- Navigation -->
<nav>
    <ul>
        <li><a href="/users">Users</a></li>
        <li><a href="/roles">Roles</a></li>
    </ul>
</nav>

<!-- Tabs (still a list of buttons) -->
<ul role="tablist">
    <li><button role="tab">Overview</button></li>
    <li><button role="tab">Activity</button></li>
</ul>
```

This is why ln-ashlar mixins target `ul` directly:

```scss
#users td:last-child ul { @include btn-group; }     // row actions
#role-filter ul         { @include pill-group; }    // filter checkboxes
nav > ul                { @include nav-horizontal; }
```

The selector ends on `ul` because the markup ends on `ul`. No `.btn-group`, no `.filter-list` — the structural element carries the semantics.

**Why:** screen readers announce list length ("list with 5 items"). Keyboard users get list-navigation affordances. CSS gets a clean structural anchor (`ul > li > button`) without needing classes. And consistency across projects: every group is a list, period.

### S3 — Form validation: error list lives in the markup, always

Every form input that can produce a validation error has an empty error list directly after it. The list exists in the markup even when there are no errors — it is part of the input's structural envelope, not something added dynamically.

```html
<label>
    Email
    <input type="email" name="email" required>
    <ul data-ln-errors></ul>
</label>

<label>
    Password
    <input type="password" name="password" required minlength="8">
    <ul data-ln-errors></ul>
</label>
```

CSS reserves space (via `min-height` or a single-line ghost) so the layout does not jump when an error appears. JS populates `<li>` entries when validation fails.

**Only one error is shown at a time, even when validation produces several.** The user fixes one problem at a time; the layout does not grow vertically to display three simultaneous errors. Show the highest-priority error and hide the rest until the first is resolved.

```scss
[data-ln-errors] li:not(:first-child) { display: none; }
```

**Why:** stable layout is a usability requirement, not a polish detail. Inputs that grow and shrink as the user types create motion sickness. Reserving space and capping visible errors keeps the form predictable. One error at a time matches how users actually fix forms — sequentially, not in parallel.

### S4 — Override at the highest level the rule applies to

When a project needs to deviate from an ln-ashlar default, write the override on the **root selector** for the element type, not on a scoped descendant — unless the deviation is genuinely scoped.

```scss
// RIGHT — project-wide button accent shift
button { --color-primary: var(--color-brand); }

// RIGHT — only the delete action in user list is destructive
#user-list button[data-action="delete"] { --color-primary: var(--color-error); }

// WRONG — same rule copied across scopes
#user-list button  { --color-primary: var(--color-brand); }
#audit-log button  { --color-primary: var(--color-brand); }
#settings button   { --color-primary: var(--color-brand); }
```

The mental check: "is this how buttons (or inputs, or tables, or forms) look **in this project**, or is this a genuine local exception?" Project-wide rules go on the bare element selector. Local exceptions get an `#id` or attribute scope.

This applies to every element: `button`, `input`, `select`, `textarea`, `table`, `form`, `ul`, `nav`, `header`, `footer`, `dialog`, etc.

**Why:** copying the same rule across three IDs is anti-DRY by definition. It also fragments the source of truth — next month someone changes two of three and the third becomes silently inconsistent. Cascade is the language CSS speaks; root-level overrides are how you speak it fluently.

### S5 — Filter pattern: single philosophy across components

Both `ln-filter` (filtering DOM elements) and `ln-data-table` (filtering data-driven events) must follow the exact same checkbox interaction and state model:

- **"All" sentinel checkbox** at the top (`data-ln-filter-reset`), checked by default.
- **Checking a specific value checkbox** deselects "All".
- **Unchecking all value checkboxes** (or checking "All") clears the filter and re-checks "All".
- **"All" cannot be unchecked directly** — clicking "All" when it's already checked keeps it checked and clears any active value checkboxes.
- **Never "all values checked"** — that state is represented by "All" checked and all values unchecked.

**Why:** A unified filter philosophy ensures a predictable and consistent user experience throughout the entire ecosystem. Users don't have to relearn how column-level filters work compared to list filters. It also reduces logic complexity by eliminating the "all values checked = clear filter" state, aligning both components' event payloads on `values: []` for clear/unfiltered.

---

## Anti-patterns from Tailwind reflex

These are the patterns Claude (and Tailwind-trained humans) reach for instinctively. Each one has a ln-ashlar equivalent.

| Tailwind reflex | ln-ashlar way |
| --- | --- |
| `<div class="grid grid-cols-3 gap-4">` | `#x { @include grid-auto(280px); gap: var(--size-md); }` |
| `<button class="bg-blue-500 text-white px-4 py-2 rounded">` | `<button type="submit">` (auto primary) or `#x { @include btn; }` |
| `<button class="btn btn-primary">` | `<button type="submit">` — never BEM variants |
| `<button class="btn btn-danger">` | `#delete-x { @include btn; --color-primary: var(--color-error); }` |
| `class="text-gray-500"` | rebind `--color-fg: var(--fg-muted)` on the scope |
| `class="bg-gray-50"` | rebind `--color-bg: var(--bg-sunken)` on the scope |
| `class="shadow-md"` | rebind `--shadow: var(--shadow-floating)` on the scope |
| `@media (min-width: 768px)` for a component | `@include cq-up(medium, my-component)` |
| `@media (min-width: 768px)` for app shell | `@include mq-up(md)` |
| `class="md:grid-cols-2 lg:grid-cols-3"` | `grid-auto($min)` with container query refinement |
| `class="hover:bg-blue-600"` | mixin handles `&:hover` via `*-hover` companion tokens |

**The mental flip:** in Tailwind you compose utilities in HTML. In ln-ashlar you compose mixins in SCSS, on selectors that describe the element. The HTML stays semantic and stable; styling lives in one SCSS file per page or feature.

---

## A. Architecture rules

### A1 — No per-component tokens

```scss
// WRONG
:root {
    --btn-py: 0.5rem;
    --card-padding: 1rem;
    --modal-gap: 1.5rem;
}

// RIGHT — rebind shared primitives on the component scope
@mixin btn {
    --padding-y: var(--size-xs);
    --padding-x: var(--size-md);
    padding: var(--padding-y) var(--padding-x);
}

@mixin card {
    --padding-y: var(--size-md);
    --padding-x: var(--size-md-up);
    padding: var(--padding-y) var(--padding-x);
}
```

**Why:** per-component tokens at `:root` defeat the scale. Changing `--size-md` no longer cascades to the card if `--card-padding: 1rem` is frozen at `:root`. Rebinding the SHARED primitive on the component scope means density-compact, theme, and parent overrides all still work.

### A2 — Variants rebind the surface, don't redeclare properties

When a base mixin reads from a `--component-*` token surface (e.g. `@mixin button-base` reads `--btn-bg` / `--btn-fg` / `--btn-border` plus `-hover` companions), a variant of that base **rebinds those tokens**. It does NOT declare `background:` / `color:` / `border-color:` directly, and does NOT duplicate `&:hover` / `&:active` blocks.

```scss
// RIGHT — variant rebinds the surface tokens
@mixin btn {
    --color-accent:       hsl(var(--color-primary));
    --color-accent-hover: hsl(from var(--color-accent) h s calc(l - 8));

    --btn-bg:           var(--color-accent);
    --btn-fg:           var(--color-accent-fg);
    --btn-border:       var(--color-accent);
    --btn-bg-hover:     var(--color-accent-hover);
    --btn-fg-hover:     var(--color-accent-fg);
    --btn-border-hover: var(--color-accent-hover);
    @include button-base;
}

// WRONG — variant bypasses surface, duplicates base behavior
@mixin btn {
    background: var(--color-accent);
    color: var(--color-accent-fg);
    border-color: var(--color-accent);
    &:hover:not(:disabled) {
        background: var(--color-accent-hover);
        // duplicates base behavior — fragile
    }
}
```

**Why:** the base mixin already owns the hover/active/focus contract. Duplicating it means every base change needs a parallel variant change. Token rebind inherits all base behavior automatically.

### A3 — Themes rebind vocabulary at `:root`, never via descendant selectors

```scss
// RIGHT — vocabulary rebind at theme :root
[data-theme="dark"] {
    --bg-base:     hsl(220 16% 13%);
    --bg-elevated: hsl(220 16% 17%);
    --fg-default:  hsl(0 0% 95%);
    --border-subtle: hsl(220 14% 20%);
}

// WRONG — descendant selector at higher specificity
[data-theme="dark"] .btn {
    background: hsl(220 16% 13%);
    color: white;
    border-color: hsl(220 14% 20%);
}
```

**Why:** the WRONG form wins via 0,2,0 specificity over the library's `.btn` (0,1,0). That locks the theme into redeclaring everything. Vocabulary rebind at `:root` lets the library own structure; the theme just shifts the palette.

### A4 — Grep before claiming

Before recommending an architecture, refactor, or claiming that a behavior / method / event exists, run a cross-component `grep` first. Trust the code, not the mental model of "what the canonical shape should be."

**Mental shorthand:** claim → grep → propose. Never claim → propose → discover-too-late.

Real failures from past sessions, each a 2-second grep away:
- Recommended coordinator-driven sort while `ln-store._sort` already existed.
- Claimed `ln-form:success` / `ln-form:error` existed — only `ln-form:submit` does.
- Suggested `document.querySelectorAll` for runtime fan-out — direct violation of "no post-init DOM scans."

---

## B. Button & modal rules

### B1 — `<button>` is styled by structure + type, not class

Every `<button>` gets full structure and neutral colors from `scss/base/_global.scss` automatically. No class needed for cancel/close/toggle/icon buttons.

```html
<!-- Cancel: neutral from global, no class -->
<button type="button">Cancel</button>

<!-- Save: primary from type="submit", no class -->
<button type="submit">Save</button>

<!-- Action button that isn't a form submit: @include btn on semantic selector -->
<button id="export-data">Export</button>
```

```scss
#export-data { @include btn; }
#delete-user { @include btn; --color-primary: var(--color-error); }
```

### B2 — No `translateY`, no hover `box-shadow` on buttons

Color change only. This is a non-negotiable design decision.

```scss
// WRONG
&:hover { transform: translateY(-1px); box-shadow: 0 4px 8px rgba(0,0,0,0.1); }
&:active { transform: translateY(0); }

// RIGHT — color shift via *-hover tokens
&:hover:not(:disabled) {
    background: var(--btn-bg-hover);
    color: var(--btn-fg-hover);
    border-color: var(--btn-border-hover);
}
```

### B3 — No BEM variant classes

Never `btn--primary`, `btn--danger`, `card--featured`. Override the primary token instead.

```scss
// WRONG
.btn--danger { @include btn; --color-primary: var(--color-error); }

// RIGHT — override at the consumer
#delete-user { @include btn; --color-primary: var(--color-error); }
// or on a parent:
.danger-zone { --color-primary: var(--color-error); }
```

### B4 — Modal: `<form>` is the content root

```html
<button data-ln-modal-for="my-modal">Open</button>

<div class="ln-modal" data-ln-modal id="my-modal">
    <form>
        <header>
            <h3>Title</h3>
            <button type="button" aria-label="Close" data-ln-modal-close>
                <svg class="ln-icon" aria-hidden="true"><use href="#ln-x"></use></svg>
            </button>
        </header>
        <main>...</main>
        <footer>
            <button type="button" data-ln-modal-close>Cancel</button>
            <button type="submit">Save</button>
        </footer>
    </form>
</div>
```

Rules:
- `<form>` is the root — no wrapper `<div>`, no BEM
- `data-ln-modal` attribute = single source of truth for state (`"open"` / `"close"`)
- `data-ln-modal-for="id"` on trigger button
- Size via mixins: `#my-modal > form { @include modal-lg; }` — not classes
- Cancel buttons need `type="button"` to prevent form submission

### B5 — Button groups vs pill groups

Two distinct grouping patterns. Don't confuse them.

- **`@include btn-group`** — action buttons with small gap (toolbars, table row actions)
- **`@include pill-group`** — joined pills without gap (radio/checkbox replacements)

```scss
#users td:last-child ul { @include btn-group; }   // edit/delete icons
#role-filter ul         { @include pill-group; }  // Admin | Editor | Viewer
```

For pill-group, use `@include pill-outline` on the parent if you want bordered + visible inputs instead of filled-default.

---

## C. Spacing, sizing & color rules

### C1 — No raw `px` or `rem` in spacing contexts

All spacing (padding, margin, gap, inset, positional offsets used for layout) reads `--size-*` via primitives. The scale is 12 steps:

```
0  <  2xs  <  xs  <  xs-up  <  sm  <  sm-up  <  md  <  md-up  <  lg  <  xl  <  2xl  <  3xl
```

```scss
// RIGHT
@mixin section {
    --margin-block: var(--size-xl);
    --padding-y: var(--size-md);
    padding-block: var(--padding-y);
    margin-bottom: var(--margin-block);
}

// WRONG
@mixin section {
    padding: 1rem 0;        // raw literal
    margin-bottom: 24px;    // raw literal
}
```

**Allowed exceptions** (these are intrinsic geometry, not spacing rhythm):
- `0` as unitless zero (or `var(--size-0)` for clarity)
- `1px` / `2px` borders → `--border-width` / `--border-width-strong`
- Intrinsic: `100%`, `100vh`, `auto`, `1fr`, `50%`, `9999px` for full radius
- Icon sizes, avatar sizes, toggle geometry, modal max-widths, toast widths — component-intrinsic dimensions
- Font sizes use their own scale (`--text-*`, `--lh-*`, `--tracking-*`)
- Geometric component math (connector endpoints, bullet alignment) — comment required: `// Geometric — <intent>, not spacing rhythm.`

### C2 — Zero hardcoded colors. Ever.

Every color reads from a token. No `#hex`, no `rgb()`, no `hsl(...)` literals in component code.

```scss
// WRONG
background: #1e3a8a;
color: rgb(255, 255, 255);
border-color: hsl(220 20% 90%);

// RIGHT
background: var(--color-bg);          // primitive (mixin body)
color: var(--color-fg);
border-color: var(--color-border);

// Or rebind first:
--color-bg: var(--bg-elevated);       // (component scope)
background: var(--color-bg);
```

Token values that contain raw HSL channels (e.g. `--color-primary: 232 75% 48%`) live in `_tokens.scss` and `_theme.scss` only. Mixin bodies wrap them: `hsl(var(--color-primary))`.

### C3 — Density-compact must be respected

When extending `--size-*`, every addition MUST be mirrored in `scss/config/_density.scss` under `.density-compact` with a value that preserves ascending order across the whole scale.

```scss
// _tokens.scss
:root {
    --size-md: 1rem;
    --size-md-up: 1.25rem;
    --size-lg: 1.5rem;
}

// _density.scss — values shrunk but order preserved
.density-compact {
    --size-md: 0.75rem;
    --size-md-up: 0.875rem;  // still > md, still < lg
    --size-lg: 1rem;
}
```

Inversion (e.g. `md-up: 1.25rem` while `lg: 1rem` in compact) breaks any component that uses both adjacent steps.

### C4 — Mixins read 4 surface primitives

For surface styling, mixins read exactly these four:

- `--color-bg` — element surface (default: `var(--bg-base)`)
- `--color-fg` — text color (default: `var(--fg-default)`)
- `--color-border` — border color (default: `var(--border-subtle)`)
- `--shadow` — box shadow (default: `var(--shadow-resting)`)

Plus accent for emphasis: `--color-accent`, `--color-accent-hover`, `--color-accent-fg`, `--color-accent-tint*`.

Components rebind these on their own scope to select a different vocabulary value.

---

## D. Responsive rules

### D1 — Container queries for components, media queries for app shell

```scss
// RIGHT — component reusable inside sidebar, main, modal, card
@mixin page-header {
    container-type: inline-size;
    container-name: page-header;

    display: flex; flex-direction: column;
    @include cq-up(medium, page-header) {
        flex-direction: row;
    }
}

// RIGHT — app shell coupled to viewport geometry
.app-shell {
    display: grid;
    grid-template-columns: 1fr;
    @include mq-up(md) {
        grid-template-columns: 240px 1fr;
    }
}

// WRONG — viewport media query for a reusable component
@mixin page-header {
    @media (min-width: 768px) { flex-direction: row; }
}
```

**Why container queries for components:** the same `page-header` component drops into a 1200px main column and a 400px modal. Viewport media query thinks the screen is wide; container query knows the parent is narrow.

### D2 — Never hardcode breakpoint pixels

```scss
// WRONG
@media (min-width: 768px) { ... }
@container page-header (min-width: 880px) { ... }

// RIGHT
@include mq-up(md) { ... }
@include cq-up(medium, page-header) { ... }
@include cq-down(compact) { ... }   // anonymous container
```

Breakpoint names live in `$breakpoints` map in `scss/config/_breakpoints.scss`. New breakpoint? Extend the map; never silo a literal.

**Allowed raw `@media`:**
- `prefers-color-scheme` in `_theme.scss` — OS-level, not a breakpoint
- `prefers-reduced-motion` — OS-level, not a breakpoint

### D3 — Container registration is the mixin's job

A mixin that uses `cq-*` internally must declare `container-type: inline-size` (and `container-name: <name>` if not anonymous) on the selector it styles. Consumer should not register containers manually.

---

## E. Theme & state rules

### E1 — Vocabulary rebind, not structural override

See A3. Themes change palette via token rebind at theme `:root`. No descendant selectors. No duplicate hover/active blocks.

### E2 — Companion tokens for theme-shift-able properties

When a property must differ between themes but no logical token exposes it, ADD the missing token with a fallback pattern in the consumer mixin. Do not escalate specificity.

```scss
// @mixin btn — reads via fallback so default theme stays solid
--btn-bg: var(--color-accent-bg, var(--color-accent));
--btn-fg: var(--color-accent-bg-fg, var(--color-accent-fg));

// Default theme — no companion override; mixin falls back to solid accent.
// Glass theme — rebinds the -bg-* companions at theme :root.
```

The fallback pattern makes theme overrides transparent. Don't introduce per-component-surface companions (`--btn-accent-*`) at `:root` — those freeze and break the semantic-color cascade.

### E3 — Solid vs translucent accent surfaces have separate fg tokens

- **Solid:** `--color-accent` + `--color-accent-fg` — used by toast-side, pill checked, stepper active, btn under default theme. fg = white.
- **Translucent:** `--color-accent-bg` + `--color-accent-bg-fg` — used by btn under themes that opt in. fg flips to match accent for legibility.

Themes that introduce the translucent variant rebind `-bg-*` companions ONLY. Don't conflate them — setting `--color-accent-fg: var(--color-primary)` at theme `:root` collapses toast/pill/stepper text to invisible primary-on-primary.

---

## F. Working mode (Claude's behavior)

### F1 — Think first, then push back

When the user shares plans, specs, or asks architectural questions: don't immediately execute.

1. **Analyze** what's being proposed. Look for gaps, contradictions, missing edge cases, better alternatives.
2. **Push back** if something is wrong or suboptimal. Don't agree just because the user said it.
3. **Reference existing decisions** — check skills and specs before answering. If `data-table.md` says "no pagination, virtual scroll", don't suggest pagination.
4. **Ask before building** if the request is ambiguous.

This applies to architecture discussions and spec reviews. For implementation tasks ("fix this bug", "create this file"), execute directly.

### F2 — Explain approach before substantial work

For new mixins, new components, new patterns, or architectural changes: present the approach **before writing any code**.

- **SCSS:** "Create `@mixin X` in `scss/config/mixins/`, apply in `scss/components/` on `[selector]`, project uses `@include X` on `#element`"
- **JS:** "Component uses `data-ln-X` on `<element>`, dispatches event Y, project wires via Z"
- **HTML:** "Structure is `<parent> > <child>`, component X on `<element>`, styled via mixin Y"

Cover all layers touched. Wait for confirmation before executing. Doesn't apply to trivial fixes.

### F3 — Auto-mode bias is toward skip-grep — resist it

Auto mode biases toward "action over planning." That bias makes skip-grep MORE likely, not less. The rule is strictest in auto mode — discovery is part of the action, not a separate planning step.

---

## Quick "before writing code" checklist

Before pasting an SCSS or HTML proposal in chat, verify:

- [ ] Did I grep the library for existing patterns/components matching this need?
- [ ] Am I reading primitives in mixin bodies (`--color-bg`, `--padding-y`, `--gap`), not scale tokens (`--size-md`, `--color-neutral-100`)?
- [ ] Is the pattern split into mixin (recipe) + component (applied default), not blurred?
- [ ] Does the HTML use a semantic selector (`#audit-log`, `[data-ln-modal]`), not utility classes?
- [ ] Are there raw `px` / `rem` outside the allowed exception list?
- [ ] Are there hardcoded hex/rgb/hsl colors anywhere?
- [ ] For responsive: container query for component, media query only if app shell?
- [ ] For variants: does it rebind surface tokens, or duplicate base properties?
- [ ] For themes: vocabulary rebind at `:root`, or descendant override?
- [ ] For substantial work: did I explain the approach before writing code?

If any box is unchecked, stop and either fix or ask.

---

## Reference cards

### The 4 primitive surface tokens
```
--color-bg, --color-fg, --color-border, --shadow
```

### The 4 primitive structure tokens
```
--padding-x, --padding-y, --gap, --radius
```

### The 4 vocabulary background tokens
```
--bg-base, --bg-elevated, --bg-sunken, --bg-recessed
```

### The 3 vocabulary foreground tokens
```
--fg-default, --fg-muted, --fg-subtle
```

### The 3 vocabulary border tokens
```
--border-subtle, --border-strong, --border-strong-hover
```

### The 3 vocabulary shadow tokens
```
--shadow-resting, --shadow-floating, --shadow-overlay
```

### Spacing scale (12 steps)
```
0  <  2xs  <  xs  <  xs-up  <  sm  <  sm-up  <  md  <  md-up  <  lg  <  xl  <  2xl  <  3xl
```

### Breakpoint mixins
```
@include mq-up(sm|md|lg|xl|2xl)        // viewport, app shell only
@include cq-up(narrow|compact|medium|wide, <name>)   // container, components
@include cq-down(narrow|compact|medium|wide, <name>)
```
