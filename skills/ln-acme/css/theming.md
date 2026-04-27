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

Dark mode rebinds **vocabulary** tokens at theme `:root`. Primitives
(`--color-bg`, `--color-fg`, `--color-border`, `--shadow`) wire to
vocabulary, so every mixin adapts automatically:

```scss
[data-theme="dark"] {
	// Background vocabulary
	--bg-base:     hsl(220 16% 13%);
	--bg-elevated: hsl(220 16% 17%);
	--bg-sunken:   hsl(220 16% 20%);
	--bg-recessed: hsl(220 16%  9%);

	// Foreground vocabulary
	--fg-default: hsl(0 0% 95%);
	--fg-muted:   hsl(220  9% 60%);
	--fg-subtle:  hsl(218 11% 52%);

	// Border vocabulary
	--border-subtle:       hsl(220 14% 20%);
	--border-strong:       hsl(220 13% 36%);
	--border-strong-hover: hsl(218 11% 52%);
}
```

Primitives default to vocabulary at `:root`:
```scss
:root {
	--color-bg:     var(--bg-base);
	--color-fg:     var(--fg-default);
	--color-border: var(--border-subtle);
	--shadow:       var(--shadow-resting);
}
```

No per-component dark declarations needed — every mixin reads the
primitives, primitives read vocabulary, vocabulary is rebinding in dark.

## Anti-pattern — never do this

```scss
// WRONG — hardcodes a dark override on the component (specificity hack)
[data-theme="dark"] .my-component {
	color: hsl(220 20% 90%);
	background: hsl(220 16% 13%);
}
```

If a component looks wrong in dark mode, a hardcoded color (not a token
reference) is almost always the cause. Fix the component to rebind the
primitive from vocabulary.

```scss
// RIGHT — rebind primitive; theme vocabulary shift flows through
.my-component {
	--color-bg: var(--bg-recessed);
	color:      var(--color-fg);
	background: var(--color-bg);
}
```

## Orthogonality with density

Dark mode and density (`.density-compact` class) are fully independent.
Both are resolved via CSS custom properties and compose freely:

```html
<html data-theme="dark" class="density-compact">
```

## Consumer re-theming

Override vocabulary at any scope. Prefer vocabulary rebinds for
component-facing changes:

```scss
// Global brand color (semantic primitive)
:root { --color-primary: 340 75% 52%; }

// Scoped surface change (rebind primitive on scope)
.print-preview { --color-bg: var(--bg-base); }

// Custom named theme — rebind vocabulary at theme :root
[data-theme="high-contrast"] {
	--fg-default:    hsl(0 0% 100%);
	--bg-base:       hsl(0 0% 0%);
	--border-strong: hsl(0 0% 100%);
}
```

Vocabulary tokens: `--bg-base`, `--bg-elevated`, `--bg-sunken`,
`--bg-recessed`, `--fg-default`, `--fg-muted`, `--fg-subtle`,
`--border-subtle`, `--border-strong`, `--border-strong-hover`,
`--shadow-resting`, `--shadow-floating`, `--shadow-overlay`.

## Accessibility targets

- Body text: ≥ 7:1 (AAA)
- Secondary text: ≥ 4.5:1 (AA)
- Focus ring: ≥ 3:1 non-text (WCAG 1.4.11)

Default dark vocabulary rebind clears all three. Custom themes must re-verify with a contrast checker.
