# Pattern: Shared create/edit modal with backend-normalized prefill

A recipe for reusing one `<form>` inside `[data-ln-modal]` for both **Create** and **Edit** flows, where edit values come from a JSON payload embedded on each row's trigger button.

Use when: a table lists records with inline Edit buttons and you want a single modal rather than separate create/edit pages. Fits index pages for admin CRUD (packages, tenants, tags, users, etc.).

---

## The state problem this solves

The naive approach puts `$model->only([...])` in the view and guesses types in JS:

- Eloquent boolean cast returns `true`/`false`.
- Form HTML has `value="1"` / `value="0"`.
- `form.querySelector('[value="'+val+'"]')` tries to match `[value="true"]` → silent miss.
- Latent bug: editing an inactive record silently shows "Active" because `form.reset()` hit the HTML default first.

**Fix: normalize at the backend.** One serializer method on the model outputs every field as a scalar that can be assigned to an HTML input without JS type-guessing.

---

## The contract

The backend emits a JSON object where:

| Input type | Value shape |
|---|---|
| text / textarea / email / url / number | string or number |
| select (single) | string (matches `<option value>`) |
| radio group | string (matches one `<option value>`) |
| checkbox (standalone or toggle-switch) | `1` or `0` |
| nullable text | `''` (empty string, not `null`) |

JS never sees `true`, `false`, or `null`. Every value assigns cleanly.

---

## Backend: `toFormPayload()` on the model

```php
// app/Models/Package.php
class Package extends Model
{
    protected $casts = [
        'is_active' => 'boolean',
        // ...
    ];

    public function toFormPayload(): array
    {
        return [
            'name'            => $this->name,
            'max_users'       => (int) $this->max_users,
            'max_documents'   => (int) $this->max_documents,
            'is_active'       => $this->is_active ? 1 : 0,
        ];
    }
}
```

**Why a method on the model**: single source of truth for which fields the edit form exposes. Adding a new form field = one edit (the method), not a scavenger hunt across views.

**What goes in / what stays out**: create-only fields (like `admin_email` that maps to a related user, not a tenant attribute) are **excluded**. The coordinator derives create-only-ness implicitly — any form field whose name is not a key in the payload is `disabled` and its wrapper `hidden` on edit. No marker attribute in the Blade. `toFormPayload()` is the single source of truth for the edit surface.

---

## View: the edit trigger

```blade
@foreach($packages as $package)
    <tr>
        <td>{{ $package->name }}</td>
        <td>
            <button data-ln-modal-for="package-modal"
                    data-action="{{ route('admin.packages.update', $package) }}"
                    data-method="PUT"
                    data-title="{{ __('Edit Package') }}: {{ $package->name }}"
                    data-fields='@json($package->toFormPayload())'>
                <svg class="ln-icon"><use href="#ln-edit"></use></svg>
            </button>
        </td>
    </tr>
@endforeach
```

Each row carries its own payload — no round-trip on Edit click.

---

## View: the form partial

The form must contain a blank `_method` hidden input next to `@csrf`. The coordinator **only updates** the value — it does not create the element — so if it's missing Laravel receives a raw POST to `/resource/{id}` and rejects it with 405.

```blade
<form data-ln-ajax method="POST" action="{{ route('admin.packages.store') }}">
    @csrf
    <input type="hidden" name="_method" value="">
    {{-- ... fields ... --}}
</form>
```

On create, the coordinator writes `_method="POST"` (a no-op for the framework). On edit, it writes `_method="PUT"` (or whatever `data-method` says) and Laravel's method-override middleware spoofs the verb.

**Create-only fields need no marker.** The coordinator derives create-only from `toFormPayload()`: any named field whose name is NOT a key in the payload is treated as create-only on edit. Its wrapper (`.form-element` or `fieldset`) is hidden and the input is `disabled` (which removes it from FormData and skips HTML5 `required` validation). On create, the same loop re-enables and un-hides everything — stateless, no snapshot of original attributes needed.

```blade
{{-- No attribute needed. admin_email isn't in Tenant::toFormPayload(), so
     on edit the coordinator disables the input and hides .form-element. --}}
<div class="form-element">
    <label for="admin_email">{{ __('Admin Email') }}</label>
    <input type="email" name="admin_email" required>
</div>
```

`toFormPayload()` is the single source of truth for the edit surface: want a field editable on edit? Add it to the method. Don't want it? Leave it out. No second place to update.

---

## JS: the coordinator

A single capture-phase click listener on `document` prepares the modal before `ln-modal`'s own listener opens it.

```js
document.addEventListener('click', function (e) {
    const trigger = e.target.closest('[data-ln-modal-for]');
    if (!trigger || !trigger.dataset.action) return;

    const modal = document.getElementById(trigger.dataset.lnModalFor);
    const form = modal?.querySelector('form');
    if (!form) return;

    form.reset();

    const isEdit = !!trigger.dataset.fields;
    const fields = isEdit ? JSON.parse(trigger.dataset.fields) : {};

    if (isEdit) {
        for (const name in fields) {
            const el = form.elements[name];
            if (!el) continue;
            const val = fields[name];

            // Collection: radio group, or hidden+checkbox sharing a name
            if (el.length !== undefined && el.nodeType === undefined) {
                const cb = Array.from(el).find(n => n.type === 'checkbox');
                if (cb) { cb.checked = val === 1; continue; }
                el.value = val;  // radio group — native selection by value
                continue;
            }

            // Single element
            if (el.type === 'checkbox') {
                el.checked = val === 1;
            } else {
                el.value = val ?? '';
            }
        }
    }

    // Implicit create-only: any named field NOT in toFormPayload() is create-only.
    // On edit → disable + hide wrapper. On create → re-enable + un-hide.
    // Stateless: no snapshot of original required/disabled needed.
    Array.from(form.elements).forEach(function (el) {
        const name = el.name;
        if (!name || name.startsWith('_')) return;  // skip _token, _method
        const hide = isEdit && !(name in fields);
        el.disabled = hide;
        const wrapper = el.closest('.form-element, fieldset');
        if (wrapper) wrapper.hidden = hide;
    });

    form.action = trigger.dataset.action;
    const methodInput = form.querySelector('input[name="_method"]');
    if (methodInput) methodInput.value = trigger.dataset.method || 'POST';
}, true);  // capture phase — fires before ln-modal's bubble-phase listener
```

**Why `disabled` and not `required = false`**:

- `disabled` removes the input from form submission entirely — the server never sees the field, which matches the semantics of "create-only, not part of the update payload".
- `disabled` also bypasses HTML5 validation (including `required`), so no `required`-toggle gymnastics.
- `disabled` is idempotent and stateless: on every click the loop re-derives the correct value from `isEdit` + `fields`. No need to snapshot the original `required` state and restore it.

**Wrapper convention**: the coordinator uses `.closest('.form-element, fieldset')` to find the element to visually hide. This depends on project form structure — every form input is wrapped in a `.form-element` or nested in a `fieldset`. If your project uses a different wrapper, update the selector.

**Why `form.elements[name]` and not `querySelector`**:

- Radio groups: `form.elements.auth_method` returns a `RadioNodeList`. Assigning `.value = 'ldap'` natively selects the matching radio. No `[value="..."]` string concatenation.
- Single inputs: returns the element directly, `.value = val` works.
- Selects, textareas, inputs: all handled by one `.value = val` branch.
- Hidden + checkbox pair (see next section): detected via `el.length !== undefined` and the checkbox is found inside.

The populate loop collapses from ~20 lines with three querySelector branches to ~12 lines with two branches.

---

## The hidden+checkbox pattern for boolean fields

Standalone checkboxes don't submit anything when unchecked — the server never sees the field. To make a boolean always arrive at the controller:

```blade
<input type="hidden" name="is_active" value="0">
<label>
    <input type="checkbox" name="is_active" value="1" checked data-ln-toggle-switch>
    {{ __('Active') }}
</label>
```

- Checkbox unchecked → only hidden sends `is_active=0`
- Checkbox checked → both send; last-value-wins in PHP form parsing → `is_active=1`

`form.elements['is_active']` returns a `RadioNodeList` of both. The coordinator's collection branch finds the checkbox inside and sets `.checked = val === 1`. The hidden stays at `0` (untouched).

---

## Anti-patterns to avoid

❌ **Putting `only([...])` in the view** — splits the field list across Blade files. Move it to the model.

❌ **Guessing types in JS** — `!!parseInt(val)` breaks on JS `true` (parses to NaN). Normalize at the backend.

❌ **Three separate `querySelector` branches** — use `form.elements[name]`. Radio groups work natively.

❌ **Filling the form on the server and sending it down per-edit via AJAX** — works but kills the "one modal, many rows" benefit. Use only if rows are huge or edit-uncommon.

❌ **Per-field `data-*` attributes** (`data-name`, `data-max-users`) — attribute-per-field is verbose, camel-cases snake_case field names, and offers nothing over one JSON blob.

---

## When NOT to use this pattern

- **Forms with nested or repeating structures** (one-to-many, JSON columns) — the flat payload is too thin. Use a dedicated edit route that server-renders the form.
- **Forms where the set of fields differs per record** — prefer a dedicated edit route.
- **Forms where values come from an expensive join** — don't pay the cost per row on index render. Lazy-fetch on edit click.

For those, use classic `GET /{resource}/{id}/edit` returning a partial that replaces the modal body.
