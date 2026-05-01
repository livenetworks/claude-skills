# ln-ashlar — Stat Card

Dashboard KPI tile. Large numeric value, uppercase label, optional trend indicator.

Sources: `scss/config/mixins/_stat-card.scss`, `scss/components/_stat-card.scss`, `docs/css/stat-card.md`.

---

## Canonical HTML

```html
<article data-ln-stat-card>
	<p data-ln-stat-label>Total Documents</p>
	<p data-ln-stat-value>1,247</p>
	<p data-ln-stat-trend="up">
		<svg class="ln-icon" aria-hidden="true"><use href="#ln-arrow-up"></use></svg>
		12% from last month
	</p>
</article>
```

All three slots are optional. Omit `data-ln-stat-trend` if no trend is available.

## Data attributes (slots)

| Attribute | Element | Purpose |
|---|---|---|
| `data-ln-stat-card` | `<article>` | Component root — applies `@include stat-card` |
| `data-ln-stat-label` | `<p>` | Uppercase label — `label-md` role, secondary color |
| `data-ln-stat-value` | `<p>` | Big number — `heading-lg` role, tabular-nums |
| `data-ln-stat-trend` | `<p>` | Trend row — icon + text, colored by direction |

## Trend variants

| Value | Color |
|---|---|
| `data-ln-stat-trend="up"` | `--color-success` (green) |
| `data-ln-stat-trend="down"` | `--color-error` (red) |
| `data-ln-stat-trend="neutral"` | `--fg-muted` (grey) |

Pair with a Tabler outline icon (`ln-icon`) at `1rem` size. Icon is `aria-hidden`.

## Internals

The mixin (`@include stat-card`) provides:
- `flex-col`, `gap(0.25rem)`, `p(var(--density-pad-lg))` — density-aware padding
- `bg-primary` surface, `rounded-lg`, `shadow-sm`, `border`

Padding uses `--density-pad-lg` so the card automatically adapts to the `.density-compact` class.

## Grid layout

Stat cards are displayed in a grid. Use `@include container` for the wrapper:

```scss
#dashboard-kpis {
	@include container(kpigrid);
	display: grid;
	grid-template-columns: 1fr;
	@include gap(1rem);

	@container kpigrid (min-width: 480px) {
		grid-template-columns: repeat(2, 1fr);
	}
	@container kpigrid (min-width: 880px) {
		grid-template-columns: repeat(4, 1fr);
	}
}
```

## Stat card vs full card

- Use **stat-card** for a single headline metric with an optional trend (dashboard shelf, KPI row).
- Use **card** (`@include card`) for multi-section content with a header, body, footer structure.
- Stat-card is intentionally compact — do not add secondary lists or tables inside it.

## Project selector pattern

```scss
// Apply the mixin to your own selector instead of the data attribute
#summary-panel .metric { @include stat-card; }
```
