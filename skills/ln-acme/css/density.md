# Skill: Density system

Decision guide for using the `.density-compact` class. Full docs:
`docs/css/density.md`, `scss/config/_density.scss`.

## What it is

A single CSS class that overrides base design tokens (`--size-*`,
`--text-body-*`, `--text-label-*`, `--text-title-*`, `--text-heading-*`,
`--text-display-sm`, `--density-row-h`) on the element where it's
applied. Every descendant that reads those tokens shrinks via the
cascade. No per-component rules, no parallel token scale, no JS.
Refactored in v1.3 from the previous `--density-*` parallel scale.

## Activation

### Global

```html
<html class="density-compact">
```

### Scoped

```html
<div class="density-compact">
	<!-- only this subtree is compact -->
</div>
```

Density is a normal CSS custom property cascade — it applies at any
DOM scope. Nested elements inherit from their nearest `.density-compact`
ancestor, or from `:root` if none.

Comfortable is the default — no class needed.

## What reacts vs what does not

**Reacts (via base-token override):** tables, forms, cards, stat-card,
nav links, breadcrumbs, alerts, banners, tabs, all headings (`h1`–`h6`),
body paragraphs, body chrome, and any mixin reading the logical
`--font-size` / `--line-height` (form inputs, menu-items rows, etc.)
— the compact block explicitly rebinds those alongside
`--text-body-md`. See `docs/css/density.md` §"Explicit `--font-size`
rebind" for why the explicit rebind is required.

**Deliberately exempt (hardcoded rem or raw typography scale):**

| Surface | Reason |
|---|---|
| Buttons, pills | WCAG 2.5.5 hit-target floor — cannot shrink. |
| Modal outer chrome | Only `max-width` declared; inner content inherits. |
| Toast | Fixed notification visual. |
| Page-header outer padding | Structural rhythm; inner h1 does react. |
| Sidebar outer chrome | Layout primitives; inner nav link text does react. |
| `small`, `code`, `pre` | Already at compact size. |
| Avatar text | Tracks avatar pixel size, not density. |
| Nav section dividers | Already tiny. |

## Anti-pattern: per-component compact selectors

Do NOT write:

```scss
.density-compact .my-component {
	padding: 0.5rem; // wrong
}
```

Correct fix: make the component consume base tokens.

```scss
.my-component {
	padding: var(--size-md); // correct — cascade handles it
}
```

## Anti-pattern: new `--density-*` tokens

The parallel `--density-pad-*` / `--density-gap-*` / `--density-font-body`
scale was DELETED in v1.3. Do not resurrect it. Components react by
consuming base tokens (`--size-*`, `--text-body-md`, role typography
tokens). The only surviving density-named token is `--density-row-h` —
used for table row `min-height` because it has no analogue in the base
scale.

## Orthogonality with dark mode

`.density-compact` and `data-theme` live on different token namespaces
(`--size-*` / `--text-*` vs `--color-*`). They compose without conflict:

```html
<html data-theme="dark" class="density-compact">
```

## Adding a new component to density

1. Replace hardcoded padding/gap rem values with `var(--size-*)`.
2. Replace `@include text-base` / `@include text-sm` (raw scale) with
   `font-size: var(--text-body-md); line-height: var(--lh-body-md);`
   (or the matching role token) for content text.
3. Leave structural chrome hardcoded.

That's it. The component reacts to density for free, via the cascade.
