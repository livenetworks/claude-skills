# Skill: Density system

Decision guide for using `[data-density="compact"]`. Full docs: `docs/css/density.md`, `scss/config/_density.scss`.

## What it is

A single CSS attribute that re-tunes the `--density-*` token scale at the CSS variable layer. No per-component rules, no JS, no class toggling. Components that consume `--density-*` tokens shrink automatically. Added in ln-acme v1.2.

## Activation

### Global (whole page compact)

```html
<html data-density="compact">
```

### Scoped (one region compact, rest comfortable)

```html
<div data-density="compact">
	<!-- only this subtree is compact -->
</div>
```

Density is a normal CSS custom property cascade — it applies at any DOM scope. Nested sections inherit from their parent. You can also re-expand a section inside a compact parent with `data-density="comfortable"` (re-defines tokens back to `:root` defaults).

Comfortable is the default — no attribute needed for normal mode.

## Token reference

All tokens defined in `scss/config/_density.scss`. Components consume these; the compact override re-tunes them all in one place.

| Token | Comfortable | Compact | Primary consumers |
|---|---|---|---|
| `--density-pad-xs` | `0.25rem` | `0.125rem` | reserved |
| `--density-pad-sm` | `0.5rem` | `0.375rem` | input `py`, table cell `py`, panel header `py` |
| `--density-pad-md` | `1rem` | `0.625rem` | input `px`, table cell `px`, card body `p` |
| `--density-pad-lg` | `1.5rem` | `1rem` | stat-card outer padding |
| `--density-gap-sm` | `0.5rem` | `0.375rem` | reserved |
| `--density-gap-md` | `0.75rem` | `0.5rem` | section-card footer button gap |
| `--density-gap-lg` | `1rem` | `0.75rem` | reserved |
| `--density-row-h` | `2.75rem` | `2.25rem` | table `tbody tr` min-height |
| `--density-row-h-sm` | `2.25rem` | `1.875rem` | reserved |
| `--density-font-body` | `var(--text-body-md)` | `var(--text-body-sm)` | table `td` font-size |
| `--density-lh-body` | `var(--lh-body-md)` | `var(--lh-body-sm)` | table `td` line-height |

## What reacts vs what does not

**Reacts:** tables, form inputs/textarea/select, cards (`section-card`), panel headers, stat card.

**Deliberately exempt:**

| Component | Reason |
|---|---|
| Buttons | WCAG 2.5.5 hit target — minimum 24×24px must not be violated by density. This is a design decision, not an oversight. |
| Modals, toasts | Focused interruption surfaces; cramping them saves no data-density screen space. |
| Page header, sidebar nav | Fixed visual hierarchy; density semantics are ambiguous for nav. |
| Form labels, column headers | Structural — must stay legible at any density. |
| Interactive controls (checkboxes, radios, pills) | Same a11y reasoning as buttons. |

## Anti-pattern: per-component compact selectors

Do NOT write:

```scss
[data-density="compact"] .my-component {
	padding: 0.5rem; // wrong
}
```

This explodes specificity and duplicates the compact override in every component. The correct fix: make the component consume an existing `--density-*` token. The override flows through the cascade automatically.

```scss
.my-component {
	padding: var(--density-pad-md); // correct — reacts to density for free
}
```

## Orthogonality with dark mode

`data-density` and `data-theme` are independent attributes on orthogonal token namespaces (`--density-*` vs `--color-*`). They compose without conflict:

```html
<html data-theme="dark" data-density="compact">
```

Compact dark mode works as expected — no extra rules needed.

## Adding a new component to density

1. Identify the component's spacing rules (padding, gap, min-height).
2. Classify each rule: **structural** (border, label, control target) or **content** (cell padding, card body)?
3. Replace content rules with the matching `var(--density-pad-*)` / `var(--density-gap-*)` token.
4. Leave structural rules as literal values.
5. Add the component to the "What reacts" table in `docs/css/density.md`.

Do not define new `--density-*` tokens per component — the existing scale (4 padding + 3 gap + 2 row heights + body font) is intentionally fixed.
