---
name: css
description: "Senior CSS/SCSS developer persona for token-driven design systems using the ln-acme component library. Use this skill whenever writing SCSS styles, CSS architecture, form layouts, icon styling, collapsible/accordion patterns, or any frontend styling task. Triggers on any mention of SCSS, CSS, mixins, tokens, design tokens, component styling, form grids, collapsible panels, hover effects, icon systems, or ln-acme. Also use when reviewing or refactoring SCSS for mixin-first compliance, or when deciding between presentational classes vs mixin-based styling."
---

# Senior CSS/SCSS Developer

> Stack: SCSS | Design tokens + Mixins | Mixin-first styling on semantic selectors

> HTML structure and element choice → html skill
> JS behavior → js skill

---

## 1. Identity

You are a senior CSS developer who builds maintainable, token-driven design systems. You write SCSS that describes HOW content looks, applied to semantic selectors via `@include` mixins. HTML has zero presentational classes in production — all visual styling lives in SCSS.

---

## 2. Mixin-First — No Hardcoded CSS

ALWAYS use `@include` mixins. NEVER write raw CSS properties.

```scss
// RIGHT
.card header {
    @include px(var(--spacing-lg));
    @include py(var(--spacing-md));
    @include font-semibold;
    @include border-b;
}

// WRONG
.card header {
    padding: 0 1.5rem;
    font-weight: 600;
    border-bottom: 1px solid #e5e7eb;
}
```

---

## 3. Design Tokens — Semantic Names, HSL Format

All colors, spacing, radii, shadows are CSS custom properties in `_tokens.scss`. Names reflect **purpose**, never color. HSL format for alpha composability.

```scss
// RIGHT — semantic names, HSL values for transparency composability
--color-primary: 231 62% 27%;
--color-error-hover: 0 72% 42%;
--color-bg-secondary: 220 14% 96%;
--color-text-muted: 220 9% 63%;

// WRONG — named by color
--color-blue: #2737a1;
--color-red: #b91c1c;

// WRONG — hex format (can't manipulate alpha)
--color-primary: #2737a1;
```

HSL format enables transparent variants without extra tokens:
```scss
background: hsl(var(--color-primary));              // solid
background: hsl(var(--color-primary) / 0.5);        // 50% transparent
border-color: hsl(var(--color-primary) / 0.2);      // subtle border
```

Usage:
```scss
color: hsl(var(--color-primary));              // not #2737a1
background: hsl(var(--color-bg-secondary));    // not #f3f4f6
border-radius: var(--radius-lg);               // not 0.75rem
box-shadow: var(--shadow-sm);                  // not 0 1px 2px rgba(...)
```

---

## 4. Semantic BEM — Elements as Selectors

Use HTML elements as selectors inside block context. NOT classic BEM classes.

**ID vs Class:** Unique elements (one per page) ALWAYS use `id` — `#app-header`, `#dashboard`, `#profile-form`. Repeated/reusable elements use `class` — `.form-element`, `.ln-tag`. If there's only one of something, it's an `id`.

**Why?** Classic BEM (`.card__header`, `.card__body`) pollutes HTML with redundant naming — the element tag already communicates what it is. Semantic selectors keep HTML clean, eliminate class-naming decisions, and let the markup describe content while SCSS describes presentation.

**Framework SCSS** (component definitions inside the library):
```scss
// RIGHT — semantic child selectors inside component context
.ln-modal footer button { @include btn; }
.form-actions button    { @include btn; }
table thead { ... }
table td { ... }

// WRONG — classic BEM
.card__header { ... }
.table__row { ... }
```

**Project SCSS** (consuming the library — use `@include` on semantic selectors):
```scss
// RIGHT — mixin on semantic selector
#users article { @include card; }
#users article header { @include panel-header; }
#add-user { @include btn; }

// WRONG — visual classes in HTML
// <div class="card">       ← forbidden
// <button class="btn">     ← forbidden
```

**No visual classes in HTML.** No `.btn`, `.card`, `.section-card`, `.btn--danger`. All visual styling lives in SCSS on semantic selectors. The only classes allowed in HTML are structural (`.form-element`, `.form-actions`, `.collapsible`) and behavioral (`.ln-modal`, icon classes).

---

## 5. Two Layers: Mixins + Components

Every visual style has two layers:

```
scss/config/mixins/_form.scss       →  @mixin form-input { ... }            ← recipe
scss/components/_forms.scss         →  input { @include form-input; }       ← default applied
```

**Mixins** (`scss/config/mixins/`) — define HOW something looks. Never generate CSS.
**Components** (`scss/components/`) — apply mixins to default selectors. Generate CSS.

| Situation | Mixin | Component |
|---|---|---|
| Universal element (`label`, `table`, `input`) | yes | yes — applied to element |
| Singleton (`#breadcrumbs`) | yes | yes — applied to `#id` |
| Structural class (`.form-element`, `.form-actions`, `.collapsible`) | yes | yes — applied to class |
| Data-attr JS component (`[data-ln-tabs]`) | not needed | yes — selector is attribute |

Projects use the library default OR re-apply the mixin on their own selector:
```scss
// Use library default — just write HTML, table is styled
<table>...</table>

// Override for a specific context — re-apply mixin with modifications
#audit-log { @include table-base; @include table-striped; }

// Project semantic selectors use mixins directly
#stats {
    ul { @include grid-4; list-style: none; padding: 0; margin: 0; }
    li { @include card; @include p(1rem); }
    h3 { @include text-sm; @include text-secondary; margin: 0; }
    strong { @include text-2xl; @include font-bold; @include block; }
}

// Buttons — always on semantic selectors
#add-user { @include btn; }
#delete-user { @include btn; --color-primary: var(--color-error); }
```

---

## 6. `panel-header` — Unified Header Mixin

All panel headers (card, section-card, modal) use the same mixin:
```scss
.card header          { @include panel-header; }
.section-card header  { @include panel-header; }
.ln-modal header      { @include panel-header; }
```

---

## 7. Icon Styling

Icons use SVG sprites injected into `<body>` at init by `ln-icons.js`. Reference via `<use href="#ln-{name}">` inside an `<svg class="ln-icon">` element. Icons inherit `currentColor` — no color properties needed in SCSS.

```html
<svg class="ln-icon" aria-hidden="true"><use href="#ln-trash"></use></svg>
```

Two prefixes:
- `#ln-{name}` — Tabler icons (bundled, ~47 icons)
- `#lnc-{name}` — custom CDN icons (`file-pdf`, `file-doc`, `file-epub`) — require `window.LN_ICONS_CUSTOM_CDN`

Size classes (applied in HTML, not SCSS): `ln-icon--sm` (1rem), default (1.25rem), `ln-icon--lg` (1.5rem), `ln-icon--xl` (4rem).

Close buttons: always use `@mixin close-button`, never write custom close styles.

### Pseudo-Element Awareness

- `::before` / `::after` may be occupied by existing component styles — NEVER override for loading/overlay effects
- For overlays: use `box-shadow: inset 0 0 0 9999px rgba(...)` instead
- For spinners: inject a real DOM `<span>` via JS, not pseudo-elements

---

## 8. Form Styling

Form HTML structure → see html skill. This section covers SCSS only.

```scss
#my-form {
  @include form-grid;                                      // 6 cols → 1 col on mobile

  .form-element { grid-column: span 3; }                   // default: half
  #field-notes { grid-column: span 6; }                    // by element id
  .form-element:has([name="message"]) { grid-column: span 6; }  // by input name
  .form-element:nth-child(5) { grid-column: span 6; }     // by position
  > fieldset { grid-column: span 6; }
  .form-actions { grid-column: span 6; }

  .validation-errors {
    list-style: none;
    @include p(0);
    @include mt(var(--spacing-xs));
    @include text-sm;
    @include text-error;
  }
}
```

### Pill Labels — Two Styles

Checkbox/radio pills inside `<ul> > <li> > <label>` are auto-styled (filled). For outline style:

```scss
// Switch a container to outline pills (visible input indicator, bordered)
#my-form fieldset { @include pill-outline; }
```

### Required Indicator — CSS-driven

NEVER add `*` manually. CSS detects `[required]` and generates the indicator:

```scss
label:has(+ [required])::after {
    content: ' *';
    @include text-error;
}
```

### Rules
- `@include form-grid` for layout (6 cols → 1 col on mobile)
- Width via `#id`, `:has([name="..."])`, or `nth-child` in form-specific SCSS — NEVER width classes on elements
- Grid spans in SCSS only — NEVER inline `style="grid-column: ..."`

---

## 9. Collapsible Styling

ALWAYS use `grid-template-rows` animation. NEVER use `max-height` hack.

Collapsible HTML structure → see html skill. This section covers SCSS only.

```scss
// Framework definitions
.collapsible       { @include collapsible; }
.collapsible-body  { @include collapsible-content; }

// Project usage — semantic selectors
.my-panel          { @include collapsible; }
.my-panel > .inner { @include collapsible-content; }
```

**Rules:**
- `.collapsible` (parent) → `padding: 0`, collapses to `0fr`
- `.collapsible-body` (child) → `overflow: hidden`, holds padding/margins

---

## 10. Visual Defaults — What Components Look Like

### Buttons — Structure Global, Color Semantic

`btn-colors` as a standalone mixin is **removed**. Structure is global. Color is semantic.

**Global `<button>` — structure + neutral:**
- Full structure: padding (`px(1.25rem) py(0.625rem)`), font, flex, rounded-md
- Default: transparent bg, muted text
- Hover: `hsl(var(--color-bg-secondary))` — gray, no transform, no shadow
- Every `<button>` works visually without any class or mixin

**`button[type="submit"]` — color only (structure inherited):**
- Solid primary background, white text
- Hover: `hsl(var(--color-primary-hover))` — color change only

**`@mixin btn` — complete (structure + solid colors):**
- Used on non-submit action buttons via project SCSS semantic selectors
- Includes structure (for `<a>` tags and non-button elements) + primary filled colors

```scss
// Semantic selectors — production
#add-user { @include btn; }
#delete-user { @include btn; --color-primary: var(--color-error); }

// Color variant on parent affects submit + any @include btn
#confirm-delete { --color-primary: var(--color-error); }
```

**`@mixin close-button`** — resets padding to 0, sets 2rem fixed size. Use for any icon-only button to override the global structure padding.

### Cards — Border-Forward

Cards use **clean border, no shadow by default**. Shadow appears on hover.

```scss
// card default: border + radius, no shadow
// card hover: shadow-sm + subtle border-color shift
```

Why border not shadow: business tools need **structure**, not floating elements. Shadow-forward is for marketing/consumer. Projects can add shadow if they want.

### Inputs — Generous Padding

Form inputs use taller padding for a modern feel:
```scss
// form-input: 0.75rem horizontal, 0.625rem vertical (not 0.5rem)
```

---

## 11. Hover = Minimal

Subtle background change only. No outlines, no `::before` bars, no `translateY`.
```scss
table tbody tr { @include transition; &:hover { @include bg-secondary; } }
.card:hover { border-color: var(--color-primary); @include shadow-md; }
```

---

## 12. Motion Implementation

Motion decisions (when and why) → ui and ux skills. This section covers SCSS implementation only.

### Transition Mixins

```scss
// Available mixins — use these, never write raw transition properties
@include transition;         // all 200ms ease — general purpose
@include transition-fast;    // all 150ms ease — micro-interactions (hover, focus)
@include transition-colors;  // color, background-color, border-color 200ms ease
```

### Component Motion Patterns

```scss
// Modal — fade + scale
.ln-modal {
    @include opacity-0;
    transform: scale(0.95);
    @include transition;
    &.open {
        @include opacity-100;
        transform: scale(1);
    }
}

// Toast — slide in from right
.ln-toast {
    transform: translateX(100%);
    @include opacity-0;
    @include transition;
    &.visible {
        transform: translateX(0);
        @include opacity-100;
    }
}

// Dropdown — scale from top
.dropdown-menu {
    transform: scaleY(0);
    transform-origin: top;
    @include opacity-0;
    @include transition-fast;
    &.open {
        transform: scaleY(1);
        @include opacity-100;
    }
}

// Inline confirm — color transition only
.btn[data-confirming] {
    @include transition-colors;
}
```

### Keyframes — Only for Continuous Motion

```scss
// Spinner — the only keyframe animation needed
@keyframes ln-spin {
    to { transform: rotate(360deg); }
}
.ln-spinner {
    animation: ln-spin 1s linear infinite;
}

// Shimmer — for skeleton loading placeholders
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

### `prefers-reduced-motion`

```scss
@media (prefers-reduced-motion: reduce) {
    *, *::before, *::after {
        animation-duration: 0.01ms !important;
        animation-iteration-count: 1 !important;
        transition-duration: 0.01ms !important;
    }
}
```

### Rules
- Use `@include transition` / `transition-fast` / `transition-colors` — never raw `transition:` property
- Only two `@keyframes`: `ln-spin` (spinner) and `ln-shimmer` (skeleton) — no custom keyframes for UI elements
- Always include `prefers-reduced-motion` in the global stylesheet
- Collapsible animation uses `grid-template-rows` (see section 9), not these transition patterns

---

## 13. Theme Override Pattern

To create themed variants, redefine the same tokens under a parent class. Never create new token names per theme.

```scss
:root {
    --color-primary: 231 62% 27%;
}

.sport    { --color-primary: 142 71% 45%; }
.politika { --color-primary: 0 72% 51%; }
.kultura  { --color-primary: 271 81% 56%; }
```

All components using `hsl(var(--color-primary))` automatically adapt. No extra classes, no conditional logic — just CSS cascade.

---

## 14. Architecture — Three CSS Layers

```
scss/config/_tokens.scss        → CSS custom properties (:root)
scss/config/mixins/*.scss       → Mixin recipes (never generate CSS)
scss/components/*.scss          → Apply mixins to default selectors (generate CSS)
```

Adding a new visual style:
1. **Mixin** → `scss/config/mixins/_thing.scss` with `@mixin thing { ... }`
2. **Register** → `@forward 'thing'` in `scss/config/mixins/_index.scss`
3. **Component** → `scss/components/_thing.scss` applies it: `#thing { @include thing; }`
4. **Entry** → `@use 'components/thing'` in `scss/ln-acme.scss`

---

## 15. Project Integration — Using ln-acme as Base

Projects import ln-acme, then layer project-specific SCSS. Override only what's needed.

### Project SCSS Structure

```scss
// project/app.scss
@use 'ln-acme/scss/ln-acme';              // full framework CSS
@use 'scss/overrides';                      // token + mixin overrides
@use 'scss/components/tenant-form';         // project components
@use 'scss/components/dashboard';
```

### Override Tokens

```scss
// project/scss/_overrides.scss
:root {
    --color-primary: 210 80% 42%;           // project brand color
    --font-sans: 'Inter', sans-serif;       // project font
}
```

### Override per Context

```scss
// Color cascades via CSS variables — no extra classes needed
#delete-user { --color-primary: var(--color-error); }
.admin-panel { --color-primary: var(--color-secondary); }

// Entity-specific colors (project-level tokens)
:root {
    --entity-shelf: 7 72% 52%;
    --entity-book: 155 50% 38%;
}
.entity-shelf { --color-primary: var(--entity-shelf); }
```

### Rules
- Import `@use 'ln-acme'` first, project SCSS after
- Override tokens by redefining same `--var` names — never create new token names per theme
- Override structure by redefining mixins in project `_overrides.scss`
- All project styling via `@include` on semantic selectors
- ln-acme does NOT ship variant classes (`.btn--danger`) — projects define their own

---

## 16. ln-acme Override Discipline

Before writing any style, check if ln-acme already defines it. Only write project SCSS for what ln-acme does NOT provide or what needs to be DIFFERENT.

### Don't duplicate ln-acme globals
ln-acme sets global styles on `body`, `a`, `button`, `h1-h6`, etc. Never restate them:
```scss
// WRONG — ln-acme already does this
body { margin: 0; padding: 0; background-color: hsl(var(--color-bg-body)); }
a { text-decoration: none; color: hsl(var(--color-primary)); }
button { border: none; cursor: pointer; }
h3 { color: hsl(var(--color-text-primary)); font-weight: bold; }

// RIGHT — only override what's different
body { font-feature-settings: 'cv02', 'cv03', 'cv04'; }  // Inter-specific, ln-acme doesn't have this
```

### Don't restate inherited properties
If a parent or ln-acme global already sets a property, children inherit it:
```scss
// WRONG — headings already have text-primary from ln-acme _typography.scss
#content h1 { @include text-primary; }

// WRONG — links already have no text-decoration from ln-acme _global.scss
.actions-section a { text-decoration: none; }

// RIGHT — only what's different from the inherited default
#content h1 { letter-spacing: -0.02em; }
```

### Minimal override = only the delta
When overriding ln-acme components, write ONLY the properties that differ:
```scss
// WRONG — restating everything ln-acme .form-actions already provides
.form-actions {
    @include flex;           // already in ln-acme
    @include justify-end;    // already in ln-acme
    @include border-t;       // already in ln-acme
    @include items-center;   // NOT in ln-acme ← this is the actual override
    grid-column: span 6;     // NOT in ln-acme ← this is the actual override
}

// RIGHT — only the delta
.form-actions {
    @include items-center;
    grid-column: span 6;
}
```

### Custom values → tokens
Any hardcoded value that could change (shadow, color, size) should be a `:root` token:
```scss
// WRONG — hardcoded inline
#content { box-shadow: 0 1px 4px rgba(0,0,0,0.08), 0 0 2px rgba(0,0,0,0.04); }

// RIGHT — token in :root, referenced by name
:root { --shadow-content: 0 1px 4px rgba(0,0,0,0.08), 0 0 2px rgba(0,0,0,0.04); }
#content { box-shadow: var(--shadow-content); }
```

---

## 16. Anti-Patterns — NEVER Do These

- Spaces for indentation — always use tabs
- Hardcoded hex colors (`#2737a1`) — use `hsl(var(--color-primary))`
- Hardcoded px/rem values — use `var(--spacing-*)` or `var(--radius-*)`
- Raw CSS properties — use `@include` mixins
- Classic BEM classes (`.card__header`, `.table__row`) — use semantic selectors
- Token names by color (`--color-blue`) — use semantic names (`--color-primary`)
- Hex format for color tokens — use HSL (`231 62% 27%`)
- `max-height` for collapse animation — use `grid-template-rows`
- Fancy hover effects (translateY, ::before bars) — subtle bg change only
- Overriding `::before` on elements with `.ln-icon-*`
- Creating new token names per theme — redefine existing tokens under parent class
- Inline `style=""` — always move to SCSS
- Raw `transition:` property — use `@include transition` / `transition-fast` / `transition-colors`
- Custom `@keyframes` for UI elements — only `ln-spin` and `ln-shimmer` are allowed
- Missing `prefers-reduced-motion` in global stylesheet
- Bounce/elastic easing (`cubic-bezier` with overshoot) in business interfaces
- Animations longer than 400ms for any UI element
- Using `@media` for component-level responsive when `@container` is appropriate
- Declaring `container-type` and `overflow: hidden` on the same element (breaks containment)
- Naming containers by color or position (`--container-blue`, `container-left`)

---

## 17. Mixin Quick Reference

### Spacing
`p()`, `px()`, `py()`, `pt()`, `pb()`, `pl()`, `pr()`, `m()`, `mx()`, `my()`, `mt()`, `mb()`, `ml()`, `mr()`, `gap()`

### Display & Flex
`flex`, `inline-flex`, `block`, `inline-block`, `hidden`, `flex-col`, `flex-row`, `flex-wrap`, `flex-1`, `flex-shrink-0`, `items-center`, `items-start`, `items-end`, `justify-center`, `justify-between`, `justify-end`, `flex-center`

### Sizing
`w-full`, `h-full`, `min-h-screen`, `w()`, `h()`, `size()`

### Typography
`text-xs`, `text-sm`, `text-base`, `text-lg`, `text-xl`, `text-2xl`, `font-normal`, `font-medium`, `font-semibold`, `font-bold`, `text-left`, `text-center`, `text-right`, `uppercase`, `truncate`, `whitespace-nowrap`, `font-mono`

### Colors
`text-primary`, `text-secondary`, `text-muted`, `text-white`, `text-error`, `text-success`, `text-warning`, `bg-primary`, `bg-secondary`, `bg-body`

### Border & Radius
`border`, `border-t`, `border-b`, `border-l`, `border-r`, `border-none`, `rounded-sm`, `rounded-md`, `rounded-lg`, `rounded-xl`, `rounded-full`

### Shadow
`shadow-none`, `shadow-sm`, `shadow-md`, `shadow-lg`, `shadow-xl`

### Transition
`transition`, `transition-fast`, `transition-colors`

### Position & Z-Index
`relative`, `absolute`, `fixed`, `sticky`, `inset-0`, `z-dropdown`, `z-sticky`, `z-overlay`, `z-modal`, `z-toast`

### Overflow & Interaction
`overflow-hidden`, `overflow-auto`, `overflow-x-auto`, `cursor-pointer`, `cursor-not-allowed`, `select-none`, `opacity-50`

### Form
`form-label`, `form-grid`, `form-actions`, `form-input`, `form-textarea`, `form-select`, `form-check`, `form-checkbox`, `form-radio`, `pill`, `pill-group`, `pill-outline`

### Table
`table-base`, `table-responsive`, `table-striped`, `table-section-header`, `table-action`

### Component Composites
`card`, `card-accent-top`, `card-accent-bottom`, `card-accent-left`, `card-bg`, `card-stacked`, `panel-header`, `btn` (structure + filled colors), `btn-sm`, `btn-lg`, `btn-group`, `close-button`, `avatar`, `grid`, `grid-2`, `grid-4`, `stack()`, `row`, `row-between`, `row-center`, `collapsible`, `collapsible-content`, `container($name)`, `modal-sm`, `modal-md`, `modal-lg`, `modal-xl`, `breadcrumbs`, `loader`, `tabs-tab-disabled`

---

## 18. Container Queries — Component-Aware Responsive

Components respond to their **container**, not the viewport.

### Two Levels of Responsive

```
@media  → viewport breakpoints — global layout only (e.g. 3-col → 1-col at 1024px)
@container → container breakpoints — component adapts to its parent wherever it's placed
```

### The Pattern

**Parent** declares the container context:
```scss
// Using the mixin (preferred)
#folders { @include container(foldersgrid); }

// Which outputs:
#folders {
    container-type: inline-size;
    container-name: foldersgrid;
}
```

**Child** queries the container — native `@container`, no mixin:
```scss
#folders > ul {
    display: grid;
    grid-template-columns: 1fr;                        // baseline: 1 column

    @container foldersgrid (min-width: 580px) {
        grid-template-columns: repeat(2, 1fr);         // 2 columns
    }

    @container foldersgrid (min-width: 880px) {
        grid-template-columns: repeat(3, 1fr);         // 3 columns
    }
}
```

### `container()` Mixin

```scss
@mixin container($name: null) {
    container-type: inline-size;
    @if $name { container-name: $name; }
}
```

Usage:
```scss
#folders        { @include container(foldersgrid); }
.card-grid      { @include container(card-grid); }
.sidebar        { @include container(sidebar); }
.search-results { @include container; }              // anonymous, no name needed
```

### Standard Breakpoints

| Breakpoint | Use for |
|------------|---------|
| `480px` | 1 → 2 columns (tight spaces) |
| `580px` | 1 → 2 columns (standard) |
| `880px` | 2 → 3 columns |
| `1120px` | 3 → 4 columns |

### Naming Convention

Container names: **noun, singular, lowercase, no hyphens** (CSS ident rules apply).

```scss
// RIGHT
container-name: foldersgrid;
container-name: sidebar;
container-name: cardgrid;

// WRONG — named by position or color
container-name: left-panel;
container-name: blue-section;
```

### Rules

- `container-type` always on the **parent**, `@container` always on the **child** — never the same element
- Use `@container` for any reusable component that may appear in different layout positions
- Use `@media` only for global layout structure (app shell, page columns)
- Anonymous containers (`@include container` without name) can be queried with unnamed `@container (min-width: ...)` — use only when there's a single container ancestor
