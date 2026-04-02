# Search

> Filter visible content by text matching.

---

## Core Principle

`ln-search` is a pure client-side component. It filters DOM children by matching their text content against the user's query. It does not fetch data, does not know about servers or APIs. For server-side search, use a `<form>` with `ln-http`.

---

## Two Contexts

| | Client-side (ln-search) | Server-side |
|---|---|---|
| Component | `ln-search` | `<form>` + `ln-http` |
| Data source | DOM children | HTTP API |
| Timing | Instant keyup | Debounce via `data-ln-form-debounce` |
| Use case | Filter a `<ul>`, `<table>`, `<nav>`, any list | Search across entities, full-text |

---

## ln-search — Client-Side DOM Filtering

### How It Works

```
User types in input
  → ln-search reads query
  → Iterates children of target element
  → Matches textContent against query
  → Toggles hidden on non-matching children
```

Instant, zero config, zero coordinator.

### HTML Structure

```html
<input data-ln-search="user-list" placeholder="Filter users...">

<ul id="user-list">
    <li>Dalibor Sojic</li>
    <li>Marko Petrovski</li>
    <li>Jane Smith</li>
</ul>
```

- `data-ln-search="target-id"` — points to the element whose children get filtered
- Works on any parent: `<ul>`, `<table>` (filters `<tr>`), `<nav>`, `<div>`
- Matches against `textContent` of each child
- Non-matching children get `hidden` toggled
- Clear button (×) when text is present
- `/` keyboard shortcut to focus (when no input is active)

### Attributes

| Attribute | On | Description |
|---|---|---|
| `data-ln-search="id"` | `<input>` | Target element ID whose children are filtered |

### Events

| Event | When | `detail` |
|---|---|---|
| `ln-search:input` | User types | `{ query }` |
| `ln-search:clear` | User clears search | `{}` |

---

## Server-Side Search

Not an ln-search concern. Use a `<form>` with auto-submit + `ln-http`.
Full spec → `form.md` (Auto-Submit section).

---

## Data Table Search

`data-ln-data-table-search` is a separate input integrated within the data table component. It queries IndexedDB via the coordinator, not the DOM. Different problem, different solution — do not mix with `ln-search`.

---

## Anti-Patterns

- **ln-search for server-side search** — ln-search is client-side DOM filtering only
- **Debounce on ln-search** — client-side filtering is instant, no debounce needed
- **Custom search logic in JS** — ln-search matches textContent, nothing more. For complex matching, use a coordinator listening to `ln-search:input`
- **ln-search on data-table** — data-table has its own integrated search mechanism
