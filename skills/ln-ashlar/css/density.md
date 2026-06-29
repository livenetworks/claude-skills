# Skill: Density system

Attribute-based density system (`[data-density]`). Full docs: `docs/css/density.md`,
`scss/config/_density.scss`.

## The 4 tiers — inverted default

| Tier | Activation | Body | Header | Sidebar | Row h |
|---|---|---|---|---|---|
| Dense (default) | `:root` — no attribute needed | 14px | 3.25rem | 14.5rem | 36px |
| `compact` | `[data-density="compact"]` | same as dense | same | same | 36px |
| `comfortable` | `[data-density="comfortable"]` | 16px | 3.5rem | 16rem | 44px |
| `spacious` | `[data-density="spacious"]` | 18px | 4rem | 17.5rem | 48px |

The `:root` base is the **dense** tier — the DocuFlow-tuned scale (14px body, compact
chrome). Density only goes UP from there. There is no class; only the `[data-density]`
attribute shifts the scale.

`compact` is an explicit handle for the dense base so a settings switcher can write
a single attribute across all tiers (including returning to dense) rather than removing
the attribute to reset.

## Activation

```html
<!-- Global comfortable -->
<html data-density="comfortable">

<!-- Global spacious -->
<html data-density="spacious">

<!-- Scope dense inside a comfortable page -->
<table data-density="compact">

<!-- Scope comfortable inside a spacious page -->
<aside data-density="comfortable">
```

Density is an explicit user choice (settings toggle). It is NEVER auto-switched by
viewport — viewport breakpoints handle layout; density handles information density
inside that layout.

## What reacts

Everything reading these logical / role tokens reacts via the cascade:

- `--padding-y`, `--gap` — base rhythm
- `--text-body-md/sm`, `--lh-body-md/sm` — body text
- `--text-label-md/sm`, `--lh-label-md/sm` (label-sm and caption added to comfortable + spacious up-tiers; dense base inherits `:root`)
- `--text-caption`, `--lh-caption` (comfortable + spacious up-tiers only)
- `--text-title-md/sm`, `--lh-title-md/sm`
- `--text-heading-sm/md/lg`, `--lh-heading-sm/md/lg`
- `--text-display-sm`, `--lh-display-sm`
- `--font-size`, `--line-height` (explicit rebind — form inputs)
- `--app-header-height`, `--app-sidebar-width` — shell geometry
- `--density-row-h` — table row minimum height
- `--btn-padding-y`, `--btn-padding-x`, `--input-padding-y` — controls
- `--card-padding-y`, `--card-padding-x`
- `--table-cell-padding-y`, `--table-cell-padding-x`

Interactive controls scale upward for WCAG 2.5.5: dense base ≈38px (AA),
comfortable ≈46px (AAA), spacious ≈54px (AAA).

## What does NOT react

| Surface | Reason |
|---|---|
| Modal outer chrome | Only `max-width` declared; inner content inherits. |
| Toast | Fixed notification visual. |
| Avatar text | Tracks avatar pixel size, not density. |
| `small`, `code`, `pre` | Already at compact size. |
| Nav section dividers | Already tiny. |

## Anti-pattern: per-component density selectors

```scss
// WRONG — do not write density-specific selectors for components
[data-density="compact"] .my-component {
	padding: 0.5rem;
}

// RIGHT — make the component consume logical tokens
.my-component {
	padding: var(--padding-y) var(--padding-x);  // cascade handles it
}
```

## Anti-pattern: new `--density-*` tokens

The parallel `--density-pad-*` / `--density-gap-*` scale was deleted in v1.3.
Do not resurrect it. The only surviving density-named token is `--density-row-h`
(table row `min-height`) because it has no analogue in the base scale.

## Orthogonality with dark mode

`[data-density]` and `[data-theme]` live on different token namespaces and compose
without conflict:

```html
<html data-theme="dark" data-density="comfortable">
```

## Adding a new component to density

1. Replace hardcoded padding/gap rem values with `var(--padding-y)` / `var(--gap)`.
2. For role typography in a mixin, use `@include typography(role)` — this rebinds
   `--font-size`/`--line-height` at the consuming element's scope so the lazy var()
   resolves under the active density tier. The direct `font-size: var(--text-body-md)`
   form is discouraged (vocabulary direct-read, may be frozen for roles not rebound in
   all density tiers). For bare non-mixin text, `font-size: var(--font-size)` is fine.
3. Leave structural chrome (avatar px, toggle geometry, modal max-width) hardcoded.
