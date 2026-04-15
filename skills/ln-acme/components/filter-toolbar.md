# Filter Toolbar

> Canonical docs: `docs/css/filter-toolbar.md`
> Source: `scss/config/mixins/_filter-toolbar.scss` + `scss/components/_filter-toolbar.scss`

---

## Decision: filter-toolbar vs ad-hoc filter rows

Always use `[data-ln-filter-toolbar]` (or `@include filter-toolbar`) for above-table search + filter layouts. Do NOT build per-page flex rows with custom spacing — they diverge and break at narrow widths. The mixin handles the stacked → single-row responsive transition via container query.

---

## HTML pattern

```html
<div data-ln-filter-toolbar>
	<div data-ln-filter-search>
		<input type="search" placeholder="Search documents…">
	</div>
	<div data-ln-filter-group>
		<span data-ln-chip>Status: Draft <button type="button" aria-label="Remove Status filter">×</button></span>
		<span data-ln-chip>Tag: Quality <button type="button" aria-label="Remove Tag filter">×</button></span>
	</div>
	<div data-ln-filter-sort>
		<select>
			<option>Sort: Newest</option>
			<option>Sort: Oldest</option>
			<option>Sort: A–Z</option>
		</select>
	</div>
	<div data-ln-filter-bulk>
		<button type="button">Bulk actions</button>
	</div>
</div>
```

---

## Slots

| Slot attribute | Grid area | Width | Purpose |
|---|---|---|---|
| `data-ln-filter-search` | `search` | `minmax(12rem, 20rem)` | Search input |
| `data-ln-filter-group` | `chips` | `1fr` (fills remaining) | Active filter chips (`data-ln-chip`) |
| `data-ln-filter-sort` | `controls` | `auto` | Sort dropdown |
| `data-ln-filter-bulk` | `controls` | shares with sort | Bulk action button |

All slots are optional. If both `data-ln-filter-sort` and `data-ln-filter-bulk` are present they share the `controls` area with an `inline-flex` + `gap(0.5rem)` layout.

---

## Responsive (container query)

- **Below 880px:** vertical stack — search → chips → controls.
- **880px+:** single row — search | chips | controls.

The parent element must declare `container-type: inline-size` (or use `@include container`) for the query to fire.

---

## Project usage

```scss
// Default selector via attribute — no extra CSS needed.
// For a custom selector:
#documents-filters { @include filter-toolbar; }
#documents-page    { @include container(docpage); }
```
