# Data Table

> The primary component for displaying, navigating, and acting on structured data.

---

## Core Principle

A data table is a VIEWPORT into a dataset — not a paginated slice. The user works with ALL their data through a scrollable window. Data lives in a client-side cache (IndexedDB), sort/filter/search are instant (client-side), and the system syncs with the server in the background.

---

## Anatomy

```
┌─────────────────────────────────────────────────────────────────┐
│ [🔍 Search documents...]                          [+ Create]   │ ← Toolbar (search + primary action only)
├────┬──────────────────┬────────────┬──────────┬────────┬───────┤
│ ☐  │ Name          ⇅  │ Status ▾●⇅ │ Category │ Date ↑ │       │ ← Sticky header (sort + filter per column)
├────┼──────────────────┼────────────┼──────────┼────────┼───────┤
│ ☐  │ ISO 27001 Policy │ ● Approved │ Policy   │ Jan 15 │ ⋯    │
│ ☐  │ Risk Assessment  │ ● Draft    │ Report   │ Feb 03 │ ⋯    │
│ ☐  │ Access Control   │ ● Pending  │ Policy   │ Mar 22 │ ⋯    │
│    │                  │            │          │        │       │
│    │  (virtual scroll — renders visible rows from local cache) │
│    │                  │            │          │        │       │
├────┴──────────────────┴────────────┴──────────┴────────┴───────┤
│ 1,247 items · 45 filtered · 5 selected  [Delete]   Σ €24,500  │ ← Sticky footer
└─────────────────────────────────────────────────────────────────┘
```

---

## Data Layer — Table is UI Only

The data table is a PURE UI COMPONENT. It receives data, renders it, and emits events. It does NOT fetch, cache, or sync data.

Data flows through a separate layer (ln-store or equivalent):

```
┌─────────────────────────┐        ┌──────────────────────────────┐
│ DATA LAYER (ln-store)   │        │ UI LAYER (ln-data-table)     │
│                         │        │                              │
│ IndexedDB read/write    │ data → │ Virtual scroll rendering     │
│ Server sync (delta)     │        │ Sticky header/footer         │
│ Stale-while-revalidate  │ ← events │ Sort/filter/search UI     │
│ Optimistic mutations    │        │ Row selection                │
│ Cache versioning        │        │ Keyboard navigation          │
│ Conflict detection      │        │                              │
└─────────────────────────┘        └──────────────────────────────┘
```

The coordinator (project-specific JS) connects them:

```
User clicks sort → table emits event → coordinator queries store → store returns sorted data → table renders

User creates record → coordinator sends to server → optimistic update in store → table re-renders
```

This separation means:
- Table works with any data source (IndexedDB, REST, WebSocket, static array)
- Data layer is reusable by other components (autocomplete, dashboard, KPIs)
- WebSocket support can be added to the data layer later without touching table code

---

## Data Loading Strategy

### Server-Side Rendering (SSR / Blade)

Blade renders ONLY the table shell — structure, toolbar, header columns, footer. Blade NEVER renders `<tr>` data rows.

```
Blade renders:
  ✓ Page layout, toolbar, search input, create button
  ✓ Table header with column names
  ✓ Table footer structure
  ✓ Skeleton rows (CSS-only loading placeholders)

JS handles:
  ✓ Reading data from IndexedDB
  ✓ Rendering table rows
  ✓ Sort, filter, search (all client-side)
  ✓ Background delta sync
```

### First Visit (Empty IndexedDB)

```
1. Blade → table shell + skeleton rows (instant)
2. JS → GET /api/{resource} (full dataset)
3. JS → Store in IndexedDB + render table
4. Save last_synced_at timestamp
```

Skeleton is visible until the full dataset arrives. This happens ONCE.

### Subsequent Visits (IndexedDB has data)

```
1. Blade → table shell + skeleton rows (instant)
2. JS → IndexedDB read → render table (<50ms, practically instant)
3. JS → GET /api/{resource}?since={last_synced_at} (delta, background)
4. Server returns only changed/created/deleted records since timestamp
5. Merge deltas into IndexedDB → reactively update table if anything changed
6. Save new last_synced_at
```

User sees data in under 50ms. Skeleton is visible for one frame at most.

### Delta Sync Response Format

```json
{
  "data": [
    { "id": 42, "title": "Updated doc", "updated_at": 1736952600 },
    { "id": 99, "title": "New doc", "updated_at": 1736954400 }
  ],
  "deleted": [17, 23],
  "synced_at": 1736953500
}
```

Server requirements:
- `updated_at` column on every syncable table
- Soft deletes (`deleted_at` column) — deleted records appear in delta response
- Endpoint supports `?since=` parameter returning only changed records

### When to Sync

| Trigger | Action |
|---------|--------|
| Table mounts (page open) | Delta sync if `last_synced_at` older than threshold (e.g., 5 min) |
| Tab becomes visible again | Delta sync (visibility change event) |
| User performs CRUD action | Optimistic local update + server request |
| Future: WebSocket message | Push update directly into store |

### Optimistic Mutations

When the current user creates/edits/deletes:

```
1. Update IndexedDB immediately (before server responds)
2. Update table immediately (user sees instant result)
3. Send request to server
4. Server success → done (already up to date)
5. Server error → revert IndexedDB → revert table → show error
```

### Conflict Detection

When delta sync returns a record that the current user also modified:

```
Record in delta has updated_at > user's last known updated_at
  AND user has unsaved changes to this record
  → Show notification: "This record was modified by [user] at [time]"
  → Let user choose: keep mine / take theirs / view diff
```

For table views (not inline editing), conflicts are rare — just update silently.

### Cache Versioning

IndexedDB stores a schema version. When the application updates and the data structure changes:

```
App version changes → schema version mismatch
  → Clear IndexedDB → full reload from server
```

Also clear IndexedDB on logout.

---

## Scrolling — Virtual Scroll

### Why Not Pagination

Pagination breaks the user's mental model. Data is one continuous set, not "pages." Users think "I saw that record somewhere near the middle" — not "it was on page 7." Pagination makes cross-boundary comparison impossible.

### Virtual Scroll Behavior

- Renders only visible rows + buffer zone above and below
- Scrollbar reflects the TOTAL dataset size
- Since all data is in IndexedDB, no server requests during scroll
- Scroll position is preserved on return (navigating away and coming back)
- Smooth scrolling — no jumps or layout shifts

---

## Sticky Header

The column header row stays fixed at the top when scrolling vertically. Each column header is a multi-function element with two separate controls:

### Sort Toggle (Dedicated Button — Right Side)

A small toggle button with sort arrows. One click, no dropdown. This is the most frequent header interaction — it must be the fastest.

```
Click cycle: ⇅ (none) → ↑ (asc) → ↓ (desc) → ⇅ (none)
```

- One click action — no dropdown, no extra UI
- Only one column sorted at a time
- Active sort: arrow icon visually distinct (colored, filled)
- Inactive: ⇅ icon, muted
- Sort is client-side (IndexedDB query) — instant

### Filter Dropdown (Click Column Name or Filter Icon)

Click the column name or a dedicated filter icon to open a dropdown with filter options for that column.

```
┌──────────────────┐
│ [Search...]      │  ← Search within filter values (if >8 values)
│ ──────────────── │
│ ☑ Approved       │
│ ☑ Draft          │
│ ☐ Rejected       │
│ ☐ Pending        │
│ ──────────────── │
│ [Clear filter]   │
└──────────────────┘
```

- Checkbox list of unique values in that column
- Search within dropdown when more than 8-10 values
- "Clear filter" to remove filter for this column
- Client-side filtering (IndexedDB) — instant
- Multiple columns can be filtered simultaneously (AND logic)
- Filter dropdown closes on outside click

### Active State Indicators

Columns with active sort or filter must be visually distinct:

```
Inactive:      Status  ⇅  ▾          ← both icons muted
Sorted asc:    Status  ↑  ▾          ← sort icon colored/active
Sorted desc:   Status  ↓  ▾          ← sort icon colored/active
Filtered:      Status  ⇅  ▾●         ← dot on filter icon
Both active:   Status  ↑  ▾●         ← both indicators visible
```

The dot (or filled icon) tells the user "this column is filtering your data" without opening the dropdown.

### Column Resize

- Drag column border to resize
- Double-click column border to auto-fit content width
- Minimum width: enough for header text
- Widths persist in localStorage

---

## Sticky Footer

The footer stays fixed at the bottom. It is the STATUS BAR of the table.

### Always Shows:

- **Total count**: "1,247 items"
- **Filtered count** (when filters/search active): "45 of 1,247 items"
- **Active filter pills**: dismissible pills per active filter for quick clearing

### Optionally Shows:

- **Column summaries**: sum, average, count for numeric columns (e.g., "Σ 24,500 EUR")
- **Selection count** (when rows selected): "5 selected" with bulk action buttons

### Layout:

```
┌──────────────────────────────────────────────────────────────────┐
│ 1,247 items · 45 filtered · 5 selected  [Delete] [Export]  Σ €24,500 │
└──────────────────────────────────────────────────────────────────┘
```

Left: counts and status. Right: aggregates and bulk actions.

---

## Sticky First Column

When the table scrolls horizontally (many columns):

- Identity column (name, title) stays fixed
- Subtle shadow on right edge indicates floating above scrolled content
- User always knows WHICH ROW they're looking at

---

## Toolbar

Minimal — only search and primary action. Filters live on column headers.

```
┌─────────────────────────────────────────────────────────────────┐
│ [🔍 Search documents...]                          [+ Create]   │
└─────────────────────────────────────────────────────────────────┘
```

### Search

- Single text input, left side
- Searches across all text columns (client-side, from IndexedDB)
- Instant filtering for local data (IndexedDB/DOM). Debounce 300ms + minimum 2 characters only for HTTP API search.
- Clear button (×) when text is present
- Keyboard shortcut: `/` focuses search
- Search + column filters work together (AND logic)
- Result count shown in sticky footer ("45 of 1,247")

### Primary Action

- Create/Add button, right side
- Always visible regardless of scroll position

---

## Row Behavior

### Row Click

- If detail page exists: clicking the row navigates to it
- Entire row is the click target
- Exception: checkboxes, action buttons, links within the row don't trigger navigation
- Cursor changes to pointer on hover
- Subtle background change on hover

### Row Selection

- Checkbox column (first column, before identity column)
- Header checkbox: select all visible (filtered) rows
- Selected rows have tinted background
- Selection count in sticky footer with bulk actions
- Shift+click: range select
- Selection persists across sort/filter changes

### Row Actions

- Rightmost column
- 1-2 actions: inline icon buttons (edit, delete)
- 3+ actions: overflow menu (⋯)
- Actions column doesn't sort and has minimal header

---

## Column Types and Alignment

| Type | Alignment | Display |
|------|-----------|---------|
| Text | Left | Truncate with tooltip |
| Numeric | Right | Thousands separator, monospace |
| Date | Left | Short format ("Jan 15"), full on hover |
| Status | Left or Center | Badge (dot + text + tint) |
| Boolean | Center | Icon (✓/✕) |
| Actions | Center | Icon buttons or overflow menu |
| Checkbox | Center | Checkbox input |

---

## States

### Loading (First Visit)

- Skeleton rows matching expected layout
- Header renders immediately with column names
- Footer shows "Loading..."
- Skeleton count: fill visible viewport

### Loading (Subsequent Visit)

- Data from IndexedDB renders in <50ms — no visible skeleton
- Delta sync happens silently in background
- If delta returns changes: rows update reactively

### Empty — No Data

```
┌─────────────────────────────────────────────────────┐
│ Header row (columns still visible)                  │
├─────────────────────────────────────────────────────┤
│                                                     │
│              No documents yet                       │
│   Create your first document to get started         │
│              [+ Create Document]                    │
│                                                     │
├─────────────────────────────────────────────────────┤
│ 0 items                                             │
└─────────────────────────────────────────────────────┘
```

### Empty — Filter/Search Returned Zero

```
┌─────────────────────────────────────────────────────┐
│ [Search: "xyz"]                                     │
├─────────────────────────────────────────────────────┤
│ Header row (columns visible, Status has ●)          │
├─────────────────────────────────────────────────────┤
│                                                     │
│        No results for "xyz" with current filters    │
│        Try adjusting your search or filters         │
│              [Clear all filters]                    │
│                                                     │
├─────────────────────────────────────────────────────┤
│ 0 of 1,247 items                                    │
└─────────────────────────────────────────────────────┘
```

### Error

- Error message in table body, header/footer visible
- "Something went wrong. [Retry]"
- On delta sync failure: silent (data from IndexedDB is still usable), retry on next trigger

---

## Responsive Behavior

### Desktop (>1024px)

Full table, horizontal scroll if needed, sticky first column.

### Tablet (768-1024px)

- Hide non-essential columns
- Maintain sticky header and footer
- Horizontal scroll available

### Mobile (<768px)

- **Option A: Card list** — each row becomes a card (client-facing)
- **Option B: Horizontal scroll** — full table, scrollable (admin/internal)

---

## Keyboard Navigation

| Key | Action |
|-----|--------|
| `/` | Focus search input |
| `↑` `↓` | Move row focus |
| `Enter` | Open focused row |
| `Space` | Toggle selection |
| `Shift+Click` | Range select |
| `Escape` | Clear search / deselect all |
| `Home` | Scroll to first row |
| `End` | Scroll to last row |

---

## Anti-Patterns

- **Pagination** — breaks mental model, prevents cross-boundary viewing
- **"Load more" button** — inferior to virtual scroll
- **Server-side sort/filter/search for small datasets** — if it fits in IndexedDB, do it client-side
- **Blade rendering table rows** — SSR renders the shell, JS renders data
- **Two requests on first load** (SSR data + JS data) — pick one source of truth
- **Toolbar filters separate from columns** — filters belong on the column they filter
- **Sort inside filter dropdown** — sort is one-click toggle, filter is dropdown. Different frequency, different UI.
- **Clickable row AND "View" button** — redundant
- **Column headers that don't indicate sortability** — sortable columns must look interactive
- **Selection that resets on filter/sort** — selection is sacred
- **Hidden scrollbar** — scrollbar is information (position in dataset)
- **Delta sync on every mount regardless of staleness** — check threshold first
- **Silent conflict overwrites** — notify user when their data was modified by someone else
