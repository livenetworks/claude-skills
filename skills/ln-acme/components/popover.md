# Skill: ln-popover

Decision guide for using the popover component. Full API: `js/ln-popover/README.md` and `docs/js/popover.md`.

## When to use popover vs dropdown vs tooltip

| Need | Use |
|---|---|
| Rich click-triggered content panel (links, form fields, help text, user menu) | **ln-popover** |
| Menu of discrete actions (buttons, links) | **ln-dropdown** |
| Terse hover hint that adds no interactive content | **ln-tooltip** |

The dividing line: if the user needs to interact WITH the content (click a link, fill a field, read a paragraph), use popover. If the content is just a label or one-line hint, use tooltip. If the content is a list of actions, use dropdown.

## Canonical HTML

```html
<!-- Trigger (any focusable element) -->
<button data-ln-popover-for="user-menu">Account</button>

<!-- Popover (sibling or anywhere in DOM — ID is the link) -->
<div data-ln-popover id="user-menu">
	<p>user@example.com</p>
	<a href="/settings">Settings</a>
	<a href="/logout">Sign out</a>
</div>
```

No JS initialization call needed. MutationObserver wires everything on DOM ready.

## Attribute reference

| Attribute | On | Description |
|---|---|---|
| `data-ln-popover` | popover element | Creates the instance; starts closed |
| `data-ln-popover="open"` | popover element | Starts open at page load |
| `data-ln-popover-for="id"` | trigger element | Click toggles the popover with that `id` |
| `data-ln-popover-position` | popover element | Preferred side: `top`, `bottom` (default), `left`, `right` |
| `data-ln-popover-placement` | popover element | Set by JS after auto-flip — reflects actual winning side |

`data-ln-popover` is the single source of truth for state. Setting it to `"open"` opens; anything else closes. JS API methods just set this attribute.

## Imperative API

```javascript
const popover = document.getElementById('my-popover');

popover.lnPopover.open(triggerEl);   // pass trigger for focus return
popover.lnPopover.close();
popover.lnPopover.toggle(triggerEl);
popover.lnPopover.destroy();         // removes all listeners, cleans instance
```

Equivalent: `popover.setAttribute('data-ln-popover', 'open')` — same result.

## Events

All events dispatch on the popover element and bubble.

| Event | Cancelable | When |
|---|---|---|
| `ln-popover:before-open` | yes | Before opening — call `e.preventDefault()` to abort |
| `ln-popover:open` | no | Opened |
| `ln-popover:before-close` | yes | Before closing — call `e.preventDefault()` to abort |
| `ln-popover:close` | no | Closed |
| `ln-popover:destroyed` | no | Instance destroyed |

`detail` on all events: `{ popoverId, target, trigger }`. `trigger` is `null` when opened via direct attribute mutation with no known trigger.

If `before-open` or `before-close` is cancelled, the observer reverts the attribute automatically.

## Focus behavior

- **On open:** focus moves to the first focusable child (input, button, link). If none, the popover container gets focus (auto-assigned `tabindex="-1"`).
- **Tab is NOT trapped.** Popover is a Disclosure, not a modal. Tab cycles the page normally.
- **On Escape close:** focus returns to the trigger.
- **On outside-click close:** focus is NOT returned — the click already established a new target.

## Portal / teleport

On open, the popover element is moved to `<body>` end via `teleportToBody()` from `ln-core`. This makes `position: fixed` coordinates reliable regardless of ancestor `transform` or `contain` rules. The element is restored to its original DOM position on close. This is the same pattern as `ln-dropdown`. See `docs/js/popover.md` and `js/ln-core/README.md` § Positioning Helpers.

## Escape and nested popovers

- Escape closes only the most-recently-opened popover (LIFO stack). Each subsequent Escape closes the next one.
- When popover A is open and a trigger inside A opens B, A stays open (A's outside-click listener checks `dom.contains(target)` — click originated inside A).

## What NOT to do

- Do not use popover for a list of actions → use `ln-dropdown`.
- Do not use popover for a one-liner label → use `ln-tooltip`.
- Do not manually move the popover element in CSS with `transform` ancestors — let `teleportToBody` handle stacking context.
- Do not set `display` or `visibility` directly — all show/hide flows through `data-ln-popover` attribute.
