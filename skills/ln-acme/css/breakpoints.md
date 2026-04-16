# Breakpoints

> Canonical docs: `docs/css/breakpoints.md`
> Container-query doctrine: `docs/ln-acme-container-queries.md`
> Source: `scss/config/_breakpoints.scss`

---

## Decision rule: media queries vs container queries

| Use | Scope |
|---|---|
| `@media` + `$bp-*` | App-shell layout only — header, sidebar, main column widths |
| `@container` + `$cq-*` | Components — they respond to their container, not the viewport |

Never use `@media` inside a component mixin. Components are embedded in layouts of varying widths; only a container query produces correct results regardless of where the component is placed.

---

## App-shell media breakpoints

Import: `@use 'ln-acme/scss/config/breakpoints' as *;`

| Sass variable | CSS variable | Value |
|---|---|---|
| `$bp-sm` | `--bp-sm` | 480px |
| `$bp-md` | `--bp-md` | 768px |
| `$bp-lg` | `--bp-lg` | 1024px |
| `$bp-xl` | `--bp-xl` | 1280px |
| `$bp-2xl` | `--bp-2xl` | 1536px |
| `$bp-3xl` | `--bp-3xl` | 1920px |

```scss
@use 'ln-acme/scss/config/breakpoints' as *;

.app-shell {
	display: grid;
	grid-template-columns: 1fr;

	@media (min-width: $bp-md) {
		grid-template-columns: 16rem 1fr;
	}
}
```

---

## Container-query breakpoints

| Sass variable | CSS variable | Value | Typical use |
|---|---|---|---|
| `$cq-narrow` | `--cq-narrow` | 480px | 1→2 columns in tight containers |
| `$cq-compact` | `--cq-compact` | 580px | 1→2 columns (standard) |
| `$cq-medium` | `--cq-medium` | 880px | 2→3 columns; page-header breakpoint |
| `$cq-wide` | `--cq-wide` | 1120px | 3→4 columns |

```scss
@use 'ln-acme/scss/config/breakpoints' as *;

#folders { @include container(foldersgrid); }

#folders > ul {
	display: grid;
	grid-template-columns: 1fr;

	@container foldersgrid (min-width: $cq-compact) {
		grid-template-columns: repeat(2, 1fr);
	}
	@container foldersgrid (min-width: $cq-medium) {
		grid-template-columns: repeat(3, 1fr);
	}
}
```

---

## JS consumption

All breakpoints are exposed as CSS custom properties at `:root`. Read them from JS without hardcoding pixel values:

```javascript
const bpMd = parseInt(
	getComputedStyle(document.documentElement).getPropertyValue('--bp-md')
);
```

---

## Rules

- Never hardcode breakpoint pixel values. Use the variables.
- Never use `@media` inside a component mixin — use `@container`.
- Do not combine `container-type: inline-size` with `overflow: hidden` on the same element — this breaks containment.
