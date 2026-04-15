# ln-acme — Visual Rules Implementation

> Concrete ln-acme values for the principles in global ui/visual-language.md §1-§8.

---

## §1 Radius + Spacing — ln-acme Implementation

```scss
// Rounded nav links MUST have mx() — never flush to container
.nav a {
    @include rounded-md;
    @include mx(0.5rem);
    @include px(0.75rem);
}

// Sharp nav links CAN be flush
.nav a {
    @include px(1rem);
}
```

## §3 Icon Set

ln-acme standard: **Tabler Icons, outline variant, stroke-width 2**

## §4 Spacing Scale

Token scale: `0.25 / 0.5 / 0.75 / 1 / 1.25 / 1.5 / 2 / 3rem`

## §6 Typography

- Font: **Inter** for all UI text
- Weights: 400 (body), 500 (medium), 600 (semibold), 700 (bold)
- For component internals, use `@include typography($role)` — it pairs `font-size` + `line-height` from the role token system. Available roles: `display-lg/md/sm`, `heading-lg/md/sm`, `title-md/sm`, `body-lg/md/sm`, `label-md/sm`, `caption`. See `css/mixins.md` for the full role list.

## §7 Shadow Scale (v1.1)

Shadows are cool-tinted, dual-layer (`hsl(220 40% 15% / alpha)`), not plain grey. Scale: `shadow-none`, `shadow-xs`, `shadow-sm`, `shadow-md`, `shadow-lg`, `shadow-xl`, `shadow-2xl`, `shadow-inner`.

Color-aware variants for focus halos and CTAs: `--shadow-primary`, `--shadow-success`, `--shadow-error` (token values, not mixins — apply via `box-shadow: var(--shadow-primary)`).

In dark mode, shadows revert to solid black with higher alpha (cool tint disappears on dark surfaces). This is handled automatically by `_theme.scss`.

The three-layer focus halo (from `@include focus-ring`) is built from `box-shadow` layers, not from the shadow scale tokens. See the Focus Ring section in `css/mixins.md`.

## §8 Radius Scale

| Context | Mixin | Value |
|---|---|---|
| Buttons, inputs, cards, modals | `rounded-md` | 8px |
| Badges, pills, tags | `rounded-full` | 9999px |
| Tooltips | `rounded-sm` | 4px |

---

## Motion Implementation

> For motion philosophy (when and why) → global ui/visual-language.md §18.

### Transition Mixins

```scss
@include transition;         // all 200ms ease — general purpose
@include transition-fast;    // all 150ms ease — micro-interactions (hover, focus)
@include transition-colors;  // color, background-color, border-color 200ms ease
```

Never write raw `transition:` property — always use these mixins.

### Easing Tokens

| Token | Use case |
|-------|----------|
| `--easing-standard` | Default — most UI transitions (modal open/close, state changes) |
| `--easing-decelerate` | Enter — element arriving (slide in, expand) |
| `--easing-accelerate` | Exit — element leaving (slide out, collapse) |
| `--easing-spring` | Bouncy feedback — selection toggles, drag confirmation |

```scss
transition: transform 220ms var(--easing-spring);
```

The transition mixins (`@include transition`, `@include transition-fast`) use `ease` as their default. Override the easing property directly when a specific curve is needed.

### Component Motion Patterns

```scss
// Modal — fade + scale
.ln-modal {
    @include opacity-0;
    @include motion-safe {
        transform: scale(0.95);
        @include transition;
        &.open { transform: scale(1); }
    }
    &.open { @include opacity-100; }
}

// Toast — slide in from right
.ln-toast {
    @include opacity-0;
    @include motion-safe {
        transform: translateX(100%);
        @include transition;
        &.visible { transform: translateX(0); }
    }
    &.visible { @include opacity-100; }
}

// Dropdown — scale from top
.dropdown-menu {
    @include opacity-0;
    transform-origin: top;
    @include motion-safe {
        transform: scaleY(0);
        @include transition-fast;
        &.open { transform: scaleY(1); }
    }
    &.open { @include opacity-100; }
}

// Inline confirm — color transition only (no motion-safe needed)
.btn[data-confirming] {
    @include transition-colors;
}
```

### Keyframes — Only Two Allowed

```scss
// Spinner
@keyframes ln-spin {
    to { transform: rotate(360deg); }
}
.ln-spinner { animation: ln-spin 1s linear infinite; }

// Shimmer (skeleton loading)
@keyframes ln-shimmer {
    0% { background-position: -200% 0; }
    100% { background-position: 200% 0; }
}
.ln-skeleton {
    background: linear-gradient(90deg,
        hsl(var(--color-bg-secondary)) 25%,
        hsl(var(--color-bg-secondary) / 0.5) 50%,
        hsl(var(--color-bg-secondary)) 75%
    );
    background-size: 200% 100%;
    animation: ln-shimmer 1.5s ease-in-out infinite;
}
```

No custom `@keyframes` for UI elements beyond these two.

### prefers-reduced-motion

ln-acme uses `@include motion-safe { }` — it gates your animation declarations behind `@media (prefers-reduced-motion: no-preference)`. Wrap `transform`, `opacity`, `translate`, `scale`, `rotate`, and keyframe animations in it. Do NOT use the `!important` override anti-pattern on `*, *::before, *::after`.

Color transitions on hover (`@include transition-colors`) are fine unwrapped — they do not trigger vestibular issues.

```scss
// CORRECT — gate motion declarations positively
.ln-modal {
    @include motion-safe {
        @include transition;
        transform: scale(0.95);
        &.open { transform: scale(1); }
    }
}

// WRONG — anti-pattern, never do this
*, *::before, *::after {
    transition-duration: 0.01ms !important;
}
```

---

## Button Architecture

### Global `<button>` — Structure + Neutral (out of the box)

Every `<button>` gets full structure + neutral colors from `scss/base/_global.scss`:
- Structure: `inline-flex`, centered, `px(1.25rem) py(0.625rem)`, `text-sm`, `font-medium`, `rounded-md`
- Default: transparent bg, muted text
- Hover: `hsl(var(--color-bg-secondary))` — gray, no transform
- Active: border-color background
- Focus: focus ring
- Disabled: 50% opacity

### `<button type="submit">` — Color Only

- Background: solid `hsl(var(--color-primary))`, white text
- Hover: `hsl(var(--color-primary-hover))`

### `@mixin btn` — Complete Action Button

For non-submit buttons that need primary styling:

```scss
#add-user { @include btn; }
#delete-user { @include btn; --color-primary: var(--color-error); }
```

Size variants:
```scss
#compact { @include btn; @include btn-sm; }
#hero { @include btn; @include btn-lg; }
```

### Rules

- No `btn--*` variant classes — use `--color-primary` override
- No `translateY` or `box-shadow` on hover — color change only
- Zero hardcoded colors — every color reads `var(--token)`

---

## Collapsible Implementation

```scss
// Framework
.collapsible       { @include collapsible; }
.collapsible-body  { @include collapsible-content; }

// Project override
.my-panel          { @include collapsible; }
.my-panel > .inner { @include collapsible-content; }
```

- `.collapsible` (parent): `padding: 0`, collapses to `0fr`
- `.collapsible-body` (child): `overflow: hidden`, holds padding/margins

---

## Container Query Mixin

```scss
@mixin container($name: null) {
    container-type: inline-size;
    @if $name { container-name: $name; }
}
```

Usage:
```scss
#folders        { @include container(foldersgrid); }
.card-grid      { @include container(cardgrid); }
.sidebar        { @include container(sidebar); }
.search-results { @include container; }              // anonymous
```

Standard breakpoints: `480px`, `580px`, `880px`, `1120px`

Container names: noun, singular, lowercase, no hyphens (`foldersgrid`, not `folders-grid`).

ln-acme uses **container queries for components** (respond to the container's width) and **viewport breakpoints for layout** (respond to the page width). Components must not use `@media` breakpoints internally — they must adapt via container queries so they work in any layout slot. See `docs/css/breakpoints.md` and `docs/ln-acme-container-queries.md` for detail.

---

## Theme Override

```scss
:root { --color-primary: 231 62% 27%; }
.sport    { --color-primary: 142 71% 45%; }
.politika { --color-primary: 0 72% 51%; }
.kultura  { --color-primary: 271 81% 56%; }
```

---

## Override Discipline

### Don't duplicate ln-acme globals

```scss
// WRONG — ln-acme already does this
body { margin: 0; background-color: hsl(var(--color-bg-body)); }
a { text-decoration: none; color: hsl(var(--color-primary)); }
button { border: none; cursor: pointer; }

// RIGHT — only override what's different
body { font-feature-settings: 'cv02', 'cv03', 'cv04'; }
```

### Don't restate inherited properties

```scss
// WRONG — headings already have text-primary from ln-acme
#content h1 { @include text-primary; }

// RIGHT — only the delta
#content h1 { letter-spacing: -0.02em; }
```

### panel-header — Unified Header Mixin

All panel headers use the same mixin:
```scss
.card header          { @include panel-header; }
.section-card header  { @include panel-header; }
.ln-modal header      { @include panel-header; }
```
