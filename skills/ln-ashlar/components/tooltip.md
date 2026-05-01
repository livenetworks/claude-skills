# Skill: ln-tooltip

Decision guide for CSS baseline vs JS enhance. Full docs: `docs/js/tooltip.md`, `docs/css/tooltip.md`, `js/ln-tooltip/README.md`, `scss/components/_tooltip.scss`.

## The two modes

| Mode | How | When to use |
|---|---|---|
| CSS baseline | `data-ln-tooltip="text"` | Fixed-position hints that won't clip — works with no JS |
| JS enhance | add `data-ln-tooltip-enhance` | Near viewport edges, in scroll containers, or when `aria-describedby` wiring is required |

**Default to CSS baseline.** Add `-enhance` only when you have a specific reason.

## CSS baseline — canonical HTML

```html
<button data-ln-tooltip="Edit this item">
	<svg class="ln-icon" aria-hidden="true"><use href="#ln-edit"></use></svg>
	<span class="sr-only">Edit</span>
</button>
```

The tooltip text is rendered via `content: attr(data-ln-tooltip)` on `::after`. Pure CSS, zero JS, no events. Position is fixed relative to the element via the stylesheet in `scss/components/_tooltip.scss`.

## JS enhance — canonical HTML

Same markup, add the opt-in flag:

```html
<button data-ln-tooltip="Edit this item" data-ln-tooltip-enhance>
	<svg class="ln-icon" aria-hidden="true"><use href="#ln-edit"></use></svg>
	<span class="sr-only">Edit</span>
</button>
```

When `-enhance` is present, the co-located `ln-tooltip.scss` rule suppresses the CSS `::after` pseudo-element (`content: none`), so only the JS-rendered tooltip node appears. The two never conflict.

## Position preference

```html
<button data-ln-tooltip="Remove" data-ln-tooltip-enhance data-ln-tooltip-position="bottom">
	Delete
</button>
```

`data-ln-tooltip-position` accepts `top` (default), `bottom`, `left`, `right`. JS uses `computePlacement()` from `ln-core` and auto-flips if the preferred side clips the viewport. For full positioning rules see `js/ln-core/README.md` § Positioning Helpers.

## Title fallback and the `<abbr>` pattern

When `data-ln-tooltip` is present but empty, JS enhance reads `title` instead. This enables semantic `<abbr>`:

```html
<abbr data-ln-tooltip data-ln-tooltip-enhance title="International Organization for Standardization">
	ISO
</abbr>
```

While the styled tooltip is visible, the JS layer strips `title` from the element to prevent the browser's native tooltip from appearing alongside it. On hide, `title` is restored.

Without `-enhance`, CSS baseline also triggers (it reads `attr(data-ln-tooltip)` which is empty, so nothing renders). For `<abbr>`, always add `-enhance`.

## Coexistence rule

- CSS `::after` is always active for `[data-ln-tooltip]`.
- When `[data-ln-tooltip-enhance]` is also present, a single rule in `ln-tooltip.scss` sets `::after { content: none }` to suppress the CSS version.
- This rule is purely additive — un-enhanced elements are unaffected.

## No events by design

Tooltip dispatches no show/hide events. It is a purely presentational hover/focus affordance. The only event is `ln-tooltip:destroyed` (fired when cleanup removes a JS-enhanced instance). See architectural reasoning in `docs/js/tooltip.md`.

## Attributes

| Attribute | On | Description |
|---|---|---|
| `data-ln-tooltip="text"` | trigger | Tooltip text. Empty value triggers title fallback in JS mode. |
| `data-ln-tooltip-enhance` | trigger | Opt-in flag for JS positioning + aria wiring |
| `data-ln-tooltip-position` | trigger | Preferred side: `top` (default), `bottom`, `left`, `right` |

## What NOT to do

- Do not add `-enhance` on every tooltip by default — CSS baseline is lighter and sufficient for stable layouts.
- Do not use tooltip for interactive content (links, buttons) — use `ln-popover`.
- Do not rely on tooltip text for required information — tooltips are a redundant affordance, not a primary label.
