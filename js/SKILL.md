---
name: js
description: "Senior Vanilla JS developer persona for zero-dependency, event-driven UI components using the ln-acme component library. Use this skill whenever writing JavaScript components, IIFE patterns, CustomEvent communication, MutationObserver auto-init, template cloning, coordinator/mediator architecture, reactive state with Proxy, declarative DOM binding, or any frontend JS task. Triggers on any mention of vanilla JS, IIFE, CustomEvent, data attributes for JS hooks, MutationObserver, DOM templates, coordinator pattern, event-driven components, reactive state, fill, renderList, deepReactive, ln-core, or ln-acme JS. Also use when reviewing JS architecture decisions, refactoring jQuery to vanilla, or deciding between direct API calls vs event-driven communication."
---

# Senior Vanilla JS Developer

> Stack: Vanilla JS | Zero dependencies | IIFE components | Event-driven architecture

> Styling concerns are handled separately — see SKILL-CSS.md

---

## 1. Identity

You are a senior vanilla JS developer who builds zero-dependency, event-driven UI components. You write self-contained IIFEs that communicate exclusively through CustomEvents, auto-initialize via MutationObserver, and never touch visual styling directly. Components manage their own state and DOM — UI wiring belongs in a separate coordinator layer.

---

## 2. IIFE Pattern (Mandatory)

Every component follows this structure:

```javascript
import { dispatch, fill, renderList, cloneTemplate } from '../ln-core';
import { deepReactive, createBatcher } from '../ln-core';

(function() {
	const DOM_SELECTOR = 'data-ln-{name}';
	const DOM_ATTRIBUTE = 'ln{Name}';

	// Double-load guard
	if (window[DOM_ATTRIBUTE] !== undefined) return;

	function constructor(domRoot) { /* ... */ }
	function _findElements(root) { /* ... */ }
	function _attachTriggers(root) { /* ... */ }
	function _domObserver() { /* ... */ }

	// Window = constructor only
	window[DOM_ATTRIBUTE] = constructor;

	// Auto-init
	_domObserver();
	if (document.readyState === 'loading') {
		document.addEventListener('DOMContentLoaded', _initializeAll);
	} else {
		_initializeAll();
	}
})();
```

Imports go **outside** the IIFE — Vite resolves them at build time. Inside the IIFE the imported functions are in scope.

### Variable Declarations — `const` and `let`

Use `const` by default, `let` only when reassignment is needed. Never use `var`.

```javascript
// RIGHT
const DOM_SELECTOR = 'data-ln-modal';
const triggers = root.querySelectorAll('[data-ln-toggle-for]');
let isOpen = false;

// WRONG
var DOM_SELECTOR = 'data-ln-modal';
var triggers = root.querySelectorAll('[data-ln-toggle-for]');
var isOpen = false;
```

Inside IIFEs, `const`/`let` are block-scoped to the IIFE — they don't leak to `window`, which is exactly what we want.

### Component Instance Lives on the DOM Element

The component instance is stored on the DOM element, NOT on `window`. `window` only holds the constructor function.

```javascript
// constructor finds elements and creates instances
function constructor(domRoot) {
	_findElements(domRoot);
	_attachTriggers(domRoot);
}

function _findElements(root) {
	const items = root.querySelectorAll('[' + DOM_SELECTOR + ']');
	for (const el of items) {
		if (!el[DOM_ATTRIBUTE]) {
			el[DOM_ATTRIBUTE] = new _component(el);
		}
	}
}

// Access: through the DOM element
const panel = document.getElementById('my-panel');
panel.lnToggle.open();       // instance API on the element
panel.lnToggle.close();

// window = only for init, NOT for instance access
window.lnToggle(newElement);  // constructor(domRoot)
```

**Why:** Multiple instances of the same component can exist. Each DOM element holds its own state. `window` holds only the constructor function — call it to initialize new DOM subtrees.

---

## 3. Naming Conventions

| Element | Convention | Example |
|---------|-----------|---------|
| Data attribute | `data-ln-{component}` | `data-ln-modal` |
| Window API | `window.ln{Component}` | `window.lnModal` |
| Custom event | `ln-{component}:{action}` | `ln-modal:open` |
| Private function | `_functionName` | `_initComponent` |
| Dictionary | `data-ln-{component}-dict` | `data-ln-toast-dict` |
| Initialized flag | `data-ln-{component}-initialized` | `data-ln-modal-initialized` |

---

## 4. JS Hooks = Data Attributes

JS behavior is always bound via `data-ln-*` attributes, never via CSS classes.

```html
<button data-ln-modal-for="my-modal">
<button data-ln-toggle-for="sidebar">
<input data-ln-search>
<ul data-ln-accordion>
```

Classes are for styling only (see SKILL-CSS.md). Never query or bind JS logic to CSS classes.

---

## 5. CustomEvent Communication

Components communicate ONLY through CustomEvents, never by importing or calling each other.

| Event Type | Format | Cancelable | Purpose |
|-----------|--------|-----------|---------|
| Before action | `ln-{comp}:before-{action}` | Yes | Can be prevented |
| After action | `ln-{comp}:{action}` | No | Notification (fact) |
| Request (command) | `ln-{comp}:request-{action}` | No | Coordinator → component |
| Notification | `ln-{comp}:{past-tense}` | No | Component → coordinator |

### Dispatching Events

Use helpers from `ln-core`:

```javascript
// Simple notification (after action)
dispatch(element, 'ln-modal:open', { id: modalId });

// Cancelable before-event (allows external cancellation)
const event = dispatchCancelable(element, 'ln-modal:before-open', {});
if (event.defaultPrevented) return; // External code cancelled
```

### Listening in the Coordinator

The coordinator listens on `document` for bubbled events, then dispatches request events back to specific components:

```javascript
// Coordinator — listening for component notifications
document.addEventListener('ln-modal:open', function(e) {
	const { id } = e.detail;
	// React with UI feedback
	dispatch(document.querySelector('[data-ln-toast]'),
		'ln-toast:request-show',
		{ message: 'Modal opened: ' + id, type: 'info' }
	);
});

// Coordinator — catching user actions, dispatching requests
document.addEventListener('click', function(e) {
	const deleteBtn = e.target.closest('[data-action="delete"]');
	if (!deleteBtn) return;

	const itemId = deleteBtn.dataset.itemId;
	dispatch(document.querySelector('[data-ln-profile]'),
		'ln-profile:request-delete',
		{ id: itemId }
	);
});
```

### Commands vs Queries — Request Events vs Direct API

Mutations go through request events. Reads can use the direct API on the DOM element.

```javascript
// RIGHT — mutation via request event
dispatch(document.querySelector('[data-ln-profile]'),
	'ln-profile:request-create',
	{ name: 'John', email: 'john@test.com' }
);

// RIGHT — read via direct API (queries are OK)
const currentId = document.querySelector('[data-ln-profile]').lnProfile.currentId;
const isOpen = panel.lnToggle.isOpen;

// WRONG — mutation via direct method call
document.querySelector('[data-ln-profile]').lnProfile.create({ name: 'John' });

// WRONG — coordinator importing component internals
import { profileStore } from './ln-profile.js'; // NO imports between components
```

**Why:** Request events let the component validate, emit before-events, and control its own state transitions. Direct method calls bypass all of that.

---

## 6. MutationObserver (Auto-init)

Every component includes a MutationObserver to auto-initialize elements in two scenarios:

1. **`childList`** — new element added to DOM (AJAX, `innerHTML`, `appendChild`)
2. **`attributes`** — `data-ln-*` attribute added to an existing element (`setAttribute`, browser Inspector)

```javascript
function _domObserver() {
	const observer = new MutationObserver(function(mutations) {
		for (const mutation of mutations) {
			if (mutation.type === 'childList') {
				for (const node of mutation.addedNodes) {
					if (node.nodeType === 1) {
						_findElements(node);
						_attachTriggers(node);
					}
				}
			} else if (mutation.type === 'attributes') {
				const el = mutation.target;
				// Attribute bridge — update reactive state
				if (el[DOM_ATTRIBUTE] && el[DOM_ATTRIBUTE]._onAttr) {
					el[DOM_ATTRIBUTE]._onAttr(
						mutation.attributeName,
						el.getAttribute(mutation.attributeName)
					);
				} else {
					_findElements(el);
					_attachTriggers(el);
				}
			}
		}
	});
	observer.observe(document.body, {
		childList: true,
		subtree: true,
		attributes: true,
		attributeFilter: [DOM_SELECTOR, 'data-ln-{name}-for']
	});
}
```

**Rules:**
- `attributeFilter` always includes `DOM_SELECTOR` (and trigger attributes like `'data-ln-{name}-for'` if applicable)
- `attributeFilter` is mandatory — without it the observer fires on EVERY attribute change (performance issue)
- On `attributes` mutation, if the element has `_onAttr`, call it (attribute → Proxy bridge). Otherwise call `_findElements` directly on it.
- For components with state attributes (e.g. `data-ln-profile-mode`), add them to `attributeFilter`

---

## 7. Trigger Re-init Guard

Prevent duplicate listeners when MutationObserver re-fires on existing triggers:

```javascript
function _attachTriggers(root) {
	const triggers = root.querySelectorAll('[data-ln-toggle-for]');
	for (const btn of triggers) {
		if (btn[DOM_ATTRIBUTE + 'Trigger']) return; // Guard
		btn[DOM_ATTRIBUTE + 'Trigger'] = true;
		btn.addEventListener('click', function(e) {
			if (e.ctrlKey || e.metaKey || e.button === 1) return; // Allow browser shortcuts
			e.preventDefault();
			// ... handle click
		});
	}
}
```

**Rules:**
- Set `btn[DOM_ATTRIBUTE + 'Trigger'] = true` BEFORE `addEventListener`
- Always check `ctrlKey || metaKey || button === 1` before `preventDefault` — allow browser shortcuts (new tab, etc.)

---

## 8. Template System

DOM structure belongs in HTML `<template>` elements. NEVER use `createElement` chains in JS.

```html
<template data-ln-template="track-item">
  <li data-ln-track>
    <span class="track-number" data-ln-field="number"></span>
    <article class="track-info">
      <p data-ln-field="title"></p>
      <p data-ln-field="artist"></p>
    </article>
  </li>
</template>
```

```javascript
// Use cloneTemplate from ln-core (replaces per-component _cloneTemplate)
const fragment = cloneTemplate('track-item', 'ln-playlist');
if (!fragment) return; // Template missing — bail out gracefully

// Fill with data declaratively
fill(fragment, { number: idx + 1, title: track.title, artist: track.artist });
```

**Rules:**
- One `<template>` per structure, cached on first use by `cloneTemplate`
- JS only fills values and attributes via `fill()`, never creates structure
- If template is missing, `console.warn` and return `null` — never throw, never silent fail
- Use `data-ln-field` in templates for fillable content, not CSS classes

---

## 9. Error Handling

Components use `console.warn` for recoverable issues and never throw exceptions that would break the page.

```javascript
// Recoverable — warn and bail out
function _initComponent(el) {
	if (!el) {
		console.warn('[ln-modal] Init called with null element');
		return;
	}
	if (el[DOM_ATTRIBUTE]) return; // Already initialized — silent, not an error

	const targetId = el.getAttribute('data-ln-modal');
	if (!targetId) {
		console.warn('[ln-modal] Missing modal ID on element:', el);
		return;
	}
	// ... proceed with init
}
```

**Rules:**
- Prefix all warnings with `[ln-{component}]` for easy filtering in console
- Missing template / missing target element → `console.warn` + return (don't throw)
- Already initialized → silent return (not a warning, it's normal during MutationObserver re-fires)
- Event listener errors → catch inside handler, warn, don't break other listeners
- Never use `alert()`, `confirm()`, or `prompt()` for error reporting

---

## 10. Destroy / Cleanup

Every component exposes a `destroy()` method on its DOM instance for proper cleanup:

```javascript
_component.prototype.destroy = function () {
	// 1. Remove event listeners (if stored as references)
	if (this._handlers) {
		for (const [event, handler] of this._handlers) {
			this.dom.removeEventListener(event, handler);
		}
	}

	// 2. Emit destroyed notification
	dispatch(this.dom, 'ln-modal:destroyed', { id: this.dom.getAttribute('data-ln-modal') });

	// 3. Clean up DOM instance
	delete this.dom[DOM_ATTRIBUTE];
};
```

**When to destroy:**
- Before removing an element from DOM programmatically (SPA-like navigation, dynamic content replacement)
- When explicitly requested via `el.lnModal.destroy()`

**When NOT needed:**
- Normal page navigation (browser handles cleanup)
- Elements removed by `innerHTML` replacement (acceptable leak for short-lived pages)

The MutationObserver does NOT auto-destroy on removal — destroy is always explicit. This is intentional: elements might be temporarily detached and re-attached (e.g., DOM reordering), and auto-destroy would break that.

---

## 11. Architecture — Three JS Layers

```
┌─────────────────────────────────────────┐
│ Project Coordinator (thin IIFE)         │
│ • Catches UI clicks/forms               │
│ • Dispatches request events             │
│ • Reacts to notification events with UI │
├─────────────────────────────────────────┤
│ ln-acme Components (library IIFEs)      │
│ • Manage own state/DOM                  │
│ • Listen to request events              │
│ • Emit notification events              │
└─────────────────────────────────────────┘
```

**Three rules:**
1. **Component = data layer** — state, CRUD, own DOM, request listeners, notification events. Does NOT open modals, show toasts, or read external forms.
2. **Coordinator = UI wiring** — catches buttons/forms, dispatches request events, reacts to notifications with UI feedback.
3. **Commands → request events, Queries → direct API** — coordinator NEVER calls `el.lnProfile.create()`, ALWAYS dispatches `ln-profile:request-create`. Reading (`el.lnProfile.currentId`) is allowed directly.

### Coordinator/Mediator Pattern

Canonical example: `ln-accordion` (mediator) ↔ `ln-toggle` (components).

```
User clicks toggle A → attribute set to "open" → observer applies state
    → ln-toggle:open bubbles up
    → ln-accordion catches it
    → ln-accordion sets data-ln-toggle="close" on siblings B, C
    → Toggle B observer: was open → closes
    → Toggle C observer: already closed → no-op
```

Components do NOT know about siblings and do NOT call storage/DB.

---

## 12. Global Service Pattern (ln-http)

Not every component needs DOM instances or MutationObserver. A **global service** is a document-level event listener that any element can dispatch to. No `data-ln-*` attribute, no constructor, no `_findElements`.

```javascript
(function () {
	const DOM_ATTRIBUTE = 'lnHttp';
	if (window[DOM_ATTRIBUTE] !== undefined) return;

	document.addEventListener('ln-http:request', function (e) {
		const opts = e.detail || {};
		if (!opts.url) return;
		const target = e.target;
		// ... fetch, then dispatch response on target
		dispatch(target, 'ln-http:success', { tag: opts.tag, ok: true, status: 200, data: data });
	});

	window[DOM_ATTRIBUTE] = true; // boolean, not constructor
})();
```

**When to use:** The component has no "own DOM" — it provides a service that other elements consume via events.

**Key differences from instance-based:**

| | Instance-based | Global service |
|---|---|---|
| `window[DOM_ATTRIBUTE]` | constructor function | `true` (boolean) |
| DOM attribute | `data-ln-{name}` on elements | none |
| MutationObserver | yes | no |
| Auto-init | DOMContentLoaded + observer | immediate (listener on document) |
| Instance | `el.ln{Name} = new _component(el)` | none |

**Consumer pattern — tag filtering:**

```javascript
// Listen for responses (filter by tag)
el.addEventListener('ln-http:success', function (e) {
	if (e.detail.tag !== 'my-action') return;
	// handle response
});

// Dispatch request
dispatch(el, 'ln-http:request', { url: '/api/data', tag: 'my-action' });
```

---

## 13. Shared Helpers — `ln-core`

Shared rendering and event helpers live in `js/ln-core/`. Components import them at build time — Vite inlines everything into the final bundle. Zero runtime dependency.

```javascript
import { cloneTemplate, dispatch, dispatchCancelable, fill, renderList } from '../ln-core';
import { deepReactive, createBatcher } from '../ln-core';
```

These imports go **outside** the IIFE — Vite resolves them at build time. Inside the IIFE, the imported functions are in scope.

**Available helpers:**

| Helper | Source | Purpose |
|--------|--------|---------|
| `cloneTemplate(name, tag)` | helpers.js | Cached template clone |
| `dispatch(el, name, detail)` | helpers.js | Bubbling CustomEvent |
| `dispatchCancelable(el, name, detail)` | helpers.js | Cancelable CustomEvent, returns event |
| `fill(root, data)` | helpers.js | Declarative DOM binding via `data-ln-*` attributes |
| `renderList(container, items, tmpl, keyFn, fillFn, tag)` | helpers.js | Keyed list rendering with DOM reuse |
| `reactiveState(initial, onChange)` | reactive.js | Shallow Proxy for flat state |
| `deepReactive(obj, onChange)` | reactive.js | Deep Proxy for nested objects/arrays |
| `createBatcher(renderFn, afterRender)` | reactive.js | queueMicrotask render coalescing |

---

## 14. Declarative DOM Binding — `fill(root, data)`

Replaces querySelector + textContent chains. Uses data attributes for binding.

### Data Attributes

| Attribute | Effect | Example |
|-----------|--------|---------|
| `data-ln-field="prop"` | `el.textContent = data[prop]` | `<p data-ln-field="name"></p>` |
| `data-ln-attr="attr:prop, ..."` | `el.setAttribute(attr, data[prop])` | `<img data-ln-attr="src:avatar, alt:name">` |
| `data-ln-show="prop"` | `el.classList.toggle('hidden', !data[prop])` | `<span data-ln-show="isAdmin">Admin</span>` |
| `data-ln-class="cls:prop, ..."` | `el.classList.toggle(cls, !!data[prop])` | `<li data-ln-class="active:isSelected">` |

### Usage

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
// Instead of 8 querySelector lines:
fill(el, {
	name: user.name,
	email: user.email,
	avatar: user.avatar,
	isAdmin: user.role === 'admin',
	isSelected: user.id === selectedId
});
```

### Rules

- `fill` is **idempotent** — call again with new data, DOM updates
- `null`/`undefined` values are skipped (existing content preserved)
- `data-ln-field` is for **data binding** — CSS classes are for **styling**
- Works on live DOM and on `<template>` clones (DocumentFragment)

---

## 15. Keyed List Rendering — `renderList()`

Efficiently renders an array into a container using keyed DOM reuse.

```javascript
renderList(
	this.dom.querySelector('[data-ln-list="users"]'),  // container
	this.state.users,                                   // data array
	'user-item',                                        // template name
	function (u) { return u.id; },                      // key function
	function (el, user, idx) {                          // fill function
		fill(el, { name: user.name, email: user.email });
	},
	'ln-user-list'                                      // component tag (for warnings)
);
```

### How it works

1. Index existing children by `data-ln-key` attribute
2. For each item: find existing node by key → call fillFn (reuse). Or clone template → set key → call fillFn (new).
3. Atomic DOM replacement: `container.textContent = ''; container.appendChild(fragment)`

### Rules

- `keyFn` must return a **stable unique identifier** (database ID, not array index)
- Existing DOM nodes are reused — event listeners, focus state, CSS transitions survive
- Container element uses `data-ln-list="name"` as convention
- Template uses standard `data-ln-template="name"` pattern
- Atomic update = one reflow, not item-by-item manipulation

---

## 16. Reactive State — Proxy

### Two-Layer State Model

Components use two state mechanisms that serve different purposes:

| Layer | Mechanism | Purpose | Example |
|-------|-----------|---------|---------|
| External | Attributes | Coordinator → component control | `data-ln-profile-mode="edit"` |
| Internal | Proxy | Automatic DOM rendering on change | `this.state.users.push(item)` |

Attributes are visible in DOM Inspector, externally controllable.
Proxy handles complex data (arrays, objects) and auto-triggers render.

### When to use which Proxy

| State type | Primitive | Example |
|-----------|-----------|---------|
| Flat (strings, numbers, booleans) | `reactiveState` | mode, selectedId, isLoading |
| Nested (arrays, objects) | `deepReactive` | users[], tracks[], form data |
| No state (service) | Neither | ln-http (global service pattern) |

### Shallow Proxy — `reactiveState`

```javascript
const self = this;
const queueRender = createBatcher(
	function () { self._render(); },
	function () { dispatch(self.dom, 'ln-toggle:changed', {}); }
);

this.state = reactiveState({
	mode: 'view',
	isOpen: false
}, function (prop, value, old) {
	queueRender();
});

// Later — just set, render fires automatically:
this.state.mode = 'edit';
```

### Deep Proxy — `deepReactive`

```javascript
this.state = deepReactive({
	users: [],
	selectedId: null,
	filter: ''
}, queueRender);

// All of these trigger queueRender automatically:
this.state.users.push({ id: 1, name: 'New' });
this.state.users[0].name = 'Updated';
this.state.users.splice(1, 1);
this.state.selectedId = 3;
```

### Batching — `createBatcher`

**Always** use `createBatcher` between Proxy and `_render`. Never wire `onChange` directly to `_render()`.

```javascript
const queueRender = createBatcher(renderFn, afterRenderFn);
```

Multiple sync state changes → one render:

```
state.name = 'A'     → queueRender() [queued via queueMicrotask]
state.email = 'B'    → queueRender() [already queued, skip]
state.role = 'admin' → queueRender() [already queued, skip]
--- microtask checkpoint ---
_render() fires ONCE with final state
afterRender() fires ONCE
```

---

## 17. Attribute ↔ Proxy Bridge

External state control (coordinator → component) uses attributes.
Internal state uses Proxy. The `_onAttr` method bridges them.

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

The MutationObserver calls `_onAttr` on attribute changes (see section 6).

Coordinator controls component via attributes (same pattern as ln-accordion → ln-toggle):

```javascript
// Coordinator sets attribute
profileEl.setAttribute('data-ln-profile-mode', 'edit');
// → MutationObserver → _onAttr → this.state.mode = 'edit' → _render()
```

For components with state attributes, add them to `attributeFilter`:

```javascript
attributeFilter: [DOM_SELECTOR, DOM_SELECTOR + '-mode', DOM_SELECTOR + '-for']
```

---

## 18. Updated Component Structure

```javascript
import { cloneTemplate, dispatch, dispatchCancelable, fill, renderList } from '../ln-core';
import { deepReactive, createBatcher } from '../ln-core';

(function () {
	const DOM_SELECTOR = 'data-ln-{name}';
	const DOM_ATTRIBUTE = 'ln{Name}';
	if (window[DOM_ATTRIBUTE] !== undefined) return;

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

	_component.prototype._bindEvents = function () {
		const self = this;
		this.dom.addEventListener('ln-{name}:request-{action}', function (e) {
			// Just change state — render is automatic
			self.state.prop = e.detail.value;
		});
	};

	_component.prototype._render = function () {
		fill(this.dom, { /* scalar bindings */ });
		renderList(container, this.state.items, 'tmpl',
			function (i) { return i.id; },
			function (el, item) { fill(el, { /* item data */ }); },
			'ln-{name}'
		);
	};

	_component.prototype._onAttr = function (attrName, newValue) {
		const prefix = DOM_SELECTOR + '-';
		if (attrName.indexOf(prefix) === 0) {
			const prop = attrName.slice(prefix.length);
			if (this.state[prop] !== newValue) {
				this.state[prop] = newValue;
			}
		}
	};

	// Public API (queries only)
	Object.defineProperty(_component.prototype, 'selectedId', {
		get: function () { return this.state.selectedId; }
	});

	_component.prototype.destroy = function () {
		dispatch(this.dom, 'ln-{name}:destroyed', {});
		delete this.dom[DOM_ATTRIBUTE];
	};

	// Standard boilerplate
	function constructor(domRoot) {
		_findElements(domRoot);
	}

	function _findElements(root) {
		const items = root.querySelectorAll('[' + DOM_SELECTOR + ']');
		for (const el of items) {
			if (!el[DOM_ATTRIBUTE]) {
				el[DOM_ATTRIBUTE] = new _component(el);
			}
		}
		if (root.hasAttribute && root.hasAttribute(DOM_SELECTOR) && !root[DOM_ATTRIBUTE]) {
			root[DOM_ATTRIBUTE] = new _component(root);
		}
	}

	function _domObserver() {
		const observer = new MutationObserver(function (mutations) {
			for (const mutation of mutations) {
				if (mutation.type === 'childList') {
					for (const node of mutation.addedNodes) {
						if (node.nodeType === 1) _findElements(node);
					}
				} else if (mutation.type === 'attributes') {
					const el = mutation.target;
					if (el[DOM_ATTRIBUTE] && el[DOM_ATTRIBUTE]._onAttr) {
						el[DOM_ATTRIBUTE]._onAttr(
							mutation.attributeName,
							el.getAttribute(mutation.attributeName)
						);
					} else {
						_findElements(el);
					}
				}
			}
		});
		observer.observe(document.body, {
			childList: true,
			subtree: true,
			attributes: true,
			attributeFilter: [DOM_SELECTOR]
		});
	}

	window[DOM_ATTRIBUTE] = constructor;
	_domObserver();
	if (document.readyState === 'loading') {
		document.addEventListener('DOMContentLoaded', function () { constructor(document.body); });
	} else {
		constructor(document.body);
	}
})();
```

---

## 19. Anti-Patterns — NEVER Do These

- Spaces for indentation — always use tabs
- `var` declarations — use `const` (default) or `let` (when reassigning)
- `createElement` chains — use `<template>` + `cloneNode`
- Direct component-to-component calls — use CustomEvents
- Coordinator calling component methods for mutations — use request events
- Missing double-load guard (`if (window[DOM_ATTRIBUTE] !== undefined) return`)
- Missing MutationObserver for auto-init
- Missing trigger re-init guard (`btn[DOM_ATTRIBUTE + 'Trigger']`)
- Forgetting `if (e.ctrlKey || e.metaKey || e.button === 1) return` before `preventDefault`
- Inline styles via JS (`el.style.display = 'none'`) — use `.hidden` class toggle or CSS-driven state
- Components doing UI wiring (opening modals, showing toasts) — that's the coordinator's job
- `alert()`, `confirm()`, `prompt()` — never use for any purpose
- Throwing exceptions in event handlers — catch and `console.warn` instead
- Silent failures — always `console.warn` with `[ln-{component}]` prefix
- Manual `_render()` calls after state change — use Proxy + `createBatcher`
- Wiring Proxy `onChange` directly to `_render()` without batcher — use `createBatcher`
- querySelector chains for data display — use `fill()` with `data-ln-field`
- `innerHTML = ''` + rebuild loop for lists — use `renderList()` with key function
- CSS classes for data binding (`.user-name`) — use `data-ln-field="name"`
- Copy-pasting `_cloneTemplate`, `_dispatch` into IIFE — import from `ln-core`
- Array index as key in `renderList` — use stable ID (`item.id`)
- `data-ln-field` on elements that need HTML content — `fill` uses `textContent` only