# ln-ashlar — Forms Mixin Reference

Quick reference for form layout and input mixins. Full source: `scss/config/mixins/_form.scss`.
For HTML structure rules → global `html` skill §7.

---

## Layout

### `form-grid`

6-column CSS grid with `container-type: inline-size` (named `form-grid`). Collapses
to 1 column below the `md` breakpoint (768px / `$bp-md`) via `@include cq-down(md, form-grid)`. Gap defaults to `--size-md`.

```scss
#add-user-form {
	@include form-grid;

	.form-element             { grid-column: span 3; }   // half
	.form-element:has([name="notes"]) { grid-column: span 6; }  // full
	.form-element:has([name="zip"])   { grid-column: span 2; }  // narrow
	.form-actions             { grid-column: span 6; }   // always full
}
```

### `form-actions`

Flex row, `justify-end`, `border-top`, `margin-top: var(--size-lg)`. Applied globally
to `.form-actions` in `scss/components/_form.scss`.

---

## Text inputs / textareas / selects

### `form-input`

Full-width, border, recessed bg, density-reactive padding via `--input-padding-y`.
Applied globally to `input[type="text"]`, `email`, `password`, `number`, `tel`,
`date`, `search`, `url`, `textarea`, `select` in `scss/components/_form.scss`.
Rarely applied in project SCSS — the global binding covers it.

### `form-textarea` / `form-select`

Delta-only addons layered on `form-input`. `form-textarea` adds `min-height` and
`resize: vertical`. `form-select` adds the SVG dropdown arrow background.

### `form-field-group`

Shell mixin for icon-decorated inputs: one bordered flex container wrapping
`svg.ln-icon + input` or `input + button`. Zeroes shell padding; children own theirs.
Focus handled once on the shell via `:focus-within`.

```scss
// Applied globally in components/_form.scss to:
// label:has(.ln-icon):has(input[type="text"])   and similar
// Applied in components/_date.scss to:
// [data-ln-date-field]
```

### `form-input-icon-group` / `search`

`form-input-icon-group` adds the visually-hidden clear button behavior to `form-field-group`.
`search` is a delta-only refinement for search inputs: capped width, recessed bg,
density-immune pin to dense scale.

```scss
label.search { @include search; }
```

---

## Checkbox / Radio / Pill controls

### `form-checkbox` / `form-radio`

Custom-styled native checkbox/radio. Applied globally in `scss/components/_form.scss`.

### `pill-outline`

Single label: bordered pill, visible native input indicator, accent border on checked.
Base for derived pill mixins.

### `pill`

Extends `pill-outline`: filled bg, hidden input, accent fill on checked.
Applied globally to `fieldset label` (radio/checkbox groups in forms).

### `pill-group`

Joined horizontal strip on a `<ul>`. Squares borders between items; rounds
first/last. Apply to `<ul>` whose `<li>` contain labels.

```scss
#role-filter ul { @include pill-group; }
```

### `pills` / `pills-outline`

`pills` — joined filled strip targeting `ul > li > label:has(input[type="checkbox/radio"])`.
`pills-outline` — same structure, outlined variant, with negative-margin overlap.

```scss
#status-filter { @include pills; }
#type-filter   { @include pills-outline; }
```

### `check-list` / `check-list-outline`

Vertical list: `check-list` = filled pill per item; `check-list-outline` = outlined.
Apply to a `<ul>`.

```scss
#dept-filter { @include check-list-outline; }
```

### `toggle-switch`

Styled `<input type="checkbox">` rendered as an iOS-style toggle track+thumb.
Applied globally in `scss/components/_form.scss`.

### `pill-switch` / `pills-switch`

`pill-switch` — label wrapping `[toggle-switch]` in a flex row with text.
`pills-switch` — vertical `<ul>` list of `pill-switch` labels.

```scss
#notification-prefs ul { @include pills-switch; }
```

---

## Validation states

### `form-validate-invalid` / `form-validate-valid`

Error / success border-color + focused ring. Apply on the `<input>` element.

### `form-validate-errors`

Styles `<ul class="validation-errors">` (or `[data-ln-validate-errors]`):
caption-size red text, `min-height` to prevent layout shift, `list-style: none`.

```scss
// Applied globally in scss/components/_form.scss
.form-element .validation-errors { @include form-validate-errors; }
```

---

## Label

### `form-label`

Block display, `text-label-md`, medium weight. Generates `::after { content: ' *' }`
for labels adjacent to `[required]` inputs. Applied globally to `label`.
