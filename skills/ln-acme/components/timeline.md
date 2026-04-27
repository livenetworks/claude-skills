# Timeline

> Canonical docs: `docs/css/timeline.md`
> Source: `scss/config/mixins/_timeline.scss` + `scss/components/_timeline.scss`

---

## Decision: timeline vs stepper vs list

| Component | Role |
|---|---|
| `timeline` | Chronological event history (audit log, activity feed). Past events only. |
| `stepper` | Forward-looking wizard progress. User is mid-flow. |
| plain `<ul>` | Unordered items with no temporal or sequential meaning. |

Use timeline for audit logs, version history, and activity feeds where the order is temporal and no navigation is implied.

---

## HTML pattern

```html
<ol data-ln-timeline>
	<li>
		<time datetime="2026-04-14T09:32">Apr 14, 09:32</time>
		<h4>Document approved</h4>
		<p>Review completed with no outstanding issues</p>
	</li>
	<li>
		<time datetime="2026-04-13T14:18">Apr 13, 14:18</time>
		<h4>Revision submitted</h4>
		<p>Draft saved with 3 changes</p>
	</li>
</ol>
```

---

## Slot elements

| Element | Typography role | Color |
|---|---|---|
| `<time>` | `caption` | `--fg-muted` |
| `<h4>` | `title-sm` | `--color-fg` |
| `<p>` | `body-sm` | `--fg-muted` |

All three are optional — a minimal entry needs only `<h4>`.

---

## Rail and bullet

- Vertical 2px rail drawn via `::before` on `<ol>`, centered on the bullet column.
- Bullets are 12px primary-coloured circles via `::before` on each `<li>`.
- A 3px ring in `--color-bg-primary` separates bullet from rail, adapting to dark mode via the surface token.

---

## Accessibility

- Use `<ol>` to convey sequence.
- Always include `datetime` attribute on `<time>` for machine-readable timestamps.
- Order entries newest-first for audit log context.

---

## Project usage

```scss
// Default selector via attribute — no extra CSS needed.
// For a custom selector:
#audit-log { @include timeline; }
```
