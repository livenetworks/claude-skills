# Chip

> Canonical docs: `docs/css/chip.md`
> Source: `scss/config/mixins/_chip.scss` + `scss/components/_chip.scss`

---

## Decision: chip vs status-badge vs button

| Component | Role |
|---|---|
| `chip` | Removable filter token / selected value. Interactive (optional close). |
| `status-badge` | Read-only state indicator. Never interactive. |
| `button` | Primary action trigger. Full affordance. |
| `pill` | Radio/checkbox-backed mutually-exclusive option. |

Use chip when a selection or filter value needs to be displayed AND removed by the user. Use status-badge for "Approved / Draft / Obsolete" state labels that cannot be interacted with.

---

## HTML pattern

```html
<!-- Plain chip (passive label) -->
<span data-ln-chip>Draft</span>

<!-- Dismissible chip (active filter token) -->
<span data-ln-chip>
	Quality Manual
	<button type="button" aria-label="Remove Quality Manual filter">
		<svg class="ln-icon" aria-hidden="true"><use href="#ln-x"></use></svg>
	</button>
</span>

<!-- Tone variants -->
<span data-ln-chip="success">Approved</span>
<span data-ln-chip="warning">Pending</span>
<span data-ln-chip="error">Rejected</span>
<span data-ln-chip="info">Draft</span>
```

---

## Tone variants

| Attribute value | Background | Text |
|---|---|---|
| (none) | `--color-neutral-100` | Primary text |
| `success` | Success 12% tint | Success token |
| `warning` | Warning 12% tint | Warning token |
| `error` | Error 12% tint | Error token |
| `info` | Info 12% tint | Info token |

---

## Dismissible pattern

The close `<button>` inside a chip uses `all: unset` to strip browser defaults. The mixin explicitly restores `:focus-visible { @include focus-ring; }` so keyboard users retain a visible focus indicator. Always provide a descriptive `aria-label` — "Remove" alone is ambiguous when multiple chips are present.

---

## Project usage

```scss
// Default selector is applied automatically via data attribute.
// For a custom selector:
.document-tag { @include chip; }
```
