# ln-ashlar — Modal Implementation

> HOW to build modals with ln-ashlar. For WHAT a modal must have → global ui/components/modal.md.

## Component

- Attribute: `data-ln-modal` on modal element (value = state: "open"/"close")
- Trigger: `data-ln-modal-for="id"` on trigger button
- Close: `data-ln-modal-close` on close/cancel buttons
- API: read state via `el.lnModal.isOpen`; teardown via `el.lnModal.destroy()`.
- State change: `el.setAttribute('data-ln-modal', 'open'|'close')` — the only write path.
- ESC listener active only while modal is open

## HTML Pattern

```html
<button data-ln-modal-for="my-modal">Open</button>

<div class="ln-modal" data-ln-modal id="my-modal">
    <form>
        <header>
            <h3>Title</h3>
            <button type="button" aria-label="Close" data-ln-modal-close>
                <svg class="ln-icon" aria-hidden="true"><use href="#ln-x"></use></svg>
            </button>
        </header>
        <main>...</main>
        <footer>
            <button type="button" data-ln-modal-close>Cancel</button>
            <button type="submit">Save</button>
        </footer>
    </form>
</div>
```

## SCSS Sizes

```scss
#my-modal > form { @include modal-lg; }
```

| Mixin | Width |
|-------|-------|
| `modal-sm` | 28rem |
| `modal-md` | 32rem |
| `modal-lg` | 42rem |
| `modal-xl` | 48rem |

## Events

| Event | When |
|-------|------|
| `ln-modal:before-open` | Before opening (cancelable) |
| `ln-modal:open` | After opened |
| `ln-modal:before-close` | Before closing (cancelable) |
| `ln-modal:close` | After closed |
| `ln-modal:destroyed` | After `destroy()` is called; `{ modalId, target }` |

## Display Fill (`data-ln-modal-*`)

A `data-ln-modal-for` trigger can also fill the modal's `[data-ln-field]` display and set its mode — no coordinator:

```html
<button data-ln-modal-for="user-modal" data-ln-modal-name="Ana">Edit</button>

<div class="ln-modal" data-ln-modal data-ln-modal-mode="new" id="user-modal">
	<form data-ln-form>
		<header>
			<h3>
				<span data-ln-modal-when="new">New user</span>
				<span data-ln-modal-when="edit">Edit — <span data-ln-field="name"></span></span>
			</h3>
		</header>
	</form>
</div>
```

- `data-ln-modal-<key>` on the trigger → fills modal `[data-ln-field]` (keys camelCased: `data-ln-modal-user-name` → `userName`).
- `data-ln-modal-mode` is set automatically: `edit` if any `data-ln-modal-*` payload, `new` if none; an explicit `data-ln-modal-mode` on the trigger wins. `[data-ln-modal-when]` spans toggle on it (co-located SCSS).
- This is the modal **display** namespace; the **form** fill is the separate `data-ln-fill-*` namespace → `patterns/edit-modal-prefill.md`, `js/ln-fill/README.md`.

## Rules
- `<form>` is the content root — select via `.ln-modal > form`
- Cancel needs `type="button"` to prevent form submission
- No `.ln-modal__content` class — semantic selectors only
- Sizes via SCSS mixins on `#id > form`, not CSS classes
