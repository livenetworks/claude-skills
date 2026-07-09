# ln-ashlar — Data Table Implementation

> HOW to build data tables with ln-ashlar. For WHAT a data table must have → global ui/components/data-table.md.

## Components

### ln-table (UI)

- Attribute: `data-ln-table` on table container (value = table name)
- Two execution modes: **SSR** (enhances server-rendered rows) and **Data-Driven** (template-cloning presenter)
- Sort, filter, search, virtual scroll, row selection, keyboard navigation
- Instance property: `el.lnTable`

### ln-data-store (Data)

- Attribute: `data-ln-data-store` on a container element (value = store name)
- IndexedDB with in-memory fallback, delta sync, optimistic mutations
- Instance property: `el.lnDataStore`

## Execution Modes

**SSR mode** — no `data-ln-table-source`. Blade renders full `<tbody>` rows from server. JS enhances in-place for sort, filter, search, virtual scroll.

**Data-Driven mode** — add `data-ln-table-source` attribute. Table renders rows from `ln-table:set-data` events by cloning `<template data-ln-template="{name}-row">`. Initial SSR rows (if any) are parsed immediately for instant paint, then replaced on first `set-data`.

## HTML Structure

```html
<!-- SSR mode (no data-ln-table-source) -->
<section data-ln-table="packages" id="packages-table">
	<header>
		<input data-ln-search="packages-table" type="search" placeholder="Search…">
	</header>
	<table>
		<thead>
			<tr>
				<th data-ln-table-sort="string">Name</th>
				<th data-ln-table-sort="number">Max Users</th>
			</tr>
		</thead>
		<tbody>
			<!-- Server-rendered rows -->
			<tr>
				<td>Pro</td>
				<td data-ln-value="50">50</td>
			</tr>
		</tbody>
	</table>
</section>

<!-- Data-Driven mode -->
<section data-ln-table="packages" data-ln-table-source id="packages-table">
	<header>
		<input data-ln-search="packages-table" type="search" placeholder="Search…">
	</header>
	<table>
		<thead>
			<tr>
				<th data-ln-table-col="name">
					Name
					<button data-ln-table-col-sort aria-label="Sort by name"></button>
				</th>
				<th data-ln-table-col="max_users">
					Max Users
					<button data-ln-table-col-sort aria-label="Sort by max users"></button>
				</th>
				<th><!-- actions --></th>
			</tr>
		</thead>
		<tbody data-ln-table-body></tbody>
	</table>
	<footer>
		<span>
			<span data-ln-table-total></span> records
		</span>
	</footer>
</section>

<template data-ln-template="packages-row">
	<tr data-ln-table-row>
		<td>{{ name }}</td>
		<td>{{ max_users }}</td>
		<td>
			<ul>
				<li>
					<button data-ln-table-row-action="edit" aria-label="Edit {{ name }}">Edit</button>
				</li>
			</ul>
		</td>
	</tr>
</template>
```

## Key Data Attributes

| Attribute | Applied To | Purpose |
|---|---|---|
| `data-ln-table` | Wrapper | Table name; component root |
| `data-ln-table-source` | Wrapper | Opt-in: Data-Driven mode |
| `data-ln-table-selectable` | Wrapper | Enable row checkboxes |
| `data-ln-table-col="field"` | `<th>` | Maps header to record field key |
| `data-ln-table-col-sort` | Button in `<th>` | Three-state sort trigger |
| `data-ln-table-col-filter` | Button in `<th>` | Opens filter popover |
| `data-ln-table-filter-col="key"` | `<th>` | Maps filter key to column |
| `data-ln-table-col-select` | `<th>` | Select-all checkbox column |
| `data-ln-table-row` | `<tr>` | Row container; click target |
| `data-ln-table-row-id` | `<tr>` | Record ID on rendered row |
| `data-ln-table-row-select` | Input | Per-row selection checkbox |
| `data-ln-table-row-action="name"` | Button | Row action trigger |
| `data-ln-table-body` | `<tbody>` | Data-driven render target |
| `data-ln-table-total` | Inline | Footer: total record count |
| `data-ln-table-filtered` | Inline | Footer: visible (filtered) count |
| `data-ln-table-selected` | Inline | Footer: selected count |
| `data-ln-table-clear-all` | Button | Reset all filters + search |
| `data-ln-value` | `<td>` | Raw machine value for sort/filter (display stays in text) |

## Coordinator Wiring (Data-Driven)

```javascript
// Table requests data → coordinator queries store → feeds back
document.addEventListener('ln-table:request-data', function (e) {
	const storeEl = document.querySelector('[data-ln-data-store="packages"]');
	const store = storeEl.lnDataStore;

	store.getAll({
		sort: e.detail.sort,
		filters: e.detail.filters,
		search: e.detail.search
	}).then(function (result) {
		e.target.dispatchEvent(new CustomEvent('ln-table:set-data', {
			bubbles: false,
			detail: { data: result.data, total: result.total, filtered: result.filtered }
		}));
	});
});

// Store synced → re-request data (table refreshes automatically)
document.addEventListener('ln-store:synced', function () {
	const tableEl = document.getElementById('packages-table');
	if (tableEl && tableEl.lnTable) {
		tableEl.lnTable._requestData();
	}
});
```

## Filter Composition

Filter UI is **not built into the table**. It is composed from:
- `ln-popover` — opens the filter panel
- `ln-search` — search input inside the panel
- `ln-filter` — checkbox/radio options inside the panel

The table listens to `ln-filter:changed` (bubbled from the filter panel). `ln-search:change` is listened on the table wrapper when the search input targets the table's ID.

## Events

| Event | Direction | Payload | Purpose |
|---|---|---|---|
| `ln-table:request-data` | Table → Coordinator | `{ table, sort, filters, search }` | Requests dataset |
| `ln-table:set-data` | Coordinator → Table | `{ data, total, filtered }` | Feeds dataset |
| `ln-table:set-loading` | Coordinator → Table | `{ loading }` | Toggle loading overlay |
| `ln-table:ready` | Table → Coordinator | `{ total }` | After initial parse |
| `ln-table:rendered` | Table → Coordinator | `{ table, total, visible }` | After rows drawn |
| `ln-table:sort` | Table → Coordinator | `{ table, field, direction }` | Sort changed |
| `ln-table:filter` | Table → Coordinator | `{ term, matched, total }` | Filter/search changed (SSR) |
| `ln-table:row-click` | Table → Coordinator | `{ table, id, record }` | Row body clicked |
| `ln-table:row-action` | Table → Coordinator | `{ table, id, action, record }` | Row action button clicked |
| `ln-table:select` | Table → Coordinator | `{ table, selectedIds, count }` | Row selection changed |
| `ln-table:select-all` | Table → Coordinator | `{ table, selected }` | Select-all toggled |
| `ln-table:empty` | Table → Coordinator | `{ term, total }` | Empty state shown |

## ln-data-store Events

| Event | Direction | Purpose |
|---|---|---|
| `ln-store:request-remote-sync` | Store → Coordinator | Needs remote data fetch |
| `ln-store:ready` | Store → Coordinator | Cache loaded (from IDB or server first load) |
| `ln-store:loaded` | Store → Coordinator | First server load complete |
| `ln-store:synced` | Store → Coordinator | Background delta sync complete |
| `ln-store:created` | Store → Coordinator | Optimistic create applied |
| `ln-store:updated` | Store → Coordinator | Optimistic update applied (also fires on server-confirm id-swap and server-wins conflict reconciliation — there is no separate "confirmed" event) |
| `ln-store:deleted` | Store → Coordinator | Optimistic delete applied (also fires on create-reject cleanup) |
| `ln-store:request-create` | Coordinator → Store | Request optimistic create — dispatched both at form/API intake AND at server-confirm reconciliation (id-swap via `ln-store:request-update`) |
| `ln-store:request-update` | Coordinator → Store | Request optimistic update |
| `ln-store:request-delete` | Coordinator → Store | Request optimistic delete |
| `ln-store:request-bulk-delete` | Coordinator → Store | Request optimistic bulk delete |
| `ln-store:destroyed` | Store → (global) | Instance torn down |

> Sortable/formatted cells carry the raw value in `data-ln-value`.
> See ln-core-api.md → "Codegen rule — formatted/sortable cells".
