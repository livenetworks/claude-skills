# ln-ashlar — Token Reference

Terse reference. All values from `scss/config/_tokens.scss` and `scss/config/_density.scss`.
For theming overrides → `css/theming.md`. For density tier values → `css/density.md`.

---

## Token model (3 layers)

```
Scale       →  --size-*, --color-neutral-*, --shadow-sm/md/xl
               back-end plumbing; NEVER read inside mixin bodies
Vocabulary  →  --bg-base, --fg-default, --border-subtle, --shadow-resting
               named value choices; themes rebind these
Primitives  →  --color-bg, --color-fg, --color-border, --shadow,
               --padding-x, --padding-y, --gap, --radius
               what mixin bodies read
```

Mixin bodies read **primitives**. Components rebind primitives on their own scope
to select a vocabulary value. Themes rebind vocabulary at theme `:root`.

---

## Colors — Primary

| Token | Value (HSL triplet) |
|---|---|
| `--color-primary` | `232 75% 52%` |
| `--color-primary-light` | `232 75% 93%` |
| `--color-primary-lighter` | `232 75% 97%` |

Usage: `hsl(var(--color-primary))` for solid; `hsl(var(--color-primary) / 0.5)` for alpha.

## Colors — Secondary

| Token | Value |
|---|---|
| `--color-secondary` | `160 76% 40%` |
| `--color-secondary-light` | `160 76% 93%` |
| `--color-secondary-lighter` | `160 76% 97%` |

## Colors — Status

| Token | Base | Light | Lighter |
|---|---|---|---|
| success | `142 76% 36%` | `142 76% 93%` | `142 76% 97%` |
| error | `0 84% 50%` | `0 84% 93%` | `0 84% 97%` |
| warning | `32 95% 44%` | `32 95% 93%` | `32 95% 97%` |
| info | `217 91% 60%` | `217 91% 93%` | `217 91% 97%` |

Pattern: `--color-{status}`, `--color-{status}-light`, `--color-{status}-lighter`.

## Colors — Neutral scale

`--color-neutral-50` through `--color-neutral-900` (50/100/150/200/300/400/500/600/700/800/900).
Mixins reach into neutral only when no semantic token matches — flag during dark-mode audits.

## Vocabulary — Backgrounds

| Token | Light value |
|---|---|
| `--bg-base` | `hsl(var(--color-white))` — page surface |
| `--bg-elevated` | `var(--bg-base)` — card/popover surface |
| `--bg-sunken` | `hsl(var(--color-neutral-100))` — thead, panel header |
| `--bg-recessed` | `hsl(var(--color-neutral-50))` — input background |

## Vocabulary — Foregrounds

| Token | Light value |
|---|---|
| `--fg-default` | `hsl(var(--color-neutral-900))` |
| `--fg-muted` | `hsl(var(--color-neutral-500))` |
| `--fg-subtle` | `hsl(var(--color-neutral-400))` |

## Vocabulary — Borders

| Token | Light value |
|---|---|
| `--border-subtle` | `hsl(var(--color-neutral-200))` |
| `--border-strong` | `hsl(var(--color-neutral-300))` |
| `--border-strong-hover` | `hsl(var(--color-neutral-400))` |

## Vocabulary — Shadows (contextual)

| Token | Binds to |
|---|---|
| `--shadow-resting` | `var(--shadow-sm)` |
| `--shadow-floating` | `var(--shadow-md)` |
| `--shadow-overlay` | `var(--shadow-xl)` |

## Primitives — Surface (read by mixin bodies)

```
--color-bg     → var(--bg-base)
--color-fg     → var(--fg-default)
--color-border → var(--border-subtle)
--shadow       → var(--shadow-resting)
```

## Primitives — Structure (read by mixin bodies)

```
--padding-x → var(--size-sm-up)   12px dense base
--padding-y → var(--size-xs-up)    6px dense base
--gap       → var(--size-xs-up)    6px dense base
--radius    → var(--radius-md)
```

---

## Spacing scale (full)

All 14 steps. Components read via primitives (`--padding-x/y`, `--gap`);
use `--size-*` only when a primitive doesn't fit.

| Token | Value |
|---|---|
| `--size-0` | `0` |
| `--size-2xs` | `0.125rem` — 2px |
| `--size-xs` | `0.25rem` — 4px |
| `--size-xs-up` | `0.375rem` — 6px |
| `--size-sm` | `0.5rem` — 8px |
| `--size-sm-up` | `0.75rem` — 12px |
| `--size-md` | `1rem` — 16px |
| `--size-md-up` | `1.25rem` — 20px |
| `--size-lg` | `1.5rem` — 24px |
| `--size-xl` | `2rem` — 32px |
| `--size-2xl` | `3rem` — 48px |
| `--size-3xl` | `4rem` — 64px |
| `--size-4xl` | `6rem` — 96px |
| `--size-5xl` | `8rem` — 128px |

Doctrine shorthand: `0 < 2xs < xs < xs-up < sm < sm-up < md < md-up < lg < xl < 2xl < 3xl < 4xl < 5xl`

---

## Shadow scale

Cool-tinted, dual-layer (`hsl(220 40% 15% / alpha)`). Dark mode auto-converts to
solid black higher-alpha (via `_theme.scss`).

| Token | Description |
|---|---|
| `--shadow-none` | `none` |
| `--shadow-xs` | 1px, ultra-subtle |
| `--shadow-sm` | 3px, card resting state |
| `--shadow-md` | 12px, floating panel |
| `--shadow-lg` | 24px, elevated modal |
| `--shadow-xl` | 48px, overlay / drawer |
| `--shadow-2xl` | 72px, hero CTA |
| `--shadow-inner` | inset 4px, recessed track |

Color-aware (token values, not mixins — apply via `box-shadow: var(--shadow-primary)`):

`--shadow-primary`, `--shadow-success`, `--shadow-error` — focus halo and CTA glow.

---

## Border radius

| Token | Value |
|---|---|
| `--radius-none` | `0` |
| `--radius-sm` | `0.25rem` — 4px |
| `--radius-md` | `0.5rem` — 8px (default `--radius`) |
| `--radius-lg` | `0.75rem` — 12px |
| `--radius-xl` | `1rem` — 16px |
| `--radius-full` | `9999px` |

---

## Typography — role tokens

Paired `--text-*` / `--lh-*`. Use via `@include typography($role)`.

| Role | Size | Line-height |
|---|---|---|
| `display-lg` | `3.75rem` | `1.1` |
| `display-md` | `3rem` | `1.1` |
| `display-sm` | `1.875rem` | `1.1` |
| `heading-lg` | `1.75rem` | `1.15` |
| `heading-md` | `1.25rem` | `1.2` |
| `heading-sm` | `1.125rem` | `1.25` |
| `title-md` | `1rem` | `1.3` |
| `title-sm` | `0.875rem` | `1.3` |
| `body-lg` | `1.125rem` | `1.6` |
| `body-md` | `0.875rem` | `1.5` (dense base) |
| `body-sm` | `0.8125rem` | `1.45` |
| `label-md` | `0.8125rem` | `1.4` |
| `label-sm` | `0.75rem` | `1.4` |
| `caption` | `0.75rem` | `1.4` |

Dense base (`--font-size` / `--line-height`) = `body-md`. Comfortable tier restores
16px / 1.6. Spacious tier sets 18px / 1.75.

Font weights: `--font-normal: 400`, `--font-medium: 500`, `--font-semibold: 600`, `--font-bold: 700`.

---

## Breakpoints — CSS custom properties

All breakpoints are also exposed as CSS custom properties at `:root` for JS consumption.

| Token | Value |
|---|---|
| `--bp-sm` | `480px` |
| `--bp-md` | `768px` |
| `--bp-lg` | `1024px` |
| `--bp-xl` | `1280px` |
| `--bp-2xl` | `1536px` |
| `--bp-3xl` | `1920px` |
| `--cq-narrow` | `480px` |
| `--cq-compact` | `580px` |
| `--cq-medium` | `880px` |
| `--cq-wide` | `1120px` |

---

## Content widths

| Token | Value |
|---|---|
| `--max-w-prose` | `65ch` |
| `--max-w-form` | `32rem` |
| `--max-w-content` | `48rem` |
| `--max-w-container` | `80rem` |

---

## Easing tokens

| Token | Curve | Use case |
|---|---|---|
| `--easing-standard` | `cubic-bezier(0.4, 0, 0.2, 1)` | Default — most UI |
| `--easing-decelerate` | `cubic-bezier(0, 0, 0.2, 1)` | Enter — element arriving |
| `--easing-accelerate` | `cubic-bezier(0.4, 0, 1, 1)` | Exit — element leaving |
| `--easing-spring` | `cubic-bezier(0.34, 1.56, 0.64, 1)` | Bouncy — selection toggle |

Transition shortcuts: `--transition-base: 0.2s`, `--transition-fast: 0.15s`, `--transition-slow: 0.3s`
(all use `--easing-standard` curve). Use via `@include transition/transition-fast/transition-colors`.

---

## Z-index scale

| Token | Value | Use |
|---|---|---|
| `--z-sticky` | `10` | Sticky table headers |
| `--z-dropdown` | `20` | Dropdowns, popovers |
| `--z-overlay` | `30` | Drawers, sidebars |
| `--z-modal` | `40` | Modal dialogs |
| `--z-toast` | `50` | Toast notifications |
