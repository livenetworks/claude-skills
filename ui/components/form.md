# Form

> The primary component for data input — create, edit, and configure.

---

## Core Principle

A form is a conversation: the system asks questions (labels), the user answers (inputs), and the system gives instant feedback (validation). Every field validates on keyup from the first keystroke. Error space is always reserved — no layout shifts.

---

## Anatomy

```
┌─────────────────────────────────────────────────────────────────┐
│ <form data-ln-form>                                             │
│                                                                 │
│  ┌──────────────────────────┐ ┌──────────────────────────────┐  │
│  │ Name *                   │ │ Surname *                    │  │
│  │ ┌──────────────────────┐ │ │ ┌──────────────────────────┐ │  │
│  │ │ input                │ │ │ │ input                    │ │  │
│  │ └──────────────────────┘ │ │ └──────────────────────────┘ │  │
│  │ (reserved error space)   │ │ (reserved error space)       │  │
│  └──────────────────────────┘ └──────────────────────────────┘  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ Email *                                                  │   │
│  │ ┌──────────────────────────────────────────────────────┐ │   │
│  │ │ input                                                │ │   │
│  │ └──────────────────────────────────────────────────────┘ │   │
│  │ ⚠ Е-маил мора да биде во формат user@domain.tld         │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ • Cancel                                    • Save (dis) │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Modal vs Page — When to Use Which

The boundary is **interaction complexity**, not field count.

### Modal

- Flat form — text inputs, radio, checkbox, select, date pickers
- Single entity CRUD (create user, edit document title)
- No conditional logic (show/hide fields based on selection)
- No tabs or sections
- Even 20 fields is fine if they're all simple inputs

### Dedicated Page

- Conditional logic (selecting type reveals different field sets)
- Tabs or sections (personal info / permissions / settings)
- Multi-entity relationships with complex interaction
- File uploads with preview/crop
- Drag-and-drop ordering or nested structures

**When unsure — ask.** The wrong container wastes more time than a question.

---

## Layout — CSS Grid

Forms use CSS Grid via `@include form-grid` (6 columns → 1 column on mobile).

- Each field: `<div class="form-element">` wrapping `<label for>` + `<input id>`
- Explicit `for`/`id` association (NOT wrapping label)
- Grid spans in SCSS: `.form-element { grid-column: span 3; }` for half-width
- Full-width fields: `grid-column: span 6` (or `1 / -1`)
- Form actions: `<ul class="form-actions">` with `<li>` per button — spans full width

---

## Components — ln-validate + ln-form

Two ln-acme components, layered like ln-toggle / ln-accordion:

### ln-validate (primitive — per field)

Validates a single input, shows/hides error messages.

- Attribute: `data-ln-validate` on `<input>`
- Listens: keyup on the input
- Reads: native `input.validity` API (ValidityState)
- Shows/hides: matching `<li data-ln-validate-error="...">` elements
- Toggles: CSS state on input (valid/invalid visual)
- Emits: `ln-validate:valid` / `ln-validate:invalid`
- Works standalone (without ln-form)

### ln-form (coordinator — per form)

Manages the full form lifecycle: fill, validate, submit.

- Attribute: `data-ln-form` on `<form>`
- Listens: `ln-validate:valid` / `ln-validate:invalid` from child fields
- Tracks: whether all fields are valid → enables/disables submit button
- Fill: receives event with data object, populates inputs by `name` attribute
- Submit: `preventDefault`, emits `ln-form:submit` with serialized form data
- Reset: clears fields + resets validation state
- Auto-submit: `data-ln-form-auto` — submits on any input change (for search/filter forms)
- Debounce: `data-ln-form-debounce="300"` — waits N ms after last input change before auto-submit

### Auto-Submit (Search / Filter Forms)

For forms that submit automatically on input change — server-side search, filter panels:

```html
<form action="/search" method="get" data-ln-form-auto data-ln-form-debounce="300">
    <input name="q" type="search" placeholder="Search...">
</form>
```

```html
<form action="/users" method="get" data-ln-form-auto data-ln-form-debounce="300">
    <input name="q" placeholder="Search...">
    <select name="role">...</select>
    <select name="status">...</select>
</form>
```

- `data-ln-form-auto` — any input/select/checkbox change triggers submit
- `data-ln-form-debounce="300"` — waits 300ms after last change before submitting
- `ln-http` handles the AJAX request
- No submit button needed (but can have one as fallback)
- Auto-submit and validation are independent — auto-submit forms typically don't need validation

### Validation Rules — HTML is Source of Truth

Rules come from native HTML validation attributes. Zero JS configuration.

| HTML attribute | ValidityState property | `data-ln-validate-error` value |
|---|---|---|
| `required` | `valueMissing` | `required` |
| `type="email"` | `typeMismatch` | `typeMismatch` |
| `minlength` | `tooShort` | `tooShort` |
| `maxlength` | `tooLong` | `tooLong` |
| `pattern` | `patternMismatch` | `patternMismatch` |
| `min` / `max` | `rangeUnderflow` / `rangeOverflow` | `rangeUnderflow` / `rangeOverflow` |

### Error Messages — HTML, Not JS

```html
<div class="form-element">
  <label for="email">Email</label>
  <input id="email" name="email" type="email" required data-ln-validate>
  <ul data-ln-validate-errors>
    <li data-ln-validate-error="required">Полето е задолжително</li>
    <li data-ln-validate-error="typeMismatch">Невалиден е-маил формат</li>
  </ul>
</p>
```

Zero display text in JS. Error messages rendered by backend (multilanguage ready).

### Custom Validation

For rules that native HTML can't express (password match, async uniqueness check):
- Coordinator dispatches `ln-validate:set-custom` event on the input with `{ error: "errorName" }`
- ln-validate shows the matching `<li data-ln-validate-error="errorName">`
- Coordinator dispatches `ln-validate:clear-custom` when the error is resolved
- Custom validation is the coordinator's responsibility, not ln-validate's

---

## Before the Form

- **Pre-fill what you can** — defaults, user preferences, last used values
- **Show required fields** — user should know the scope of work upfront
- **Group related fields** — personal info, address, preferences as visual sections
- **Dependent fields** — selecting country reveals region/state fields
- **Progressive disclosure** — advanced options hidden behind "More options" toggle

## After the Form

- **Success = navigate away** — don't stay on the form showing "Success!"
- **Preserve input on error** — never clear the form when submission fails
- **Re-enable submit** — if the server fails, the user must be able to try again

---

## Validation Behavior

### Timing

- **Keyup from first keystroke** — instant feedback as user types
- **Errors appear immediately** when input becomes invalid
- **Errors clear immediately** when input becomes valid

### Error Display

- Reserved space (1 line height) below every input — always present
- When no error: space is empty but preserved (no layout shift)
- When error: error text appears in reserved space
- Input visual state changes (invalid indicator — exact styling TBD)
- When valid again: error text disappears, input returns to normal (green/check TBD)

### Untouched Fields

- Empty-on-load is NOT an error — required fields start clean
- Error state begins only after first interaction (first keyup)
- Exception: on submit attempt, ALL fields validate (including untouched required)

---

## Submit Flow

```
Submit button is DISABLED while any field is invalid
  ↓
All fields valid → button becomes ENABLED
  ↓
User clicks submit
  → ln-form: preventDefault
  → ln-form: emit ln-form:submit { data }
  → Coordinator handles HTTP request
  → Success: toast + navigate away (or close modal)
  → Server error (general): error toast
  → Server error (field-specific 422): map to fields via coordinator
```

Submit button shows loading state during server request (coordinator toggles).

---

## Fill — Edit Mode

When editing an existing record:

```
Coordinator receives edit trigger (e.g. row click in data-table)
  → Dispatches event to ln-form with record data
  → ln-form populates inputs by name attribute
  → { name: "Dalibor", email: "d@test.com" } → input[name="name"].value = "Dalibor"
```

Data comes from `<tr>` data attributes, from ln-store, or from any source — ln-form doesn't know or care about the origin.

---

## Autosave

`ln-autosave` is a separate, independent component. If present on the same `<form>`, it works alongside `ln-form` without coordination. Neither component is aware of the other.

---

## States

### Default (Empty Form)

- All fields empty, no errors shown
- Submit button disabled
- Labels and placeholders guide the user

### Filling (In Progress)

- Fields being typed in — validation runs per field
- Valid fields: normal or success indicator
- Invalid fields: error message visible in reserved space
- Submit button: disabled until all required fields valid

### Submitting

- Submit button: loading state (spinner, disabled)
- Form fields: optionally disabled during submit
- Coordinator manages this via events

### Error (Server Response)

- General errors → toast
- Field-specific 422 errors → coordinator maps to individual fields
- Form remains filled — never clear on error

### Success

- Navigate away (list page, detail page) OR close modal
- Toast confirmation ("User created", "Changes saved")
- Form is not shown in success state — user sees the next page

---

## Anti-Patterns

- **Validate on blur only** — too late, user already moved on
- **Validate on submit only** — worst UX, user gets a wall of errors
- **Clear form on error** — user loses all input, has to start over
- **Generic "Form is invalid" message** — tell the user WHICH field and WHY
- **Submit button always enabled + re-validate on click** — contradictory, confusing
- **Inline edit everywhere** — inline edit is for single fields, not full forms
- **Modal for complex forms** — if it needs tabs/sections/conditional logic, it's a page
- **Layout shift on error** — always reserve error space below fields
- **Validation rules in JS config** — HTML attributes are the source of truth
- **Custom error text in JS** — error messages live in HTML, rendered by backend
