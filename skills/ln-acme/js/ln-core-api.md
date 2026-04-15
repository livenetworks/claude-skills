# ln-acme — ln-core API Reference

> Shared helpers imported by all ln-acme components. Located in `js/ln-core/`.
> For architecture principles → global js skill §9 (three layers), §11 (reactive state).

---

## Import Pattern

Imports go **outside** the IIFE — Vite resolves at build time:

```javascript
// helpers.js — DOM, events, templates, list rendering
import { cloneTemplate, cloneTemplateScoped, dispatch, dispatchCancelable, fill, renderList, buildDict, guardBody, findElements } from '../ln-core';

// reactive.js — state proxies and batching
import { reactiveState, deepReactive, createBatcher } from '../ln-core';

// persist.js — localStorage helpers (v1.1)
import { persistGet, persistSet, persistRemove, persistClear } from '../ln-core';

// positioning.js — floating UI helpers (v1.2)
import { computePlacement, teleportToBody, measureHidden } from '../ln-core';
```

---

## Event Helpers (helpers.js)

### `dispatch(el, name, detail)`

Non-cancelable, bubbling CustomEvent.

```javascript
dispatch(element, 'ln-modal:open', { id: 'my-modal' });
```

### `dispatchCancelable(el, name, detail)`

Cancelable CustomEvent. Returns the event object — check `defaultPrevented`.

```javascript
const event = dispatchCancelable(element, 'ln-modal:before-open', { id: 'my-modal' });
if (event.defaultPrevented) return; // External listener cancelled
```

---

## Template Helpers (helpers.js)

### `cloneTemplate(name, tag)`

Clone a `<template data-ln-template="{name}">`. Caches on first use. Returns DocumentFragment or `null`.

```javascript
const fragment = cloneTemplate('track-item', 'ln-playlist');
if (!fragment) return; // Template missing — already warned
```

### `findElements(root, selector, attribute, ComponentClass)`

Find and initialize component instances. Standard auto-init pattern.

### `guardBody(setupFn, componentTag)`

Defer execution until `<body>` exists. Use in components that run before DOM is ready.

---

## Declarative DOM Binding (helpers.js)

### `fill(root, data)`

Replaces querySelector + textContent chains. Idempotent — call again with new data.

#### Data Attributes

| Attribute | Effect | Example |
|-----------|--------|---------|
| `data-ln-field="prop"` | `el.textContent = data[prop]` | `<p data-ln-field="name"></p>` |
| `data-ln-attr="attr:prop, ..."` | `el.setAttribute(attr, data[prop])` | `<img data-ln-attr="src:avatar, alt:name">` |
| `data-ln-show="prop"` | `el.classList.toggle('hidden', !data[prop])` | `<span data-ln-show="isAdmin">Admin</span>` |
| `data-ln-class="cls:prop, ..."` | `el.classList.toggle(cls, !!data[prop])` | `<li data-ln-class="active:isSelected">` |

#### Usage

```html
<template data-ln-template="user-item">
	<li data-ln-class="active:isSelected">
		<img data-ln-attr="src:avatar, alt:name">
		<p data-ln-field="name"></p>
		<p data-ln-field="email"></p>
		<span data-ln-show="isAdmin">Admin</span>
	</li>
</template>
```

```javascript
fill(el, {
	name: user.name,
	email: user.email,
	avatar: user.avatar,
	isAdmin: user.role === 'admin',
	isSelected: user.id === selectedId
});
```

#### Rules

- `fill` is idempotent — call again with new data, DOM updates
- `null`/`undefined` values are skipped (existing content preserved)
- Works on live DOM and on `<template>` clones (DocumentFragment)
- `data-ln-field` uses `textContent` only — not `innerHTML`

---

## Keyed List Rendering (helpers.js)

### `renderList(container, items, templateName, keyFn, fillFn, tag)`

Efficiently renders an array with DOM reuse via `data-ln-key`.

```javascript
renderList(
	this.dom.querySelector('[data-ln-list="users"]'),  // container
	this.state.users,                                   // data array
	'user-item',                                        // template name
	function (u) { return u.id; },                      // key function (stable ID)
	function (el, user, idx) {                          // fill function
		fill(el, { name: user.name, email: user.email });
	},
	'ln-user-list'                                      // component tag (for warnings)
);
```

#### How it works

1. Index existing children by `data-ln-key` attribute
2. For each item: find existing node by key → call fillFn (reuse). Or clone template → set key → call fillFn (new).
3. Atomic DOM replacement: `container.textContent = ''; container.appendChild(fragment)`

#### Rules

- `keyFn` returns a **stable unique identifier** (database ID, not array index)
- Existing DOM nodes are reused — event listeners, focus state survive
- Container uses `data-ln-list="name"` convention
- One reflow per render (atomic update)

---

## Reactive State (reactive.js)

### `reactiveState(initial, onChange)`

Shallow Proxy for flat state (strings, numbers, booleans).

```javascript
this.state = reactiveState({
	mode: 'view',
	isOpen: false
}, function (prop, value, old) {
	queueRender();
});

this.state.mode = 'edit'; // triggers onChange
```

### `deepReactive(obj, onChange)`

Deep Proxy for nested objects and arrays.

```javascript
this.state = deepReactive({
	users: [],
	selectedId: null,
	filter: ''
}, queueRender);

// All trigger queueRender automatically:
this.state.users.push({ id: 1, name: 'New' });
this.state.users[0].name = 'Updated';
this.state.users.splice(1, 1);
this.state.selectedId = 3;
```

### `createBatcher(renderFn, afterRenderFn)`

Microtask coalescing — multiple sync state changes → one render.

```javascript
const queueRender = createBatcher(
	function () { self._render(); },
	function () { dispatch(self.dom, 'ln-{name}:changed', {}); }
);
```

**Always** use createBatcher between Proxy and _render. Never wire onChange directly to _render().

```
state.name = 'A'     → queueRender() [queued via queueMicrotask]
state.email = 'B'    → queueRender() [already queued, skip]
state.role = 'admin' → queueRender() [already queued, skip]
--- microtask checkpoint ---
_render() fires ONCE
afterRender() fires ONCE
```

---

## Attribute ↔ Proxy Bridge

External control (coordinator → component) via attributes. Bridge syncs to Proxy state.

```javascript
_component.prototype._onAttr = function (attrName, newValue) {
	const prefix = DOM_SELECTOR + '-';
	if (attrName.indexOf(prefix) === 0) {
		const prop = attrName.slice(prefix.length);
		if (this.state[prop] !== newValue) {
			this.state[prop] = newValue;  // Proxy → queueRender → _render
		}
	}
};
```

Coordinator controls component via attributes:
```javascript
profileEl.setAttribute('data-ln-profile-mode', 'edit');
// → MutationObserver → _onAttr → this.state.mode = 'edit' → _render()
```

For components with state attributes, add to `attributeFilter`:
```javascript
attributeFilter: [DOM_SELECTOR, DOM_SELECTOR + '-mode', DOM_SELECTOR + '-for']
```

---

## Persist Helpers (persist.js) — v1.1

localStorage state persistence scoped to component + page + element key.

### Signatures

```javascript
persistGet(component, el)              // → JSON value | null
persistSet(component, el, value)       // stores JSON.stringify(value)
persistRemove(component, el)           // removes single key
persistClear(component)                // removes ALL keys for this component name
```

- `component` — string name, e.g. `'tabs'`, `'filter'`, `'table-sort'`
- `el` — the component's root element (must have `id` or `data-ln-persist`)
- `value` — any JSON-serializable value

### Storage Key Format

Keys are namespaced:

```
ln:<component>:<page-path>:<id>
```

- `<page-path>` — `location.pathname`, trailing slash stripped, lowercased (e.g. `/documents/42`)
- `<id>` — `data-ln-persist` attribute value if non-empty; otherwise `el.id`

This means the same component on two different pages does not share state.

### HTML Opt-In

Add `data-ln-persist` to the component element to enable persistence:

```html
<!-- Use element id as the key suffix -->
<ul id="doc-tabs" data-ln-tabs data-ln-persist>...</ul>

<!-- Use explicit key suffix (overrides id) -->
<ul data-ln-tabs data-ln-persist="my-tabs-key">...</ul>
```

Components only call `persistGet`/`persistSet` when `data-ln-persist` is present on their root. No attribute = no reads or writes.

### Silent No-Op

All functions catch exceptions silently. Safe in private/incognito browsing, server-side environments, and when localStorage is full.

### Components Using This Helper

| Component | `component` string passed |
|-----------|--------------------------|
| `ln-toggle` | `'toggle'` |
| `ln-tabs` | `'tabs'` |
| `ln-table` (sort) | `'table-sort'` — reads `data-ln-persist` on `[data-ln-table]` wrapper |
| `ln-filter` | `'filter'` |

---

## Positioning Helpers (positioning.js) — v1.2

Pure helpers for floating UI (popovers, tooltips, dropdowns). Used by `ln-popover`, `ln-tooltip`, and `ln-dropdown`.

### `computePlacement(anchorRect, floatingSize, preferred, offset)`

Compute viewport coordinates for a floating element. Pure function — no DOM side effects.

```javascript
const { top, left, placement } = computePlacement(
	anchor.getBoundingClientRect(),  // anchorRect — DOMRect or plain object
	{ width: 240, height: 120 },     // floatingSize
	'bottom',                        // preferred side: 'top'|'bottom'|'left'|'right'
	8                                // offset in px (default: 4)
);
```

**Return shape:** `{ top: number, left: number, placement: string }`

`placement` is the side that was actually used (may differ from `preferred` after flip).

**Auto-flip chain:**

| Preferred | Flip order |
|-----------|-----------|
| `bottom` | bottom → top → right → left |
| `top` | top → bottom → right → left |
| `left` | left → right → top → bottom |
| `right` | right → left → top → bottom |

If no side fits cleanly, falls back to the preferred side and clamps coordinates to viewport.

**Default offset:** `4` (used when `offset` argument is omitted or not a number).

### `teleportToBody(el)`

Move an element to `<body>` for stacking context escape. Leaves a comment placeholder at the original position so the element can be restored.

```javascript
const restore = teleportToBody(el);
// el is now a direct child of <body>

restore(); // returns el to its original parent position
```

- Returns a `restore()` cleanup function — always call it on component teardown.
- If `el` is already a direct child of `<body>`, returns a no-op cleanup.
- Does NOT set any inline styles — the component's SCSS handles `position: fixed`.

### `measureHidden(el)`

Measure an element that may be `display: none`, without visible flicker.

```javascript
const { width, height } = measureHidden(el);
```

Temporarily forces `visibility: hidden; display: block; position: fixed` to allow layout, reads `offsetWidth`/`offsetHeight`, then restores all three properties before returning. Returns `{ width: 0, height: 0 }` if `el` is falsy.
