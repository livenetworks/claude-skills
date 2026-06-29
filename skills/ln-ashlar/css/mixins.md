# ln-ashlar — Mixin Reference

> Complete list of available SCSS mixins. For full signatures → `docs/css/mixins.md`.

---

## Usage

```scss
@use 'ln-ashlar/scss/config/mixins' as *;

// Apply mixin to semantic selector
#add-user { @include btn; }
```

---

## Spacing

`p()`, `px()`, `py()`, `pt()`, `pb()`, `pl()`, `pr()`, `m()`, `mx()`, `my()`, `mt()`, `mb()`, `ml()`, `mr()`, `gap()`

```scss
#card { @include p(var(--size-md)); }
#card header { @include px(var(--size-lg)); @include py(var(--size-md)); }
```

## Display & Flex

`flex`, `inline-flex`, `block`, `inline-block`, `hidden`, `flex-col`, `flex-row`, `flex-wrap`, `flex-1`, `flex-shrink-0`, `items-center`, `items-start`, `items-end`, `justify-center`, `justify-between`, `justify-end`, `flex-center`

## Sizing

`w-full`, `h-full`, `min-h-screen`, `w()`, `h()`, `size()`

## Typography

`text-xs`, `text-sm`, `text-base`, `text-lg`, `text-xl`, `text-2xl`, `font-normal`, `font-medium`, `font-semibold`, `font-bold`, `text-left`, `text-center`, `text-right`, `uppercase`, `lowercase`, `capitalize`, `normal-case`, `truncate`, `whitespace-nowrap`, `font-mono`, `font-sans`, `tracking-tight`, `tracking-normal`, `tracking-wide`, `tracking-wider`

### `typography($role)` — semantic role mixin (v1.1) — canonical primitive rebind

**Doctrine:** This is the ONLY way mixins set `font-size`/`line-height`. It rebinds
the `--font-size`/`--line-height` PRIMITIVES at the consuming element's scope, then reads
them — mirror of how `@mixin card` rebinds `--color-bg`. The `--text-{role}`/`--lh-{role}`
tokens are VOCABULARY (density + themes rebind them); mixins never read them directly.

Valid roles: `display-lg`, `display-md`, `display-sm`, `heading-lg`, `heading-md`, `heading-sm`, `title-md`, `title-sm`, `body-lg`, `body-md`, `body-sm`, `label-md`, `label-sm`, `caption`.

```scss
// RIGHT — rebinds --font-size/--line-height at the element's scope
h1 { @include typography(heading-lg); }
.caption { @include typography(caption); }

// WRONG — reads vocabulary directly (frozen if density does not rebind that role)
.caption { font-size: var(--text-caption); }
```

Prefer `typography($role)` over raw `text-*` mixins for all role-based typography in mixins. The raw size mixins (`text-sm`, etc.) remain valid for one-off adjustments outside density-reactive contexts.

## Colors

`text-primary`, `text-white`, `text-error`, `text-success`, `text-warning`, `bg-primary`

For muted/secondary text or sunken/recessed backgrounds, rebind the
primitive on the component scope rather than using a dedicated mixin:

```scss
// Muted text
.my-label { --color-fg: var(--fg-muted); color: var(--color-fg); }

// Sunken background (panel header, thead)
.my-header { --color-bg: var(--bg-sunken); background: var(--color-bg); }
```

## Border & Radius

`border`, `border-t`, `border-b`, `border-l`, `border-r`, `border-none`, `rounded-sm`, `rounded-md`, `rounded-lg`, `rounded-xl`, `rounded-full`

### Per-side soft tokens for joining

For "joined panels with a single shared rule" patterns, override one
of the four soft tokens on a parent scope:

- `--border-block-start`
- `--border-block-end`
- `--border-inline-start`
- `--border-inline-end`

These tokens have NO `:root` default. Migrated mixins (`card`,
`section-card`, `floating-panel`, `stat-card`, `app-header`,
`app-footer`, accordion items, page-header, table headers/cells,
etc.) read them with their existing border as fallback, so default
rendering is unchanged.

Example — flatten the top edge of every panel after the first:

```scss
.flat-stack > * + * { --border-block-start: none; }
```

Combined with `--radius: 0` on the same scope, this produces the
flat-shared-rule industrial card stack. See `@mixin flat-stack` which
encapsulates this pattern — including `--radius: 0`, `--shadow: none`,
and `--gap: 0` re-binds — as a self-contained mixin. See `docs/css/layout.md`.

## Shadow

`shadow-none`, `shadow-xs`, `shadow-sm`, `shadow-md`, `shadow-lg`, `shadow-xl`

## Transition

`transition`, `transition-fast`, `transition-colors`

```scss
@include transition;         // all 200ms ease — general purpose
@include transition-fast;    // all 150ms ease — micro-interactions
@include transition-colors;  // color, background-color, border-color 200ms ease
```

## Position & Z-Index

`relative`, `absolute`, `fixed`, `sticky`, `sticky-top($top)`, `inset-0`, `z-dropdown`, `z-sticky`, `z-overlay`, `z-modal`, `z-toast`

## Overflow & Interaction

`overflow-hidden`, `overflow-auto`, `overflow-x-auto`, `cursor-pointer`, `cursor-not-allowed`, `select-none`, `opacity-50`

## Opacity

`opacity-0`, `opacity-100`

## Form

`form-label`, `form-grid`, `form-actions`, `form-input`, `form-textarea`, `form-select`,
`form-field-group`, `form-input-icon-group`, `search`,
`form-check`, `form-checkbox`, `form-radio`,
`pill`, `pill-outline`, `pill-group`, `pill-switch`, `pills-switch`,
`pills`, `pills-outline`,
`check-list`, `check-list-outline`,
`toggle-switch`,
`form-validate-invalid`, `form-validate-valid`, `form-validate-errors`

### form-grid

6-column CSS Grid layout for forms:

```scss
#my-form {
    @include form-grid;  // display: grid, grid-template-columns: repeat(6, 1fr), gap

    .form-element { grid-column: span 3; }                         // half width
    #field-notes { grid-column: span 6; }                          // full width by ID
    .form-element:has([name="message"]) { grid-column: span 6; }   // by input name
    .form-element:nth-child(5) { grid-column: span 6; }           // by position
    > fieldset { grid-column: span 6; }
    .form-actions { grid-column: span 6; }
}
```

### pill-outline

Base pill label mixin (structure + visible border + visible input). Standalone — does not depend on `pill` being applied first:

```scss
#my-form label { @include pill-outline; }
```

### pill-switch / pills-switch

`pill-switch` — label + toggle-switch in a flex row. `pills-switch` — vertical
`<ul>` list of `pill-switch` labels. For settings panels with multiple on/off toggles.

```scss
#notifications-settings ul { @include pills-switch; }
```

### check-list / check-list-outline

Vertical `<ul>` where each `<li><label>` is a filled pill (`check-list`) or an
outlined pill (`check-list-outline`). Same structure as `pill-group` but vertical.

```scss
#dept-filter { @include check-list; }          // filled bg on checked
#dept-filter { @include check-list-outline; }  // bordered, visible input
```

### pills / pills-outline

`pills` — joined filled pill strip on a `<ul>`. `pills-outline` — joined outlined
strip with negative-margin overlap for single shared borders.

```scss
#role-filter { @include pills; }          // filled joined strip
#status-filter { @include pills-outline; } // outlined joined strip
```

### Validation states

`form-validate-invalid` / `form-validate-valid` — border-color + focus ring for
error/success state. Apply on the `<input>` or `<select>`. `form-validate-errors`
— styles the `<ul class="validation-errors">` error list below an input.

```scss
input.error:focus-visible  { @include form-validate-invalid; }
input.valid:focus-visible  { @include form-validate-valid; }
.form-element ul           { @include form-validate-errors; }
```

## Table

`table-base`, `table-responsive`, `table-striped`, `table-section-header`, `table-action`

## Focus Ring (v1.1)

Six presets, all default to `var(--color-primary)`. Apply on `:focus-visible`.

| Mixin | Description |
|---|---|
| `focus-ring($color)` | Three-layer halo: separator + main ring + soft outer glow |
| `focus-border-thicken($color)` | Outline 2px, no layout shift |
| `focus-combination($color, $width)` | Border color change + outer ring — max signal |
| `focus-background-shift($color)` | Light primary tint on field background, no border |
| `focus-accent-line($color)` | Bottom border only — subtle |
| `focus-inset-shadow($color, $width)` | Inner shadow — field sinks |

`focus-ring` is the default for most interactive elements. Override `$color` for error state:

```scss
input.error:focus-visible { @include focus-ring(var(--color-error)); }
```

## Motion safety

`motion-safe` — wraps content in `@media (prefers-reduced-motion: no-preference)`. Gate `transform`, `opacity`, `translate`, `scale`, `rotate`, and keyframe animations inside it. See `css/visual-rules.md` for the full motion pattern.

## Breakpoint Mixins

Never hardcode pixel values inside `@media` or `@container`. Always use these mixins.
See `css/breakpoints.md` for decision rules (media = app shell; container = components).

```scss
// Viewport — app shell layout only
@include mq-up(md)                       // → @media (min-width: 768px)
@include mq-down(lg)                     // → @media (max-width: 1023px)

// Container — component-level responsive
@include cq-up(medium, page-header)      // → @container page-header (min-width: 880px)
@include cq-down(compact)               // → anonymous @container (max-width: 579px)
```

Valid names for `mq-up/mq-down`: `sm`, `md`, `lg`, `xl`, `2xl`, `3xl`
Valid names for `cq-up/cq-down`: `narrow`, `compact`, `medium`, `wide`
(plus the media names resolve too — the map is shared)

Optional `$container` argument on `cq-up/cq-down` names the container context.
Omit for anonymous container queries.

## Component Composites

**Card:** `card`, `card-accent-top`, `card-accent-bottom`, `card-accent-left`, `card-bg`,
`card-stacked`, `card-field-list`,
`panel-header`, `panel-body`, `panel-footer`,
`section`, `section-card`,
`floating-panel`

**Button:** `btn` (structure + filled colors), `btn-sm`, `btn-lg`, `btn-group`

**Avatar:** `avatar`, `avatar-sm`, `avatar-lg`, `avatar-xl`

**Layout:** `grid`, `grid-2`, `grid-4`, `stack($gap)`, `row($gap)`, `row-between($gap)`, `row-center($gap)`, `container($name)`, `flat-stack`

### `flat-stack`

Parent-scope re-bind mixin: re-binds `--gap: 0`, and on direct
children `--radius: 0`, `--shadow: none`, and
`--border-block-start: none` (from the second child onward). Works
with any panel that reads the logical tokens (card, section-card,
stat-card). Block-axis only. See `docs/css/layout.md`.

### floating-panel

Chrome recipe for floating overlays (popover, dropdown menu, toast). Rebinds
`--color-bg`, `--color-border`, `--shadow` to elevated/floating values. Reads
SOFT per-side border tokens (`--border-block-start` etc.) with full-border fallback.

```scss
[data-ln-dropdown-menu] { @include floating-panel; @include menu-items; }
```

### card-field-list

Parent-scope mixin: styles `.field` rows (`.label` + `.value`) inside a card body.
Separator between rows; none after last. Targets descendant `.field`, `.label`,
`.value` — apply on any container that wraps those structural classes.

```scss
#user-detail > main { @include card-field-list; }
```

**App-shell:** `app-wrapper`, `app-header`, `app-header-left`, `app-header-right`, `app-header-actions`, `header-avatar`, `app-main`, `sidebar` (+ `sidebar-drawer` for drawer variant), `app-scrim`, `app-footer`. Global bindings: `.app-wrapper`, `.app-header`, `.app-main`, `.app-sidebar`, `.app-scrim`, `.app-footer`, `.header-left`, `.header-right`, `.header-actions`, `.header-avatar`. See `css/app-shell.md`. `@mixin header-avatar` is distinct from `@mixin avatar` — image-only circle vs profile button with ring.

**Collapsible:** `collapsible`, `collapsible-content`, `accordion`

**Alerts:** `alert` (with `alert-banner` variant — apply both for full-width banner)

**Badge:** `badge`, `badge-live` — see `components/status-badge.md`

**Stat card:** `stat-card` — see `components/stat-card.md`

**Chip:** `chip` — removable filter token, not a status badge

**Modal:** `modal-sm`, `modal-md`, `modal-lg`, `modal-xl`

**Nav:** `nav`, `nav-links-rounded`, `nav-links-border-left`, `nav-links-border-grow`, `nav-links-border-top`

**Page:** `page-header`, `empty-state`, `prose`

**Navigation aid:** `breadcrumbs`, `stepper`, `timeline`

**Interaction:** `loader`, `toggle-switch`, `tooltip`

**Menu surfaces:** `menu-items` (shared recipe), `dropdown`, `dropdown-menu` (composes `menu-items`), `floating-panel`. `aria-current="true"` marks the active item in boolean single-select menus (scoped so it doesn't clash with breadcrumbs / stepper). For popover-as-menu: `@include floating-panel; @include menu-items;`.

**Tabs:** `tabs-nav`, `tabs-tab`, `tabs-panel` — active/disabled states (`[data-ln-tab][data-active]` / `[data-ln-tab][disabled]`) are nested selectors inside `@mixin tabs-nav`, not separate callable mixins.

**Tables:** `table-base`, `table-responsive`, `table-striped`, `table-section-header`, `table-action`

### Table interaction mixins

`table-sort` / `table-sort-active` — sort button for `<th>`. Applied by `scss/components/_table.scss`
to `.table-sort` — project rarely needs to apply directly.

`table-filter` / `table-filter-active` — filter button for `<th>`. Same pattern as sort.

`table-row` — clickable row (cursor pointer + hover bg).
`table-row-selected` — accent tint on a selected row.
`table-row-focused` — outline 2px accent for keyboard-focused row.
`table-row-action` — ghost row-action button (half-opacity idle, full on hover).
`table-row-action-delete` — extends row-action; rebinds `--color-primary` to error.
`table-row-actions` — absolute-positioned action overlay that fades in on row hover.
`table-spacer-row` — zero-padding, borderless spacer row between groups.

See `css/tables.md` for full usage patterns.

### `kbd` mixin (v1.1)

Renders keyboard key labels — monospace, bordered, bottom-heavy border for key depth:

```scss
kbd { @include kbd; }
```

---

## Architecture — Three Layers

```
scss/config/_tokens.scss        → CSS custom properties (:root)
scss/config/mixins/*.scss       → Mixin recipes (never generate CSS)
scss/components/*.scss          → Apply mixins to default selectors (generate CSS)
```

### Adding a new mixin + component

1. Create `scss/config/mixins/_thing.scss` with `@mixin thing { ... }`
2. Register: `@forward 'thing'` in `scss/config/mixins/_index.scss`
3. Update header comment in `scss/config/_mixins.scss`
4. Create `scss/components/_thing.scss`: `#thing { @include thing; }`
5. Add `@use 'components/thing'` to `scss/ln-ashlar.scss`

### Project integration

```scss
// project/app.scss
@use 'ln-ashlar/scss/ln-ashlar';       // full framework
@use 'scss/overrides';                  // project token overrides
@use 'scss/components/my-feature';      // project components
```

### Override tokens

```scss
// project/scss/_overrides.scss
:root {
    --color-primary: 210 80% 42%;       // project brand
}
```
