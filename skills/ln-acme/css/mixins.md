# ln-acme — Mixin Reference

> Complete list of available SCSS mixins. For full signatures → `docs/css/mixins.md`.

---

## Usage

```scss
@use 'ln-acme/scss/config/mixins' as *;

// Apply mixin to semantic selector
#add-user { @include btn; }
```

---

## Spacing

`p()`, `px()`, `py()`, `pt()`, `pb()`, `pl()`, `pr()`, `m()`, `mx()`, `my()`, `mt()`, `mb()`, `ml()`, `mr()`, `gap()`

```scss
#card { @include p(var(--spacing-md)); }
#card header { @include px(var(--spacing-lg)); @include py(var(--spacing-md)); }
```

## Display & Flex

`flex`, `inline-flex`, `block`, `inline-block`, `hidden`, `flex-col`, `flex-row`, `flex-wrap`, `flex-1`, `flex-shrink-0`, `items-center`, `items-start`, `items-end`, `justify-center`, `justify-between`, `justify-end`, `flex-center`

## Sizing

`w-full`, `h-full`, `min-h-screen`, `w()`, `h()`, `size()`

## Typography

`text-xs`, `text-sm`, `text-base`, `text-lg`, `text-xl`, `text-2xl`, `font-normal`, `font-medium`, `font-semibold`, `font-bold`, `text-left`, `text-center`, `text-right`, `uppercase`, `lowercase`, `capitalize`, `normal-case`, `truncate`, `whitespace-nowrap`, `font-mono`, `font-sans`, `tracking-tight`, `tracking-normal`, `tracking-wide`, `tracking-wider`

### `typography($role)` — semantic role mixin (v1.1)

Sets `font-size` + `line-height` from paired `--text-*` / `--lh-*` tokens.

Valid roles: `display-lg`, `display-md`, `display-sm`, `heading-lg`, `heading-md`, `heading-sm`, `title-md`, `title-sm`, `body-lg`, `body-md`, `body-sm`, `label-md`, `label-sm`, `caption`.

```scss
h1 { @include typography(heading-lg); }
.caption { @include typography(caption); }
```

Prefer `typography($role)` over raw `text-*` mixins for component internals. The raw size mixins (`text-sm`, etc.) remain valid for one-off adjustments.

## Colors

`text-primary`, `text-secondary`, `text-muted`, `text-white`, `text-error`, `text-success`, `text-warning`, `bg-primary`, `bg-secondary`, `bg-body`

## Border & Radius

`border`, `border-t`, `border-b`, `border-l`, `border-r`, `border-none`, `rounded-sm`, `rounded-md`, `rounded-lg`, `rounded-xl`, `rounded-full`

## Shadow

`shadow-none`, `shadow-sm`, `shadow-md`, `shadow-lg`, `shadow-xl`

## Transition

`transition`, `transition-fast`, `transition-colors`

```scss
@include transition;         // all 200ms ease — general purpose
@include transition-fast;    // all 150ms ease — micro-interactions
@include transition-colors;  // color, background-color, border-color 200ms ease
```

## Position & Z-Index

`relative`, `absolute`, `fixed`, `sticky`, `inset-0`, `z-dropdown`, `z-sticky`, `z-overlay`, `z-modal`, `z-toast`

## Overflow & Interaction

`overflow-hidden`, `overflow-auto`, `overflow-x-auto`, `cursor-pointer`, `cursor-not-allowed`, `select-none`, `opacity-50`

## Opacity

`opacity-0`, `opacity-100`

## Form

`form-label`, `form-grid`, `form-actions`, `form-input`, `form-textarea`, `form-select`, `form-check`, `form-checkbox`, `form-radio`, `pill`, `pill-group`, `pill-outline`

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

## Component Composites

**Card:** `card`, `card-accent-top`, `card-accent-bottom`, `card-accent-left`, `card-bg`, `card-stacked`, `panel-header`, `section`, `section-card`

**Button:** `btn` (structure + filled colors), `btn-sm`, `btn-lg`, `btn-group`, `close-button`

**Avatar:** `avatar`, `avatar-sm`, `avatar-lg`, `avatar-xl`

**Layout:** `grid`, `grid-2`, `grid-4`, `stack($gap)`, `row($gap)`, `row-between($gap)`, `row-center($gap)`, `container($name)`

**Collapsible:** `collapsible`, `collapsible-content`, `accordion`

**Alerts:** `alert`, `banner`

**Badge:** `badge`, `badge-live` — see `components/status-badge.md`

**Stat card:** `stat-card` — see `components/stat-card.md`

**Chip:** `chip` — removable filter token, not a status badge

**Modal:** `modal-sm`, `modal-md`, `modal-lg`, `modal-xl`

**Nav:** `nav`, `nav-links-rounded`, `nav-links-border-left`, `nav-links-border-grow`, `nav-links-border-top`

**Page:** `page-header`, `empty-state`, `prose`

**Navigation aid:** `breadcrumbs`, `stepper`, `timeline`

**Interaction:** `loader`, `toggle-switch`, `tooltip`

**Tables:** `tabs-nav`, `tabs-tab`, `tabs-tab-active`, `tabs-tab-disabled`, `tabs-panel`

**Tables:** `table-base`, `table-responsive`, `table-striped`, `table-section-header`, `table-action`

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
5. Add `@use 'components/thing'` to `scss/ln-acme.scss`

### Project integration

```scss
// project/app.scss
@use 'ln-acme/scss/ln-acme';           // full framework
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
