# ln-ashlar — Status Badge

Inline semantic indicator: colored dot + label text. Used for entity status, live states, and filterable labels.

Sources: `scss/config/mixins/_status-badge.scss`, `scss/components/_status-badge.scss`, `docs/css/status-badge.md`.

---

## Canonical HTML

```html
<!-- Default (info color) -->
<span class="badge">Draft</span>

<!-- Semantic variants -->
<span class="badge success">Active</span>
<span class="badge warning">Pending</span>
<span class="badge error">Blocked</span>
<span class="badge info">In Review</span>
<span class="badge neutral">Archived</span>

<!-- Live pulse — real-time indicator -->
<span class="badge success live">Connected</span>
<span class="badge warning live">Syncing</span>

<!-- Clickable — on <button> -->
<button class="badge error">Blocked</button>
```

## Variants

| Class | Color token | Use |
|---|---|---|
| *(none)* | `--color-info` (default) | General / neutral |
| `.success` | `--color-success` | Active, confirmed, complete |
| `.warning` | `--color-warning` | Pending, expiring, needs attention |
| `.error` | `--color-error` | Failed, blocked, critical |
| `.info` | `--color-info` | Draft, informational |
| `.neutral` | `--fg-muted` | Archived, inactive, disabled |

Note: "danger" is not a variant name — the correct class is `.error`.

## Live pulse

`.badge.live` adds a pulsing keyframe animation to the dot (`badge-pulse`). Gate applies `@include motion-safe` internally — no extra wrapper needed.

Use for ongoing / real-time states (WebSocket connected, background sync running, live feed). Do not use `.live` for static status that merely happens to be "active".

## Button badge

Place the `badge` classes on a `<button>` element for a clickable badge. Hover and active states are applied automatically. Use for filterable status labels or togglable states.

## Color override

All badge parts (dot, text, background tint) derive from `--color-primary`. Override that token on the element or a parent to create a custom variant:

```scss
// Project SCSS
.badge.premium { --color-primary: var(--color-gold); }
```

## Accessibility

- The badge's visible text IS the status label. Do not rely on color alone.
- Never use an icon-only badge — the label must always be readable.
- If the badge is used inside a table cell with a separate column header that names the status, the text label can be visually hidden but must remain in DOM.
- A `<button>` badge is keyboard-focusable and receives the standard focus ring automatically.

## Status badge vs chip vs plain text

| Pattern | Use when |
|---|---|
| **Status badge** | Entity has a defined status lifecycle (draft, active, archived). Status is the primary signal. |
| **chip** (`data-ln-chip`) | A removable tag, filter token, or multi-select value. Not a status — more like a label or category. |
| **Plain text** | No color semantic needed, status is implied by context. |

Chips support `data-ln-chip="success|warning|error|info"` tone variants but they are not interchangeable with badges — chips carry a remove button and are used in multi-value inputs.

## Project selector pattern

```scss
// Apply the mixin to your own selector
#status-cell span     { @include badge; }
#status-cell .active  { --color-primary: var(--color-success); }
#status-cell .expired { --color-primary: var(--color-error); }
```
