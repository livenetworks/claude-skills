# ln-ashlar — JS Component Template

> Full component boilerplate for creating new ln-ashlar components.
> Uses `registerComponent` from ln-core — the universal init mechanism for all 34+ library components.
> For architecture principles → global js skill.

---

## Naming Conventions

| Element | Convention | Example |
|---------|-----------|---------|
| Data attribute | `data-ln-{component}` | `data-ln-modal` |
| Window API | `window.ln{Component}` | `window.lnModal` |
| DOM instance | `el.ln{Component}` | `el.lnModal` |
| Custom event (notification) | `ln-{component}:{action}` | `ln-modal:open` |
| Custom event (request) | `ln-{component}:request-{action}` | `ln-data-store:request-create` |
| Custom event (before, cancelable) | `ln-{component}:before-{action}` | `ln-modal:before-close` |
| Private function | `_functionName` | `_render`, `_tick` |
| Dictionary attribute | `data-ln-{component}-dict` | `data-ln-toast-dict` |
| State attribute | `data-ln-{component}-{prop}` | `data-ln-profile-mode` |
| Trigger | `data-ln-{component}-for` | `data-ln-modal-for` |
| Template | `data-ln-template="{name}"` | `data-ln-template="row"` |

---

## Complete Component Template

```javascript
import { registerComponent, dispatch, dispatchCancelable, fill, renderList, deepReactive, createBatcher } from '../ln-core';

(function () {
	const DOM_SELECTOR = 'data-ln-{name}';
	const DOM_ATTRIBUTE = 'ln{Name}';

	if (window[DOM_ATTRIBUTE] !== undefined) return;

	// --- Module-level state (shared across ALL instances) ---
	// e.g. formatter cache, shared interval pool, template cache

	// --- Constructor ---
	function _component(dom) {
		this.dom = dom;
		const self = this;

		const queueRender = createBatcher(
			function () { self._render(); },
			function () { dispatch(self.dom, 'ln-{name}:changed', {}); }
		);

		this.state = deepReactive({
			// initial state
		}, queueRender);

		this._bindEvents();
		return this;
	}

	// --- Instance methods (on prototype) ---

	_component.prototype._bindEvents = function () {
		const self = this;
		this.dom.addEventListener('ln-{name}:request-{action}', function (e) {
			// Just change state — render is automatic via proxy → batcher
			self.state.prop = e.detail.value;
		});
	};

	_component.prototype._render = function () {
		fill(this.dom, { /* scalar bindings */ });
		renderList(
			this.dom.querySelector('[data-ln-list]'),
			this.state.items,
			'{name}-item',                         // template name
			function (item) { return item.id; },   // key fn (stable id)
			function (el, item) { fill(el, item); },
			'ln-{name}'
		);
	};

	_component.prototype._onAttr = function (attrName, newValue) {
		// Called by registerComponent's onAttributeChange hook.
		// Maps external attribute → internal proxy state → automatic re-render.
		const prefix = DOM_SELECTOR + '-';
		if (attrName.indexOf(prefix) === 0) {
			const prop = attrName.slice(prefix.length);
			if (this.state[prop] !== newValue) {
				this.state[prop] = newValue;
			}
		}
	};

	// Public query API (reads only — mutations go through request events)
	Object.defineProperty(_component.prototype, 'selectedId', {
		get: function () { return this.state.selectedId; }
	});

	_component.prototype.destroy = function () {
		// Remove pool memberships, disconnect own observers, remove stored listeners.
		dispatch(this.dom, 'ln-{name}:destroyed', {});
		delete this.dom[DOM_ATTRIBUTE];
	};

	// --- Boot via Core Registration ---
	// registerComponent handles: guardBody, MutationObserver (childList + attributes),
	// attributeFilter, findElements, window[attribute] = constructor, DOMContentLoaded.
	registerComponent(DOM_SELECTOR, DOM_ATTRIBUTE, _component, 'ln-{name}', {
		// extraAttributes: ['data-ln-{name}-mode'],   // extra attrs to watch
		// onAttributeChange: function (el, attrName) {
		//     el[DOM_ATTRIBUTE]._onAttr(attrName, el.getAttribute(attrName));
		// },
		// onInit: function (root) { /* runs after findElements, per added subtree */ }
	});
})();
```

### What `registerComponent` does

`registerComponent(selector, attribute, ComponentFn, componentTag, options)` from ln-core:

1. Calls `guardBody` so the observer never runs before `<body>` exists.
2. Runs `findElements(document.body, ...)` on `DOMContentLoaded` (or immediately if DOM is ready).
3. Sets `window[attribute] = constructor` — the constructor re-runs `findElements` on a subtree.
4. Sets up a single `MutationObserver` on `document.body`:
   - `childList` — new element added → `findElements` + optional `onInit`.
   - `attributes` (filtered) — existing element attribute changes:
     - If element is initialized AND `onAttributeChange` is set → calls `onAttributeChange`.
     - Otherwise → `findElements` (handles late `data-ln-x` stamp on existing element).
5. Auto-calls `destroy()` when an initialized element is removed from the DOM.
6. Builds `attributeFilter` from the selector plus `extraAttributes`.

The constructor returned by `registerComponent` is also stored at `window[attribute]`. Call
`window.ln{Name}(subtreeRoot)` to re-initialize a dynamically injected subtree.

### Four conventions every component follows

- **Paired `DOM_SELECTOR` / `DOM_ATTRIBUTE` constants.** `data-ln-{name}` is the HTML hook;
  `ln{Name}` is the JS key for both `window` registration and per-element instance.
  Derive both from the same stem: `data-ln-modal` ↔ `lnModal`.

- **Instance lives on the DOM element, not on `window`.** `window.lnModal` is the constructor.
  Each `[data-ln-modal]` element carries its own instance at `el.lnModal`. Multiple instances
  coexist; no global registry.

- **Paired before/after events for state changes.** `ln-{name}:before-{action}` (cancelable,
  before) and `ln-{name}:{action}` (non-cancelable, after).

- **`destroy()` is a contract.** Removes pool memberships, disconnects own per-instance observers,
  removes stored `addEventListener` references, deletes `el[DOM_ATTRIBUTE]`.

---

## Global Service Template (no DOM instances)

Not every component needs a per-element instance. A global service is a document-level event
listener that any element dispatches to. `ln-fill` and `ln-http` follow this shape.

```javascript
(function () {
	const DOM_ATTRIBUTE = 'lnHttp';
	if (window[DOM_ATTRIBUTE] !== undefined) return;

	document.addEventListener('ln-http:request', function (e) {
		if (e.ctrlKey || e.metaKey || e.button === 1) return;
		const opts = e.detail || {};
		if (!opts.url) return;
		// ... fetch, dispatch response on e.target
		dispatch(e.target, 'ln-http:success', { tag: opts.tag, ok: true, data: data });
	});

	window[DOM_ATTRIBUTE] = true;  // boolean sentinel — not a constructor
})();
```

---

## Fill / Coordinator Boundary

**Click-triggered fills are declarative — zero coordinator JS required.**

```html
<button
    data-ln-modal-for="pkg-modal"
    data-ln-fill-form="pkg-form"
    data-ln-fill-id="{{ id }}"
    data-ln-fill-name="{{ name }}"
>Edit</button>
```

- `data-ln-fill-form` — points to the target `<form id>`.
- `data-ln-fill-*` — each key becomes a record field (`lnFill-event-id` → `{ eventId: "42" }`).
- `{{ id }}` / `{{ name }}` in row templates are stamped by `fillTemplate()` at clone time.
- `ln-fill` (the global service) reads these on click and calls `window.lnCore.lnFill(form, record)`.

**Programmatic fills go through the coordinator.**

```javascript
// Coordinator — after store conflict or deep-link navigation
window.lnCore.lnFill(modalEl, e.detail.serverRecord);
modalEl.setAttribute('data-ln-modal', 'open');
```

| Trigger | Pattern |
|---------|---------|
| User clicks a button or table row action | `data-ln-fill-form` + `data-ln-fill-*` attributes |
| Programmatic / store-event-driven | `window.lnCore.lnFill(container, record)` in coordinator |

---

## Zero Display Text — Hard Rule

**Components contain zero user-facing strings.** No "Loading…", "No results", "Delete", "Close".

All display text comes from:
- `<template>` elements — Blade renders translated text.
- `data-ln-{component}-dict` — `buildDict` reads at init, Blade provides the strings.
- `Intl` API — for dates, numbers, currency.

Console `warn` messages (`[ln-{name}] Missing datetime attribute`) are developer-only — never user-facing.

---

## Checklist: New Component

1. Create `js/ln-{name}/src/ln-{name}.js` — IIFE from `registerComponent` template above
2. Add `import './ln-{name}/src/ln-{name}.js'` to `js/index.js`
3. DOM structure → `<template data-ln-template>` elements in HTML
4. Create `js/ln-{name}/README.md` — attributes, events, API, HTML examples
5. Create `docs/js/{name}.md` — internal state, render flow, event lifecycle
6. Create `demo/admin/{name}.html` — interactive demo page

## Checklist: Update Existing Component

1. Update `js/ln-{name}/README.md` — reflect new/changed usage
2. Update `docs/js/{name}.md` — reflect architectural changes
3. Update `demo/admin/{name}.html` — add/update examples
