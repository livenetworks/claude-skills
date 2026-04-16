# Page Header

> Canonical docs: `docs/css/page-header.md`
> Source: `scss/config/mixins/_page-header.scss` + `scss/components/_page-header.scss`

---

## Decision: page-header vs custom markup

Always use `#page-header` (or `@include page-header` on a project selector) for the top-of-page title area. Do NOT build ad-hoc heading + action rows per page — they diverge in spacing and break responsive layout. The mixin ensures consistent breadcrumb / title / actions layout with a single container-query breakpoint.

**CSS-only.** There is no `ln-page-header` JS component — the `data-ln-*` prefix is reserved for JS behavior. Page headers are a layout primitive, bound to the `#page-header` singleton id.

---

## HTML pattern

```html
<main class="main">
    <header id="page-header">
        <nav aria-label="Breadcrumb">
            <ol>
                <li><a href="/">Home</a></li>
                <li aria-current="page">Quality Manual</li>
            </ol>
        </nav>
        <div>
            <h1>Quality Manual</h1>
            <p>Version 2.3 — Approved 2026-03-15</p><!-- optional subtitle -->
        </div>
        <div>
            <button type="button">Edit</button>
            <button type="submit">Publish</button>
        </div>
    </header>
</main>
```

The inner `<nav aria-label="Breadcrumb">` gets breadcrumb styling automatically via `@mixin page-header` — no need for a separate `id="breadcrumbs"` on it.

---

## Slots

| Slot selector | Grid area | Purpose |
|---|---|---|
| `> nav` | `breadcrumbs` | Breadcrumb navigation (auto-styled) |
| `> div:has(> h1)` | `title` | Title + optional `<p>` subtitle |
| `> div:has(> button)` or `> div:has(> a)` | `actions` | Action buttons |

The `:has()` selector maps divs to areas automatically — order in the DOM does not matter.

---

## Responsive (container query)

- **Below 880px:** stacks `breadcrumbs → title → actions` vertically.
- **880px+:** breadcrumbs span full width on top; title left, actions right (`1fr auto`).

The layout flip is viewport-driven (`@media (min-width: 880px)`) — self-contained with no parent container-context requirement.

---

## Project usage

```scss
// Library default — #page-header is already bound.
// Ensure the layout context is established:
.main { @include container(shell); }

// Secondary page header or a different semantic selector:
#document-detail > header { @include page-header; }
```
