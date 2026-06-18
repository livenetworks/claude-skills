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

The binding is the CSS class `.ln-chip` — not a data attribute.
Tone variants are modifier classes on the same element.

```html
<!-- Plain chip (passive label) -->
<span class="ln-chip">Draft</span>

<!-- Dismissible chip (active filter token) -->
<span class="ln-chip">
	Quality Manual
	<button type="button" aria-label="Remove Quality Manual filter">
		<svg class="ln-icon" aria-hidden="true"><use href="#ln-x"></use></svg>
	</button>
</span>

<!-- Tone variants — modifier class, not attribute value -->
<span class="ln-chip success">Approved</span>
<span class="ln-chip warning">Pending</span>
<span class="ln-chip error">Rejected</span>
<span class="ln-chip info">Draft</span>
```

---

## Tone variants

| Class | Background | Text |
|---|---|---|
| (none) | `--bg-recessed` (neutral) | `--color-fg` |
| `.ln-chip.success` | `hsl(var(--color-success) / 0.12)` | `hsl(var(--color-success))` |
| `.ln-chip.warning` | `hsl(var(--color-warning) / 0.12)` | `hsl(var(--color-warning))` |
| `.ln-chip.error` | `hsl(var(--color-error) / 0.12)` | `hsl(var(--color-error))` |
| `.ln-chip.info` | `hsl(var(--color-info) / 0.12)` | `hsl(var(--color-info))` |

---

## Dismissible pattern

The close `<button>` inside a chip uses `all: unset` to strip browser defaults. The mixin explicitly restores `:focus-visible { @include focus-ring; }` so keyboard users retain a visible focus indicator. Always provide a descriptive `aria-label` — "Remove" alone is ambiguous when multiple chips are present.

---

## Project usage

```scss
// Default .ln-chip selector is applied automatically by scss/components/_chip.scss.
// For a custom selector:
.document-tag { @include chip; }
```
