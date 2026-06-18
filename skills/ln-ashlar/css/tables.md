# ln-ashlar — Tables Mixin Reference

Quick reference for table mixins. Full source: `scss/config/mixins/_table.scss`.
For `ln-table` (data-driven enhanced table) → JS component docs.

---

## Base

### `table-base($sticky: false)`

Full table chrome: `w-full`, rounded corners, `overflow: clip`, resting shadow,
tabular-nums. Thead: sunken bg, strong border-bottom. `th`: label-sm, semibold,
uppercase, `letter-spacing: 0.06em`. `td`: density-reactive padding, border-bottom.
Last row border removed. Applied globally to `table` in `scss/components/_table.scss`.

`$sticky: true` enables `border-collapse: separate` + `sticky thead` +
sticky footer support for scrollable tables.

```scss
#audit-log { @include table-base; }
#audit-log { @include table-base($sticky: true); }  // sticky header
```

### `table-responsive`

Stacks rows as card-blocks at narrow widths. Requires `data-label` attribute on each
`<td>` for column header labels. Combine with a container query trigger:

```scss
#users-table {
	@include table-base;
	@include container(userstable);
}
#users-table table {
	@include cq-down(compact, userstable) {
		@include table-responsive;
	}
}
```

---

## Variants

### `table-striped`

Alternate odd row bg via `--bg-sunken`. Layer on `table-base`.

### `table-section-header`

Applies to a `<tr>` acting as a group divider — sunken bg, semibold muted text.

### `table-action`

Inline icon-button inside a `<td>`: `inline-flex`, `text-sm`, subtle hover bg.
For action links in cells (not row-level overlays).

---

## Row interaction

### `table-row`

Clickable row: `cursor: pointer` + hover bg. Apply to `<tr>` that navigates
or opens a detail panel.

### `table-row-selected`

Accent tint background (`--color-accent-tint`). Apply on a `<tr>` when selected.

### `table-row-focused`

2px accent outline (inset) for keyboard-focused rows. Used by `ln-table` for
keyboard navigation; apply in project SCSS for custom navigation.

### `table-row-action` / `table-row-action-delete`

Ghost row-action button: no border/shadow, half-opacity idle, full opacity on hover.
`table-row-action-delete` extends it with `--color-primary: var(--color-error)`.

```scss
#users td:last-child ul li button           { @include table-row-action; }
#users td:last-child ul li button[data-action="delete"] { @include table-row-action-delete; }
```

### `table-row-actions`

Absolute-positioned `<ul>` overlay that fades in on row hover (right side of row).
Includes a gradient fade-out to the left. Triggered by `tbody tr:hover`. Applied
globally to `.table-row-actions` in `scss/components/_table.scss`.

### `table-spacer-row`

Zero-padding, borderless `<tr>` for group separation. All `td` get `padding: 0`.

---

## Column header controls

### `table-sort` / `table-sort-active`

Circular 28px button inside `<th>` for sort direction. `table-sort-active` sets
accent color at full opacity. Applied globally to `.table-sort`.

### `table-filter` / `table-filter-active`

Same as sort but for column filter trigger. `table-filter-active` adds a small
accent dot (`:after`) to indicate an active filter. Applied globally to `.table-filter`.

`<th>` with both `.table-sort` and `.table-filter` auto-repositions both absolutely
via the `&:has(.table-sort):has(.table-filter)` selector in `table-base`.
