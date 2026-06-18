# ln-ashlar — Search Implementation

> HOW to build search with ln-ashlar. For WHAT search must have → global ui/components/search.md.

## Client-Side Search

- Attribute: `data-ln-search` on `<input>` or on a wrapper element
- Listens on `input` event; 150ms trailing-edge debounce
- Emits: `ln-search:change` (cancelable) with `{ term, targetId }`
- Clear button auto-appears / auto-hides via `data-ln-search-clear` in scope
- Non-matching items receive `data-ln-search-hide="true"`

When placed on a **wrapper** element (not the input itself), the component finds the input inside it via `[name="search"]`, `input[type="search"]`, or `input[type="text"]`.

## Attributes

| Attribute | On | Purpose |
|---|---|---|
| `data-ln-search="<targetId>"` | `<input>` or wrapper | Binds search; value is the ID of the target container |
| `data-ln-search-items="selector"` | Same element | CSS selector for items to filter inside target (default: direct children) |
| `data-ln-search-clear` | Button inside scope | Clears input and resets filter on click |
| `data-ln-search-hide` | Items (set by JS) | Applied to items that don't match the current term |

## Canonical HTML

```html
<!-- Search on input (simplest form) -->
<input data-ln-search="packages-table" type="search" placeholder="Search packages…">

<!-- Search with clear button — wrapper host -->
<div class="search-field">
	<input type="search" name="search" placeholder="Search…">
	<button type="button" data-ln-search-clear aria-label="Clear search">
		<svg class="ln-icon" aria-hidden="true"><use href="#ln-x"></use></svg>
	</button>
</div>
<!-- data-ln-search goes on the wrapper in this case: -->
<div class="search-field" data-ln-search="my-list">
	<input type="search" name="search" placeholder="Search…">
	<button type="button" data-ln-search-clear aria-label="Clear search">
		<svg class="ln-icon" aria-hidden="true"><use href="#ln-x"></use></svg>
	</button>
</div>
```

## Server-Side Search

Use `data-ln-form-auto` with `data-ln-form-debounce`:

```html
<form action="/search" method="get" data-ln-form-auto data-ln-form-debounce="300">
	<input name="q" type="search" placeholder="Search...">
</form>
```

## ln-table integration

`ln-table` (both modes) listens to `ln-search:change` on the table wrapper. Point the search input at the table's ID:

```html
<input data-ln-search="my-table-id" type="search" placeholder="Search…">
<section data-ln-table="packages" id="my-table-id">...</section>
```
