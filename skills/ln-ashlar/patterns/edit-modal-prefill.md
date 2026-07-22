# Pattern: Shared create/edit modal with prefilled form

One `<form>` inside `[data-ln-modal]` serves both **Create** and **Edit**. Edit values are stamped declaratively onto each row's trigger button — **no fill coordinator**.

Use when: a table lists records with inline Edit buttons and you want a single modal, not separate create/edit pages. Admin CRUD index pages (packages, tenants, tags, users…).

> Doctrine #10 — *Declarative Wiring Over Coordinators* (`docs/architecture/mindset.md`): the fill lives in the DOM, inspectable in DevTools, not in JS. The coordinator is the exception, not the default.

---

## Default: declarative fill (zero coordinator)

The trigger declares everything: `data-ln-fill-*` fills the form, `data-ln-modal-*` fills the modal title + sets mode, `data-ln-modal-for` opens it.

```html
<!-- Edit trigger — flat per-field values, one modal, stamped per row -->
<button data-ln-modal-for="package-modal"
        data-ln-modal-name="Pro plan"           {{-- modal title display --}}
        data-ln-fill-form="package-form"
        data-ln-fill-id="42"
        data-ln-fill-name="Pro plan"
        data-ln-fill-max-users="50"
        data-ln-fill-is-active="1">Edit</button>

<!-- New trigger — no payload → form resets, mode = new -->
<button data-ln-modal-for="package-modal" data-ln-fill-form="package-form">New package</button>
```

On click, three independent document listeners fire — no coordinator code:

- `ln-modal` opens the modal and sets `data-ln-modal-mode` (`edit` when a payload is present, `new` when none).
- `ln-fill` reads the trigger's `data-ln-fill-*` → fills `#package-form` (empty payload → `form.reset()`).
- `ln-modal` reads `data-ln-modal-*` → fills the title's `[data-ln-field]`.

### Keys are camelCased by `dataset`

`data-ln-fill-max-users` → record key `maxUsers`. A field whose `name` is the backend column needs `data-ln-fill-as` to match — `name` stays the wire, the fill key is decoupled:

```html
<input name="max_users" data-ln-fill-as="maxUsers">
```

Single-word names (`id`, `name`) match the key directly — no `data-ln-fill-as`.

### In an `ln-table` data-driven row

`fillTemplate` interpolates `{{ }}` in **attribute values** (not only text), so the trigger stamps per row at clone time:

```html
<template data-ln-template="packages-row">
	<tr data-ln-table-row>
		<td>{{ name }}</td>
		<td>
			<button data-ln-modal-for="package-modal" data-ln-modal-name="{{ name }}"
					data-ln-fill-form="package-form" data-ln-fill-id="{{ id }}"
					data-ln-fill-name="{{ name }}" data-ln-fill-max-users="{{ max_users }}"
					data-ln-fill-is-active="{{ is_active }}">Edit</button>
		</td>
	</tr>
</template>
```

---

## Backend contract — `toFormPayload()` (still the single source of truth)

Normalize every field to a scalar on the model, then emit one `data-ln-fill-*` per key. JS never sees `true`/`false`/`null`.

```php
// app/Models/Package.php
public function toFormPayload(): array
{
	return [
		'id'        => $this->id,
		'name'      => $this->name,
		'max_users' => (int) $this->max_users,
		'is_active' => $this->is_active ? 1 : 0,   // scalar — never bool/null
	];
}
```

```blade
<button data-ln-modal-for="package-modal" data-ln-fill-form="package-form"
	@foreach($package->toFormPayload() as $k => $v)
		data-ln-fill-{{ str_replace('_', '-', $k) }}="{{ $v }}"
	@endforeach>Edit</button>
```

**Why a method on the model:** single source of truth for the edit surface. Add a form field = one edit (the method), not a scavenger hunt. Booleans arrive as `"1"`/`"0"` strings; checkbox fill coerces `"0"`/`"false"`/`""` → unchecked.

---

## Booleans — hidden + checkbox (still valid)

Standalone checkboxes submit nothing when unchecked. The hidden input guarantees the field always arrives:

```blade
<input type="hidden" name="is_active" value="0">
<label>
	<input type="checkbox" name="is_active" value="1" data-ln-toggle-switch>
	{{ __('Active') }}
</label>
```

`data-ln-fill-is-active="1"` → checked; `"0"` → unchecked (string coercion handles it).

---

## Submit: create vs update

- **SPA / store layer (default):** `data-ln-form-scope` → native submit intake by `ln-data-coordinator` → `ln-data-store:request-create | request-update`; create-vs-update is decided by form method (`POST` → create, `PUT` → update) and hidden `id`. No application JS for fill *or* routing.
- **Laravel REST (ln-form fold):** add `data-ln-form-action-edit` to the form. On edit, `ln-form` rewrites `form.action` to `/{resource}/{id}` and auto-ensures `<input name="_method">` with `PUT` (or the value of `data-ln-form-action-method`). No coordinator JS, no second click listener.

  ```html
  <!-- Minimal: baseAction + '/' + id -->
  <form data-ln-form action="/packages" data-ln-form-action-edit>

  <!-- Custom template with :id placeholder -->
  <form data-ln-form action="/packages" data-ln-form-action-edit="/packages/:id">

  <!-- Custom verb -->
  <form data-ln-form action="/packages"
        data-ln-form-action-edit="/packages/:id"
        data-ln-form-action-method="PATCH">
  ```

  The `<input name="_method">` is auto-ensured — do not author it. Fill stays
  fully declarative; the form's action/verb is the only coordinator concern, and
  `ln-form` handles it from the fill record.

Create-only fields (those absent from `toFormPayload()`) hide on edit via CSS keyed on the mode — `[data-ln-modal-mode="edit"] [data-create-only] { display: none }` — and are `disabled` in the same small loop when they must be excluded from submit.

---

## Anti-patterns to avoid

❌ **A JSON blob + a JS fill loop** (`data-fields='@json(...)'` → `JSON.parse` → populate). This *was* the recipe; the declarative trigger replaces it for click-triggered fills. A parsed object survives only for genuinely programmatic fills — see `docs/architecture/coordinator.md`.

❌ **Guessing types in JS** (`!!parseInt(val)` breaks on JS `true`). Normalize to scalars at the backend (`toFormPayload()`).

❌ **Putting `only([...])` in the view** — splits the field list across Blade files. Put it on the model.

✅ **Per-field `data-ln-fill-*` attributes** — this *is* the pattern now. The old "verbose, offers nothing over a blob" objection is obsolete: per-field attributes earn DOM-as-contract inspectability and **zero coordinator JS**. That is the whole point of doctrine #10.

---

## When NOT to use this pattern

- **Nested or repeating structures** (one-to-many, JSON columns) — the flat payload is too thin. Use a dedicated edit route that server-renders the form body.
- **The set of fields differs per record** — prefer a dedicated edit route.
- **Values come from an expensive join** — don't pay the cost per row on index render. Lazy-fetch on edit click and fill programmatically: `window.lnCore.lnFill(modal, record)` after the fetch resolves (the coordinator exception).
