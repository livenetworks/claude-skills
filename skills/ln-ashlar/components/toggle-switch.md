# Toggle Switch

> Canonical docs: `docs/css/toggle-switch.md`
> Source: `scss/config/mixins/_toggle-switch.scss` + `scss/components/_toggle-switch.scss`

---

## Decision: toggle-switch vs checkbox vs radio

| Control | Use when |
|---|---|
| `toggle-switch` | Immediate on/off state change — settings, feature flags, notifications. Effect is instant (no form submit needed). |
| `checkbox` | Deferred selection — value is submitted as part of a form. |
| `radio` | Mutually exclusive choice from a set of named options. |

If the user flips a toggle and the effect happens right away (JS change handler fires an API call), use toggle-switch. If the value is collected alongside other fields and submitted together, use a regular checkbox.

---

## HTML pattern

It is a styled `input[type="checkbox"]` — not a custom element. The browser handles checked state, keyboard interaction, and change events natively.

```html
<label>
	<input type="checkbox" data-ln-toggle-switch>
	Email notifications
</label>
```

With a checked default:

```html
<label>
	<input type="checkbox" data-ln-toggle-switch checked>
	Auto-save drafts
</label>
```

Disabled state:

```html
<label>
	<input type="checkbox" data-ln-toggle-switch disabled>
	Feature flag (locked)
</label>
```

---

## Visual states

| State | Background | Knob position |
|---|---|---|
| Off | `--color-neutral-300` | Left (`left: 2px`) |
| On (`:checked`) | `--color-primary` | Right (`translateX(1rem)`) |
| Disabled | 50% opacity, `cursor: not-allowed` | Unchanged |
| Focus | `focus-ring` outline | Unchanged |

---

## Motion safety

Background color and knob `transform` transitions are wrapped in `@include motion-safe` (`prefers-reduced-motion: no-preference`). Users with reduced-motion see instant state changes.

---

## Accessibility

- Keep the `<input>` in the DOM. Do NOT use `display: none` or `visibility: hidden` — screen readers need the element.
- Wrap in `<label>` so the label text is the accessible name. `aria-label` on the input is an alternative when a visible label is not shown.
- The label text should describe the **thing being toggled**, not the action ("Email notifications", not "Toggle emails").
- State change fires the native `change` event — no custom events needed.

---

## Name conflict note

ln-ashlar has three toggle-related patterns — do not confuse them:
- `data-ln-toggle` — JS collapsible panel (accordion). Unrelated.
- `form-checkbox` mixin — styled checkbox for form submission.
- `data-ln-toggle-switch` — this component: iOS-style immediate on/off.
