# ln-ashlar — ln-core API Reference

> Shared helpers imported by all ln-ashlar components. Located in `js/ln-core/`.
> Source of truth: `js/ln-core/index.js` (barrel), `helpers.js`, `reactive.js`, `persist.js`,
> `positioning.js`, `crypto.js`.
> For architecture principles → global js skill §9 (three layers), §12 (reactive state).

---

## Import Pattern

Imports go **outside** the IIFE — Vite resolves at build time:

```javascript
// helpers.js — DOM, events, templates, list rendering, forms, discovery
import {
	registerComponent,
	cloneTemplate, cloneTemplateScoped, fillTemplate,
	dispatch, dispatchCancelable, requestData,
	fill, lnFill, renderList, buildDict,
	guardBody, findElements, isVisible,
	serializeForm, populateForm, getLocale, readValue,
	shouldInterceptLink, buildUrl,
	registerDataMapper, getDataMapper, parseHeaders, getHeaders,
	interceptValueProperty
} from '../ln-core';

// reactive.js — state proxies and batching
import { reactiveState, deepReactive, createBatcher } from '../ln-core';

// persist.js — localStorage helpers
import { persistGet, persistSet, persistRemove, persistClear } from '../ln-core';

// positioning.js — floating UI helpers
import { computePlacement, teleportToBody, measureHidden } from '../ln-core';

// crypto.js — Web Crypto helpers (niche — encryption at rest)
import { setCryptoKey, getCryptoKey, encryptData, decryptData } from '../ln-core';
```

---

## Component Registration (helpers.js)

### `registerComponent(selector, attribute, ComponentFn, componentTag, options)`

End-to-end component registration. **The universal init mechanism** — used by every library
component. Replaces hand-rolled `findElements + MutationObserver + guardBody + DOMContentLoaded +
window[attribute] =` with one call.

```javascript
import { registerComponent } from '../ln-core';

function _component(dom) { this.dom = dom; /* ... */ return this; }
_component.prototype.destroy = function () { delete this.dom[DOM_ATTRIBUTE]; };

registerComponent('data-ln-example', 'lnExample', _component, 'ln-example', {
	extraAttributes: ['data-ln-example-state'],
	onAttributeChange: function (el, attrName) {
		el[DOM_ATTRIBUTE]._onAttr(attrName, el.getAttribute(attrName));
	},
	onInit: function (root) { /* runs after findElements per added subtree */ }
});
```

- `selector` — attribute name (`'data-ln-foo'`) OR a full CSS selector if it contains `[`, `.`,
  or `#` (e.g. `'[data-ln-foo]:not([disabled])'`). Used to build `attributeFilter` and the
  `querySelectorAll` query.
- `attribute` — JS-side key used for both `window[attribute]` (constructor) and `el[attribute]`
  (per-element instance).
- `ComponentFn` — constructor called via `new ComponentFn(el)`.
- `options.extraAttributes` — additional attribute names for the MutationObserver `attributeFilter`.
- `options.onAttributeChange(el, attrName)` — called when a filtered attribute changes on an
  already-initialized element. The attribute → state bridge hook.
- `options.onInit(root)` — called after `findElements` per subtree (initial DOM, added childList
  nodes, attribute-mutated subtrees).
- Internalized: `guardBody`, `findElements`, `window[attribute] = constructor`,
  `DOMContentLoaded` boot, auto-`destroy()` on node removal.
- Returns the constructor function (also stored at `window[attribute]`).

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
if (event.defaultPrevented) return;
```

### `requestData(component, eventName, keyName)`

Shared data-request cycle for `ln-table` / `ln-list`. Re-filters, re-renders the hydrated rows,
then dispatches `*:request-data` for the coordinator. Payload: `{ sort, filters, search, [keyName]: name }`.

```javascript
requestData(this, 'ln-list:request-data', 'list');    // ln-list
requestData(this, 'ln-table:request-data', 'table');  // ln-table
```

Instance contract: `component` must expose `_applyFilterAndSort`, `_render`, `_updateFooter`,
`_vStart`, `_vEnd`, `dom`, `name`, `currentSort`, `currentFilters`, `currentSearch`.

---

## Template Helpers (helpers.js)

### `cloneTemplate(name, tag)`

Clone a `<template data-ln-template="{name}">`. Caches on first use. Returns `DocumentFragment` or `null`.

```javascript
const fragment = cloneTemplate('track-item', 'ln-playlist');
if (!fragment) return;
```

### `cloneTemplateScoped(root, name, tag)`

Like `cloneTemplate`, but searches inside `root` first; falls back to global lookup.
Use when a component supports locally-scoped templates overrideable per-instance.

```javascript
const frag = cloneTemplateScoped(this.dom, 'column-filter', 'ln-table');
```

### `findElements(root, selector, attribute, ComponentClass)`

Find all `[selector]` inside `root` (including root itself) and instantiate `ComponentClass` on
each without an existing instance. Sets `el[attribute] = new ComponentClass(el)`.

### `guardBody(setupFn, componentTag)`

Defer execution until `<body>` exists. If `document.body` is `null`, defers to `DOMContentLoaded`.
Used internally by `registerComponent` — rare to call directly.

### `readValue(el)`

Read the raw machine value behind a formatted cell/item: `data-ln-value` attribute if present,
else `el.textContent.trim()`. The single read path for value-based sort/filter across components.

```javascript
const raw = readValue(td); // '1250.50' (from data-ln-value) or trimmed text
```

When emitting a cell whose displayed text is locale-formatted and participates in sort/filter:
put the raw value (`1250.50`, Unix timestamp) in `data-ln-value`; put the sort type in the
component-scoped behavior attribute (`data-ln-table-sort="number"` on `<th>`). Never sort
formatted text.

### `isVisible(el)`

Boolean — `true` if element has non-zero layout box (`offsetWidth`, `offsetHeight`, or
`getClientRects().length`). Cheap layout-time check; does not compute styles.

```javascript
if (!isVisible(panel)) return;
```

### `buildDict(root, selector)`

Read all `[selector]` elements once at init, extract `key → textContent`, remove from DOM, return
plain object. Used for component-level i18n strings authored by Blade.

```html
<ul hidden>
	<li data-ln-toast-dict="close">Close</li>
</ul>
```

```javascript
const dict = buildDict(dom, 'data-ln-toast-dict');
dict['close'] // 'Close'
```

Convention: `data-{component}-dict="key"` on `<li>` inside `<ul hidden>`. Missing keys return
`undefined` — use `dict['key'] || 'fallback'` in dev; Blade always provides the dict in
production.

### `getLocale(el)`

Resolve the active locale for an element. Walks ancestors for `[lang]`, falls back to
`navigator.language`. Used by date / number / collator-driven components.

```javascript
const locale = getLocale(this.dom); // 'mk', 'en-US', ...
```

---

## Declarative DOM Binding (helpers.js)

### `fill(root, data)`

Replaces `querySelector + textContent` chains. Idempotent — call again with new data to update.
**Nothing calls `fill()` automatically** — your component calls it (and re-calls it on each
render). Renderer pipelines you don't own (`ln-table` rows, `renderList` clone pass) never call
`fill()`.

#### Data Attributes

| Attribute | Effect | Example |
|-----------|--------|---------|
| `data-ln-field="prop"` | `el.textContent = data[prop]` | `<p data-ln-field="name"></p>` |
| `data-ln-attr="attr:prop, ..."` | `el.setAttribute(attr, data[prop])` | `<img data-ln-attr="src:avatar, alt:name">` |
| `data-ln-show="prop"` | `el.classList.toggle('hidden', !data[prop])` | `<span data-ln-show="isAdmin">Admin</span>` |
| `data-ln-class="cls:prop, ..."` | `el.classList.toggle(cls, !!data[prop])` | `<li data-ln-class="active:isSelected">` |

```javascript
fill(el, { name: user.name, email: user.email, isAdmin: user.role === 'admin' });
```

- `null`/`undefined` values are skipped (existing content preserved).
- `data-ln-field` in an `ln-table` row template is silently inert — the row pipeline uses
  `fillTemplate()` + `{{ field }}`, never `fill()`.

---

### `lnFill(container, record)`

Coordinator-facing fan-out fill, exposed at `window.lnCore.lnFill`. Dispatches `ln-fill` at every
`[data-ln-form]` and `[data-ln-fillable]` descendant (and at `container` itself when it matches).
`ln-form` fills its fields; `[data-ln-fillable]` regions fill `[data-ln-field]` elements.
`record = null` → reset/clear.

```javascript
window.lnCore.lnFill(modalEl, record);  // fill form + display regions
window.lnCore.lnFill(modalEl, null);    // reset / clear
```

- Call directly only for **programmatic** fills (store conflict, deep-link, import-after-fetch).
- For **click-triggered** fills, use the declarative `ln-fill` module instead (see below).

---

## Declarative Fill Module — `ln-fill`

`ln-fill` wraps `lnFill()` in a document-level delegated click listener so fills can be driven
entirely from HTML attributes — no coordinator JS needed for the common case.

```html
<!-- Trigger: data-ln-fill-form points to the form id.
     data-ln-fill-<key> attributes become the record. -->
<button
	data-ln-modal-for="event-modal"
	data-ln-fill-form="event-form"
	data-ln-fill-event-id="42"
	data-ln-fill-title="Annual Conference"
>Edit</button>

<!-- Target form -->
<form id="event-form" data-ln-form>
	<input name="eventId" type="hidden">
	<input name="title">
</form>
```

On click: reads `data-ln-fill-form` → locates the form; builds record from all `data-ln-fill-*`
keys (kebab-case auto-camelCased by browser dataset: `data-ln-fill-event-id` → `{ eventId: "42" }`);
calls `window.lnCore.lnFill(form, record)`. No payload attributes → `lnFill(form, null)` → reset.

**Reserved suffixes** (never put in the record):
- `form` — the target form id
- `store` — reserved for a future store-source seam

**Composing with `data-ln-modal-for`.** `ln-fill` does NOT call `e.preventDefault()`. A button
may carry both `data-ln-fill-form` and `data-ln-modal-for` — both document listeners fire on the
same click independently.

**In table row templates.** `fillTemplate()` interpolates `{{ key }}` in element attributes, so
per-row data stamps cleanly into `data-ln-fill-*` at clone time:

```html
<template data-ln-template="events-row">
	<tr data-ln-table-row>
		<td>{{ title }}</td>
		<td>
			<button
				data-ln-modal-for="event-modal"
				data-ln-fill-form="event-form"
				data-ln-fill-event-id="{{ id }}"
				data-ln-fill-title="{{ title }}"
				aria-label="Edit"
			>...</button>
		</td>
	</tr>
</template>
```

**`data-ln-fill-as` — decoupled fill key.** When the form field's `name` attribute is the backend
column name (e.g. `max_users`) but the record key is camelCase (`maxUsers`), add
`data-ln-fill-as="maxUsers"` to the input. `populateForm` reads `data-ln-fill-as` first, falling
back to `name`. This decouples the fill key from the wire name.

| Trigger | Use |
|---------|-----|
| User clicks a button or table row action | `data-ln-fill-form` + `data-ln-fill-*` (declarative) |
| Programmatic / store-event-driven | `window.lnCore.lnFill(container, record)` in coordinator |

Source: `js/ln-fill/src/ln-fill.js`, `js/ln-fill/README.md`.

---

## Template Text Stamping (helpers.js)

### `fillTemplate(clone, data)`

One-shot `{{ field }}` substitution on a fresh template clone — in **both text nodes and element
attribute values**. Placeholders are consumed; the element never re-updates from data. Runs
automatically inside `renderList`'s clone pass and `ln-table` row rendering.

```html
<template data-ln-template="filter-item">
	<label><input type="checkbox" data-ln-fill-id="{{ id }}"> {{ text }}</label>
</template>
```

- Missing keys → empty string in both passes.
- `fillTemplate()` ignores `data-ln-field`; `fill()` ignores `{{ }}`. They are separate systems.

#### Decision rule — `{{ }}` vs `data-ln-field`

- Renderer fills it once at clone time (`ln-table` rows, `renderList` clone pass) → `{{ field }}`.
- Your code calls `fill()` on it (initial + every update) → `data-ln-field` / `data-ln-attr`.

`data-ln-field` in an `ln-table` row template is silently inert — the row pipeline never calls
`fill()`.

---

## Keyed List Rendering (helpers.js)

### `renderList(container, items, templateName, keyFn, fillFn, tag)`

Efficiently renders an array with DOM reuse via `data-ln-key`.

```javascript
renderList(
	this.dom.querySelector('[data-ln-list]'),
	this.state.users,
	'user-item',
	function (u) { return u.id; },
	function (el, user, idx) { fill(el, { name: user.name }); },
	'ln-user-list'
);
```

- `keyFn` returns a stable unique identifier (database id, not array index).
- Existing DOM nodes with matching `data-ln-key` are reused — event listeners and focus survive.
- Atomic DOM replacement: one reflow per render.
- Calls `fillTemplate(clone, item)` automatically for newly-cloned elements.

---

## Form Helpers (helpers.js)

### `serializeForm(form, opts?)`

Walk `form.elements`, return a plain object keyed by `name`.

```javascript
const data = serializeForm(this.dom);
// { username: 'alice', roles: ['admin', 'editor'] }

const typed = serializeForm(this.dom, { typed: true });
// { active: true, count: 5 }  — number inputs coerced; single checkbox → boolean
```

- Skips disabled fields, file inputs, submit/button inputs, unnamed elements.
- Checkboxes collect as `string[]`; radios as single string; `<select multiple>` as `string[]`.
- `opts.typed = true` — coerces `type="number"` to `Number` (or `null`), single checkboxes to
  `boolean`. `type="hidden"` is never coerced.

### `populateForm(form, data)`

Inverse of `serializeForm`. Walks `form.elements`, assigns from `data` keyed by `name` (or
`data-ln-fill-as` if set on the element).

```javascript
const populated = populateForm(this.dom, { username: 'alice', roles: ['admin'] });
populated.forEach(function (el) { dispatch(el, 'input'); });
```

- Checkbox + array → `checked` if `el.value` in array.
- Checkbox group (same `name`, 2+ elements) + scalar → comma-separated membership check.
- Single checkbox + scalar → boolean coercion (`"false"/"0"/"off"/"no"/""` → unchecked).
- Radio → `checked` if value matches.
- `<select multiple>` + array → marks matching options.
- `data-ln-fill-as` on an input overrides `name` as the record-lookup key (fill key ≠ submit key).

---

## Reactive State (reactive.js)

### `reactiveState(initial, onChange)`

Shallow Proxy for flat state (strings, numbers, booleans). Fires `onChange(prop, value, old)`.

```javascript
this.state = reactiveState({ mode: 'view', isOpen: false }, function (prop, value, old) {
	queueRender();
});
this.state.mode = 'edit'; // triggers onChange
```

### `deepReactive(obj, onChange)`

Deep Proxy for nested objects and arrays. Fires `onChange()` (no args) on any nested mutation.

```javascript
this.state = deepReactive({ users: [], selectedId: null }, queueRender);
this.state.users.push({ id: 1, name: 'New' }); // triggers queueRender
```

### `createBatcher(renderFn, afterRenderFn?)`

Microtask coalescing — multiple sync state changes → one `renderFn` call.

```javascript
const queueRender = createBatcher(
	function () { self._render(); },
	function () { dispatch(self.dom, 'ln-{name}:changed', {}); }
);
```

**Always** use `createBatcher` between Proxy and `_render`. Never wire `onChange` directly to
`_render` — you get one render per assignment and the DOM thrashes.

```
state.name = 'A'     → queueRender() [queued via queueMicrotask]
state.email = 'B'    → queueRender() [already queued, skip]
--- microtask checkpoint ---
_render() fires ONCE
afterRender() fires ONCE
```

---

## Attribute ↔ Proxy Bridge

External coordinator control (setAttribute → component state).

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

Wire via `registerComponent`'s `onAttributeChange` hook and `extraAttributes`:

```javascript
registerComponent(DOM_SELECTOR, DOM_ATTRIBUTE, _component, 'ln-{name}', {
	extraAttributes: ['data-ln-{name}-mode'],
	onAttributeChange: function (el, attrName) {
		el[DOM_ATTRIBUTE]._onAttr(attrName, el.getAttribute(attrName));
	}
});
```

---

## Persist Helpers (persist.js)

localStorage state persistence scoped to component + page + element key.

```javascript
persistGet(component, el)              // → JSON value | null
persistSet(component, el, value)       // stores JSON.stringify(value)
persistRemove(component, el)           // removes single key
persistClear(component)                // removes ALL keys for this component name
```

- `component` — string name, e.g. `'tabs'`, `'filter'`, `'table-sort'`
- `el` — root element with `id` or `data-ln-persist`
- Storage key format: `ln:<component>:<page-path>:<id>`
- Persistence is always opt-in: add `data-ln-persist` (or `data-ln-persist="custom-key"`) to the
  element. Components only call these helpers when the attribute is present.
- All functions catch exceptions silently — safe in private browsing and when localStorage is full.

---

## Positioning Helpers (positioning.js)

Pure helpers for floating UI (popovers, tooltips, dropdowns).

### `computePlacement(anchorRect, floatingSize, preferred, offset)`

Compute viewport coordinates for a floating element. Pure function — no DOM side effects.

```javascript
const { top, left, placement } = computePlacement(
	anchor.getBoundingClientRect(),
	measureHidden(panel),
	'bottom-end',  // preferred: 'top'|'bottom'|'left'|'right' with optional '-start'/'-end'
	8              // offset in px (default: 4)
);
panel.style.top  = top  + 'px';
panel.style.left = left + 'px';
panel.setAttribute('data-ln-placement', placement);
```

- `preferred` accepts `-start`/`-end` alignment suffixes (floating-ui style):
  `'bottom-start'`, `'bottom-end'`, `'top-start'`, `'top-end'`, etc.
- Returns `{ top, left, placement }`. `placement` is the winning side (flip may change it).
- Fallback chain: preferred → opposite → perpendicular pair → clamps to viewport edge.

### `teleportToBody(el)`

Move an element to `<body>` for stacking-context escape. Returns a restore function.

```javascript
const restore = teleportToBody(panel);
// ... later (on component close/destroy)
restore();
```

- Does NOT set inline styles — the component's SCSS (`position: fixed`) is responsible.

### `measureHidden(el)`

Read `offsetWidth`/`offsetHeight` of a `display: none` element without visible flicker.

```javascript
const { width, height } = measureHidden(panel);
```

---

## Transport Helpers (helpers.js)

Niche — used by `ln-router` and SPA link interception.

- `shouldInterceptLink(event, anchor)` — takes a click `MouseEvent` and an `HTMLAnchorElement`;
  returns `true` if the SPA router should handle the link (left-click, same-origin, no modifier
  keys, not `target="_blank"`, not a hash-only or mailto/tel href).
- `buildUrl(...segments)` — joins path segments with `/`, deduping slashes. No query-params
  support; for query strings, append them to the last segment manually.
- `registerDataMapper(name, fn)` / `getDataMapper(name)` — register/retrieve a named transform
  function for data pipeline components.
- `parseHeaders(headersObj)` / `getHeaders()` — read and merge default request headers
  (used by SPA fetch layer).
- `interceptValueProperty(dom, descriptor, { get, set })` — wraps an existing property descriptor
  (e.g. `HTMLInputElement.prototype.value`) on `dom`, intercepting get/set via the callbacks
  object. Used by `ln-number` to maintain raw/formatted dual values.

---

## Crypto Helpers (crypto.js)

Web Crypto AES-GCM 256-bit envelope encryption. Used by the data store for encryption at rest.

```javascript
await setCryptoKey('passphrase-or-session-token');  // derive + activate key
await encryptData({ text: 'Sensitive' });           // → { encrypted: true, iv, data }
await decryptData(encryptedObj);                    // → original value
getCryptoKey();                                     // → CryptoKey | null
```

- `setCryptoKey(null)` deactivates encryption.
- `encryptData` / `decryptData` fall back to plain data when no key is active.
- `decryptData` returns `{ ...obj, decryptionError: true }` on failure (wrong key).
