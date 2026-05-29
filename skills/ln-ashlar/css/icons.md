# ln-ashlar — Icon System

> SVG sprite injection via `ln-icons.js`. For icon consistency principles → global ui/visual-language.md §3.

---

## How It Works

`ln-icons.js` fetches SVG icons on-demand from a public CDN (Tabler Icons) or a custom CDN at runtime, compiles them into a hidden `<svg>` sprite sheet injected in `<body>` at init, and caches them in `localStorage`. Icons render via `<use href="#ln-{name}">` or `<use href="#lnc-{name}">` and inherit `currentColor`.

## Markup

```html
<!-- Standalone icon -->
<svg class="ln-icon" aria-hidden="true"><use href="#ln-plus"></use></svg>

<!-- Icon in button with text -->
<button>
    <svg class="ln-icon" aria-hidden="true"><use href="#ln-plus"></use></svg>
    Add
</button>

<!-- Icon-only button — aria-label required -->
<button aria-label="Close">
    <svg class="ln-icon" aria-hidden="true"><use href="#ln-x"></use></svg>
</button>

<!-- Toggle chevron (CSS rotates on open — works inside accordion or standalone) -->
<header data-ln-toggle-for="panel1">
    Title
    <svg class="ln-icon ln-chevron" aria-hidden="true"><use href="#ln-arrow-down"></use></svg>
</header>
```

## Two Prefixes

- `#ln-{name}` — Tabler icons (fetched from jsdelivr CDN)
- `#lnc-{name}` — Custom CDN icons (served from `window.LN_ICONS_CUSTOM_CDN`)

## Available Icons

Any icon from [Tabler Icons](https://tabler.io/icons). Common ones:
`home` `x` `menu` `users` `settings` `logout` `books`
`plus` `edit` `trash` `eye` `device-floppy` `search` `check` `copy` `link` `filter` `calendar`
`upload` `download` `refresh` `printer` `lock` `star` `arrow-up` `arrow-down` `arrows-sort`
`chart-bar` `clock` `mail` `book` `world` `list` `box` `building` `alert-triangle`
`info-circle` `circle-x` `circle-check` `user` `phone` `square-compass` `file`

Full list: `scss/tabler-icons.txt`

Custom icons: `lnc-file-pdf` `lnc-file-doc` `lnc-file-epub`

## Sizes

| Class | Size |
|-------|------|
| `ln-icon--sm` | 1rem |
| (default) | 1.25rem |
| `ln-icon--lg` | 1.5rem |
| `ln-icon--xl` | 4rem |

## Color

Icons inherit parent's `color` property automatically. No color properties needed in SCSS.
Exception: custom icons (`lnc-file-pdf`, etc.) have embedded semantic stroke colors.

## Adding a Custom Icon

To host custom icons in production:
1. Save the custom SVG icon files in a directory on your production asset server or public CDN (e.g., `/public/assets/icons/` or `https://cdn.mycompany.com/assets/icons/`).
2. Before the library initializes, define the CDN URL globally using `window.LN_ICONS_CUSTOM_CDN = "https://cdn.mycompany.com/assets/icons";`.
3. In HTML, reference the icon as `#lnc-{name}` (e.g., `<use href="#lnc-corporate-logo"></use>`). The on-demand sprite generator will fetch, cache, and inject the SVG automatically from your custom CDN.

## Close Buttons

Icon-only close/dismiss buttons use the global `<button>` base styles. Re-bind `--padding-y` and `--padding-x` on the parent scope's descendant `button` selector to tighten the tap area (e.g. `--padding-y: var(--size-2xs); --padding-x: var(--size-2xs);`).

## Pseudo-Element Awareness

- `::before` / `::after` may be occupied by existing component styles — NEVER override for loading/overlay effects
- For overlays: use `box-shadow: inset 0 0 0 9999px rgba(...)` instead
- For spinners: inject a real DOM `<span>` via JS, not pseudo-elements
