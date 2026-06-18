---
name: ln-ashlar
description: "Implementation reference for the ln-ashlar frontend library. Use this skill when working on a project that uses ln-ashlar for CSS/JS. Covers: SCSS mixins and token values, JS component boilerplate, ln-core helpers API, icon system, naming conventions, and component-specific implementation patterns."
---

# ln-ashlar — Implementation Reference

> This skill covers HOW to build with ln-ashlar.
> For WHY and WHAT decisions → see global skills (css, js, html, ui, ux).

---

## What is ln-ashlar?

Unified frontend library: **SCSS CSS framework** + **vanilla JS components**. Zero dependencies. Used in Laravel projects via npm or git submodule.

## 🏛️ The DOM-First Doctrine

`ln-ashlar` is built on a simple technical reality: **the browser works natively with the DOM, not a Virtual DOM.** The framework enforces the following:

1. **Server-Rendered structure, client-rendered behavior:** The server generates complete, semantic HTML. The browser paints it immediately. A lightweight, native `MutationObserver` registers and binds vanilla JS components dynamically.
2. **HTML describes WHAT, not HOW:** HTML markup should only consist of semantic tags and structural elements. Visual details belong exclusively in SCSS.
3. **Pure SCSS Styling via `@include`:** Tailwind-style utility classes are strictly banned in markup (avoid `flex`, `grid-cols-4`, `text-red-500`). Markup is styled by applying SCSS mixins to semantic selectors (e.g., `#user-table { @include table-base; }`).
4. **Zero Dependencies:** To ensure decades of stability and complete immunity to npm supply chain attacks, `ln-ashlar` contains zero transitive dependencies at runtime.

## 🧭 Four Core Philosophy Principles

1. **HTML describes WHAT, not HOW** — Use semantic elements only. No presentational or utility classes in markup. Visual changes happen in SCSS, never in HTML.
2. **Style via `@include` on semantic selectors** — Projects write `#user-table { @include table-base; }`, not `<table class="table table-striped">`. The selector describes the element; the mixin describes how it looks.
3. **Every color is a CSS variable** — Always use `hsl(var(--color-primary))`, never hardcoded hex codes like `#2737a1`. The entire design system is fully customizable at any scope via simple variable overrides.
4. **JS is attribute-driven, zero init** — Interactivity is declared via attributes (`data-ln-modal`, `data-ln-filter`, `data-ln-toggle`). A single `MutationObserver` registers, binds, and cleans up instances automatically without boilerplate constructor calls.

## Architecture

```
SCSS: tokens → mixins → components
  scss/config/_tokens.scss     → :root CSS variables
  scss/config/mixins/_*.scss   → @mixin recipes
  scss/components/_*.scss      → Applied to default selectors

JS: IIFE components + ln-core helpers
  js/ln-core/                  → Shared helpers (fill, renderList, reactive)
  js/ln-{name}/                → Self-contained IIFE component
```

## Build

```bash
npm run build    # dist/ln-ashlar.css + .js + .iife.js
npm run dev      # Watch mode
```

## Sub-Skills

| File | Content |
|------|---------|
| `references/doctrine.md` | Core doctrine rules — DOM-first, no utility classes, attribute-driven JS; read before writing any ln-ashlar code |
| `css/app-shell.md` | App-shell mixins (header, sidebar-drawer, main, footer, header regions) and global bindings |
| `css/breakpoints.md` | Media vs container-query breakpoint tokens and rules |
| `css/cards.md` | Card and panel mixin reference (`card`, `card-flush`, `panel`, etc.) |
| `css/density.md` | Density variants (compact, default, comfortable) and token values |
| `css/forms.md` | Form layout and input mixin reference (`form-grid`, `input`, `label`, etc.) |
| `css/icons.md` | SVG sprite system, Tabler icons, custom icons |
| `css/mixins.md` | Complete mixin reference with examples |
| `css/tables.md` | Table mixin reference (`table-base`, `table-striped`, etc.) |
| `css/theming.md` | Dark mode, theme tokens, color-scheme |
| `css/tokens.md` | Token values (colors, spacing, radii, shadows) from `_tokens.scss` and `_density.scss` |
| `css/visual-rules.md` | ln-ashlar specific visual rules (§1-§8 implementation) |
| `components/chip.md` | Removable filter token / selected value (chip mixin + SCSS source) |
| `components/data-table.md` | Data table implementation — `ln-table` JS component, store, coordinator wiring |
| `components/empty-state.md` | Empty state implementation — markup, mixin, and zero-data handling |
| `components/form.md` | Form component implementation — `ln-form`, `data-ln-form`, `toFormPayload()` |
| `components/loading-state.md` | Loading state implementation — skeleton, spinner, and state toggling |
| `components/modal.md` | Modal implementation — `data-ln-modal`, trigger/close attributes, events, fill |
| `components/page-header.md` | Standard page title + breadcrumbs + actions |
| `components/popover.md` | Popover / contextual overlay |
| `components/prose.md` | Scoped long-form content typography wrapper |
| `components/search.md` | Search implementation — `ln-search`, `data-ln-search`, client-side filtering |
| `components/stat-card.md` | KPI stat card pattern |
| `components/status-badge.md` | Inline semantic status indicator — colored dot + label, filterable |
| `components/stepper.md` | Linear wizard progress indicator |
| `components/tabs.md` | Tabs implementation — `ln-tabs`, `data-ln-tabs`, active-tab state |
| `components/timeline.md` | Chronological event list (audit log, activity feed) |
| `components/toggles-and-pills.md` | Pill toggles, radio-pill groups, and switch controls (styled form elements) |
| `components/tooltip.md` | Tooltip (hover/focus hint) |
| `js/component-template.md` | Full IIFE boilerplate for new components (naming conventions for `data-ln-*`, events, `window.ln*`) |
| `js/ln-core-api.md` | `fill`, `renderList`, `cloneTemplate`, `reactive`, `batcher`, `dispatch` API reference |
| `patterns/edit-modal-prefill.md` | Shared create/edit modal — declarative `data-ln-fill-*` trigger prefill (no coordinator), `toFormPayload()` backend contract |

## Quick Reference

### CSS — Key Patterns

```scss
// Project integration
@use 'ln-ashlar/scss/ln-ashlar';   // full framework
@use 'scss/overrides';              // project tokens
@use 'scss/components/feature';     // project components

// Mixin on semantic selector
#add-user { @include btn; }
#users article { @include card; }

// Color override via token
#delete-user { --color-primary: var(--color-error); }

// Form grid (6 columns)
#my-form { @include form-grid; }
#my-form .form-element { grid-column: span 3; }

// Container query
#folders { @include container(foldersgrid); }
```

### JS — Key Patterns

```javascript
// Import helpers from ln-core
import { dispatch, fill, renderList, cloneTemplate } from '../ln-core';
import { deepReactive, createBatcher } from '../ln-core';

// Open a modal programmatically (attribute is the single source of truth)
document.getElementById('my-modal').setAttribute('data-ln-modal', 'open');

// Declarative DOM binding
fill(el, { name: user.name, email: user.email });

// Keyed list rendering
renderList(container, items, 'template-name', keyFn, fillFn, 'ln-component');
```

### HTML — Key Patterns

```html
<!-- Icon (SVG sprite) -->
<svg class="ln-icon" aria-hidden="true"><use href="#ln-plus"></use></svg>

<!-- Modal -->
<div class="ln-modal" data-ln-modal id="my-modal">
    <form>
        <header><h3>Title</h3><button type="button" aria-label="Close" data-ln-modal-close>...</button></header>
        <main>...</main>
        <footer><button type="button" data-ln-modal-close>Cancel</button><button type="submit">Save</button></footer>
    </form>
</div>

<!-- Accordion -->
<ul data-ln-accordion>
    <li>
        <header data-ln-toggle-for="panel1">Title</header>
        <main id="panel1" data-ln-toggle class="collapsible">
            <section class="collapsible-body">...</section>
        </main>
    </li>
</ul>
```
