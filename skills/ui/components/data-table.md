# Data Table

> The primary component for displaying, navigating, and acting on structured data.

## Core Principle

A data table is a VIEWPORT into a dataset — not a paginated slice. The user works with ALL their data through a scrollable window. Data lives in a client-side cache, sort/filter/search are instant, and the system syncs with the server in the background.

## Anatomy

```
┌─────────────────────────────────────────────────────────────────┐
│ [🔍 Search...]                                     [+ Create]   │ ← Toolbar
├────┬──────────────────┬────────────┬──────────┬────────┬───────┤
│ ☐  │ Name          ⇅  │ Status ▾●⇅ │ Category │ Date ↑ │       │ ← Sticky header
├────┼──────────────────┼────────────┼──────────┼────────┼───────┤
│ ☐  │ ISO 27001 Policy │ ● Approved │ Policy   │ Jan 15 │ ⋯    │
│    │                  │            │          │        │       │
│    │  (virtual scroll — renders visible rows from local cache) │
│    │                  │            │          │        │       │
├────┴──────────────────┴────────────┴──────────┴────────┴───────┤
│ 1,247 items · 45 filtered · 5 selected  [Delete]   Σ €24,500  │ ← Sticky footer
└─────────────────────────────────────────────────────────────────┘
```

## Requirements

### Data Layer Separation
- Table is PURE UI — receives data, renders, emits events
- Data layer (client-side cache) handles storage, sync, mutations
- Coordinator (project JS) connects them via events
- This separation means table works with any data source

### Loading Strategy
- **SSR mode (default):** server renders the full table with data rows — the user never waits for data to appear
- **Client-cache mode:** server renders the shell only; a loader covers the shell until the store hydrates (no placeholder rows)
- First visit (client-cache): fetch full dataset → store in cache → render
- Subsequent visits (client-cache): read cache (<50ms) → render → delta sync in background
- Delta sync: server returns only changed/created/deleted records since last sync

### Toolbar
- Search input + primary action button (Create) only
- No filters in toolbar — filters live in column headers

### Sticky Header
- Column names always visible during scroll
- Per-column sort toggle (click: unsorted → ascending → descending → unsorted)
- Per-column filter dropdown (checkbox list of unique values)
- Active filter indicator: dot on filter icon + pill in footer

### Sticky Footer
- Total count + filtered count
- Column aggregates if applicable (sum, average)
- Bulk action bar (when rows selected)

### Virtual Scroll
- All data in client cache — not paginated
- Renders only visible rows + buffer
- Consistent row heights for predictable scrolling
- Scroll position preserved on back-navigation

### Row Selection + Bulk Actions
- Checkbox column (leftmost)
- Header checkbox selects visible (filtered) rows
- "Select all N" banner for full-dataset operations
- Bulk action bar appears at bottom when selection active
- Destructive bulk actions always require modal confirm with count

### Row Actions
- Row click = navigate to detail (most common action)
- Action buttons in last column (stop propagation — don't also navigate)
- Always visible (no hover-reveal for touch accessibility)
- Overflow menu for 3+ actions per row

### Keyboard Navigation
- ↑/↓ move row focus, Enter opens focused row
- Space toggles row checkbox
- Home/End jump to first/last row

### Optimistic Mutations
- Update cache + table immediately before server responds
- Server success → done (already up to date)
- Server error → revert cache → revert table → show error

## States

| State | What user sees |
|-------|---------------|
| SSR mode | Full table with rows on first paint (no loading state needed) |
| Client-cache, first visit | Loader covers table shell until store hydrates |
| Client-cache, cached | Data from cache (<50ms), delta sync in background |
| Data | Rows with sort/filter/search active |
| Empty (no data) | "No items yet" + Create CTA |
| Empty (filter/search) | "No matching items" + Clear filters CTA |
| Error | Toast or inline error with retry |

## Anti-Patterns
- Pagination instead of virtual scroll
- Placeholder / shimmer rows — never fake data that doesn't exist yet (SSR already has real rows; client-cache mode uses a loader on the shell)
- Filters in toolbar instead of column headers
- "View" button when row could be clickable
- Hover-reveal actions (inaccessible on touch)
- Full-page loading indicator instead of a scoped loader on the table shell
- Sorting/filtering on server when dataset fits in client cache

> For implementation in a specific design system → query that system's own documentation (in this project, via the ln-ashlar routing skill). This file covers WHAT the component must contain, not how any one library spells it.
