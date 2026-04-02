# Modal

> Overlay dialog for focused tasks — confirmations, quick forms, content preview.

---

## Core Principle

A modal interrupts the user's flow to get a decision or short input. If the task is complex enough to need tabs, sections, or conditional logic — it's not a modal, it's a page. Every modal has `<form>` as its content root.

---

## Anatomy

```
┌─ backdrop ──────────────────────────────────────────────────────┐
│                                                                 │
│   ┌─ .ln-modal ─────────────────────────────────────────────┐   │
│   │ <form>                                                  │   │
│   │ ┌─ header ────────────────────────────────────────────┐ │   │
│   │ │ <h3>Title</h3>                              [✕]     │ │   │
│   │ └────────────────────────────────────────────────────┘ │   │
│   │ ┌─ main (scrollable) ────────────────────────────────┐ │   │
│   │ │                                                    │ │   │
│   │ │  Form fields / content                             │ │   │
│   │ │                                                    │ │   │
│   │ └────────────────────────────────────────────────────┘ │   │
│   │ ┌─ footer ────────────────────────────────────────────┐ │   │
│   │ │                     [Cancel]  [Submit]               │ │   │
│   │ └────────────────────────────────────────────────────┘ │   │
│   └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

- **header** — title + close button. Always present.
- **main** — scrollable content area. Scrolls when content exceeds max-height.
- **footer** — action buttons. Always visible (sticky within modal).
- **`<form>`** is always the content root — no wrapper `<div>`, no BEM classes. Styled via `.ln-modal > form`.

---

## Sizes

Applied via SCSS mixins on `#modal-id > form`:

| Size | Width | Use case |
|---|---|---|
| `modal-sm` | 28rem | Confirm/alert — text + 2 buttons |
| `modal-md` | 32rem | Quick form — 3-5 fields |
| `modal-lg` | 42rem | Larger form, content preview |
| `modal-xl` | 48rem | Data comparison, bulk edit |

Max-height: viewport minus padding. Content scrolls inside `<main>`, header and footer remain visible.

---

## When to Use Modal vs Page

| Modal | Page |
|---|---|
| Flat form (any number of simple fields) | Conditional logic (show/hide fields) |
| Single entity CRUD | Tabs or sections |
| Confirmation / alert | Multi-entity with complex relations |
| Quick preview | File upload with preview/crop |
| | Drag-and-drop, nested structures |

Same rules as form.md — the boundary is interaction complexity, not field count.

---

## Behavior

### Opening

- Trigger: `data-ln-modal-for="modal-id"` on button
- State: `data-ln-modal="open"` on modal element — single source of truth
- To open programmatically: `el.setAttribute('data-ln-modal', 'open')`
- Focus trap: focus stays inside modal while open
- Body scroll lock: background does not scroll

### Closing

- Close button: `data-ln-modal-close` (needs `type="button"`)
- Cancel button: `data-ln-modal-close` (needs `type="button"`)
- ESC key
- To close programmatically: `el.setAttribute('data-ln-modal', 'close')`
- **Backdrop click does NOT close** — user may accidentally click outside while working in a form

### Nested Modals

**Never.** If you need a modal inside a modal, the architecture is wrong. Rethink the flow.

---

## Confirmation Pattern

A confirmation is a modal with `modal-sm`, no input fields, just a question and two buttons:

```html
<div class="ln-modal" data-ln-modal id="confirm-delete">
    <form>
        <header><h3>Delete 15 employees?</h3><button type="button" class="ln-icon-close" data-ln-modal-close></button></header>
        <main>
            <p>This will also remove their attendance records and payroll history.</p>
        </main>
        <footer>
            <button type="button" data-ln-modal-close>Cancel</button>
            <button type="submit">Delete 15 Employees</button>
        </footer>
    </form>
</div>
```

- Title = the action as a question
- Body = consequences (cascade, permanence)
- Confirm button = describes the action (NOT "OK" or "Yes")
- Destructive confirm = danger color (`--color-primary: var(--color-error)`)

---

## HTML Structure

```html
<button data-ln-modal-for="create-user">Create User</button>

<div class="ln-modal" data-ln-modal id="create-user">
    <form data-ln-form>
        <header>
            <h3>Create User</h3>
            <button type="button" class="ln-icon-close" data-ln-modal-close></button>
        </header>
        <main>
            <!-- form fields -->
        </main>
        <footer>
            <button type="button" data-ln-modal-close>Cancel</button>
            <button type="submit">Create</button>
        </footer>
    </form>
</div>
```

- `data-ln-modal` on modal = single source of truth for state ("open" / "close")
- `data-ln-modal-for="id"` on trigger = references modal by ID
- Non-submit buttons need `type="button"` to prevent form submission
- Footer buttons get `@include btn` automatically — no `.btn` class needed
- No `.ln-modal__content` class — select via `.ln-modal > form`

---

## Anti-Patterns

- **Nested modals** — never. Rethink the flow.
- **Modal for complex forms** — if it needs tabs/sections/conditional logic, it's a page
- **"OK" / "Yes" as confirm button** — describe the action: "Delete 15 Employees"
- **Modal without `<form>` root** — always form, even for confirmations
- **Wrapper div between modal and form** — `.ln-modal > form` is the structure
- **BEM classes for modal internals** — use semantic elements: `header`, `main`, `footer`
- **Backdrop click to close** — accidental clicks lose form data
- **`.open()` / `.close()` API methods** — single source of truth is the `data-ln-modal` attribute value
- **Slide panel as separate component** — it's a CSS variant of modal if needed
- **Auto-closing on submit** — coordinator decides when to close, not the modal
