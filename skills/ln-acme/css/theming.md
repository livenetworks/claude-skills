# ln-acme — Theming (Dark Mode)

CSS-only dark mode and consumer re-theming. No JavaScript required for theme switching.

Sources: `scss/config/_theme.scss`, `docs/css/theming.md`.

---

## Activation

Three paths — any one is sufficient. CSS resolves them in this order:

### 1. Explicit attribute (always wins)

```html
<html data-theme="dark">
```

Force dark regardless of OS preference. Store the user's choice in `localStorage` or a cookie; the library does not persist it.

### 2. System preference (automatic)

```html
<html>
```

When no `data-theme` is set, ln-acme applies dark tokens automatically via `@media (prefers-color-scheme: dark)` targeting `:root:not([data-theme="light"])`.

### 3. Force light (opt-out of auto)

```html
<html data-theme="light">
```

Keeps light mode even when the OS is dark. Use when the user has explicitly chosen light.

## How tokens remap

Dark mode works by **reassigning the same token names** to different values. Components consume `--color-bg-primary`, `--color-text-primary`, etc. — they do not change. The token values change.

The neutral scale is fully inverted (step 50 ↔ step 900). Because light mode uses `--color-white` as the top elevation layer (not a neutral step), the three surface tokens are restated explicitly so the elevation ladder remains correct:

```
--color-bg-body:      220 16%  9%   (darkest)
--color-bg-primary:   220 16% 13%
--color-bg-secondary: 220 16% 17%   (lightest, most elevated)
```

Shadows switch from cool-tinted to solid black with higher alpha.

## Anti-pattern — never do this

```scss
// WRONG — hardcodes a dark override on the component
[data-theme="dark"] .my-component {
	color: hsl(220 20% 90%);
	background: hsl(220 16% 13%);
}
```

If a component looks wrong in dark mode, a hardcoded color (not a token reference) is almost always the cause. Fix the component to use the correct semantic token; it will then work in both modes automatically.

```scss
// RIGHT — token reference, works in both modes
.my-component {
	color: hsl(var(--color-text-primary));
	background: hsl(var(--color-bg-primary));
}
```

## Orthogonality with density

Dark mode and density (`data-density="compact|comfortable|spacious"`) are fully independent. Both are resolved via CSS custom properties and compose freely:

```html
<html data-theme="dark" data-density="compact">
```

No special handling needed in component SCSS.

## Consumer re-theming

Override any token at any scope — not just root:

```scss
// Global brand color
:root { --color-primary: 340 75% 52%; }

// Section-specific
.print-preview { --color-bg-body: var(--color-neutral-100); }

// Custom named theme
[data-theme="high-contrast"] {
	--color-neutral-900: 0 0% 100%;
	--color-neutral-50:  0 0% 0%;
	--color-border:      var(--color-neutral-900);
}
```

## Accessibility targets

- Body text: ≥ 7:1 (AAA)
- Secondary text: ≥ 4.5:1 (AA)
- Focus ring: ≥ 3:1 non-text (WCAG 1.4.11)

Default dark neutral inversion clears all three. Custom themes must re-verify with a contrast checker.
