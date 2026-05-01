# ln-ashlar — Empty State Implementation

> HOW to implement empty states with ln-ashlar. For WHAT an empty state must contain → global ui/components/empty-state.md.
> Full attribute/token reference → `docs/css/empty-state.md` in the ln-ashlar repo.

---

## Attribute Component

Use `data-ln-empty-state` on any container. The framework applies `@include empty-state` automatically via the default selector `[data-ln-empty-state]` in `scss/components/_empty-state.scss`.

---

## Two Sub-Types

### `no-data` — list has never had items (onboarding moment)

Show an inviting message and the primary "create" action. Use when the dataset is genuinely empty — no items exist yet.

```html
<div data-ln-empty-state="no-data">
	<svg class="ln-icon ln-icon--xl" aria-hidden="true"><use href="#ln-folder"></use></svg>
	<h3>No documents yet</h3>
	<p>Upload your first document to get started.</p>
	<button type="button">Upload document</button>
</div>
```

### `no-results` — filter/search returned zero matches

Show "no matches" messaging and a clear-filter action. Use when items exist but the current query excludes them all.

```html
<div data-ln-empty-state="no-results">
	<svg class="ln-icon ln-icon--xl" aria-hidden="true"><use href="#ln-search"></use></svg>
	<h3>No matches</h3>
	<p>Try a different search or clear your filters.</p>
	<button type="button">Clear filters</button>
</div>
```

The attribute value (`no-data` / `no-results`) is not consumed by ln-ashlar itself — it exists purely so project CSS can target the distinction if needed.

---

## HTML Structure

- **Icon** — `<svg class="ln-icon ln-icon--xl">` (4rem, `--color-neutral-400`)
- **Title** — `<h3>` — typography role `heading-sm`, `--color-text-primary`
- **Description** — `<p>` — typography role `body-md`, `--color-text-secondary`
- **Action** — `<button>` or `<a>` — `margin-top: 0.5rem`

All children are optional. Include what makes sense for the context.

The mixin centers children vertically and horizontally in a column, max-width 28rem, with 1rem gap between items.

---

## When to Use the Attribute vs. Custom Layout

| Situation | Approach |
|-----------|----------|
| Standard list / table empty state | `data-ln-empty-state="no-data|no-results"` |
| Non-standard container (sidebar, card, custom shell) | `@include empty-state` on project selector |

Custom selector example:

```scss
// Project selector that doesn't match [data-ln-empty-state]
#documents .empty-panel { @include empty-state; }
```

Do NOT add `data-ln-empty-state` just to get the mixin applied if the element is not semantically an empty-state container. Use `@include empty-state` directly instead.
