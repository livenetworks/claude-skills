# Page Header

> Canonical docs: `docs/css/page-header.md`
> Source: `scss/config/mixins/_page-header.scss` + `scss/components/_page-header.scss`

---

## Decision: page-header vs custom markup

Always use `[data-ln-page-header]` (or `@include page-header`) for the top-of-page title area. Do NOT build ad-hoc heading + action rows per page — they diverge in spacing and break responsive layout. The mixin ensures consistent breadcrumb / title / actions layout with a single container-query breakpoint.

---

## HTML pattern

```html
<!-- Parent must establish a container context for the responsive query -->
<div style="container-type: inline-size;">
	<header data-ln-page-header>
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
</div>
```

---

## Slots

| Slot selector | Grid area | Purpose |
|---|---|---|
| `> nav` | `breadcrumbs` | Breadcrumb navigation |
| `> div:has(> h1)` | `title` | Title + optional `<p>` subtitle |
| `> div:has(> button)` or `> div:has(> a)` | `actions` | Action buttons |

The `:has()` selector maps divs to areas automatically — order in the DOM does not matter.

---

## Responsive (container query)

- **Below 880px:** stacks `breadcrumbs → title → actions` vertically.
- **880px+:** breadcrumbs span full width on top; title left, actions right (`1fr auto`).

The query fires against the nearest `container-type: inline-size` ancestor. If the project layout already sets this on the main content column, no extra wrapper is needed.

---

## Project usage

```scss
// Default selector via attribute.
// For a custom selector:
#document-detail > header { @include page-header; }

// Ensure the layout context is established:
#document-detail { @include container(docdetail); }
```
