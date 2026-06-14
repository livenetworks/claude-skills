# ln-ashlar — Tabs Implementation

> HOW to build tabs with ln-ashlar. For WHAT tabs must have → global ui/components/tabs.md.

## Component

- Attribute: `data-ln-tabs` on the tab container (wrapper)
- Tab triggers: `data-ln-tab="key"`
- Tab panels: `data-ln-panel="key"` (inactive panels start with `class="hidden"`)
- Default tab: `data-ln-tabs-default="key"` on the wrapper

## Mode is set by the trigger type

The trigger element — not any wrapper attribute — selects the mode:

- `<a href="#nsKey:key">` triggers → **URL hash sync** (shareable, back/forward aware). Needs a namespace: `id` or `data-ln-tabs-key` on the wrapper.
- `<button>` triggers → **localStorage persist**, opt-in via `data-ln-persist`. URL untouched.

Mixing both in one group falls back to persist + a console warning. An `id` no longer forces hash mode.

## HTML Pattern — button + persist (remembers last tab)

```html
<div data-ln-tabs data-ln-tabs-default="general" data-ln-persist="user-tabs">
    <nav>
        <button type="button" data-ln-tab="general">General</button>
        <button type="button" data-ln-tab="permissions">Permissions (5)</button>
        <button type="button" data-ln-tab="history">History</button>
    </nav>
    <section data-ln-panel="general">...</section>
    <section data-ln-panel="permissions" class="hidden">...</section>
    <section data-ln-panel="history" class="hidden">...</section>
</div>
```

## HTML Pattern — anchor + hash (shareable URL)

```html
<section id="user-tabs" data-ln-tabs data-ln-tabs-default="general">
    <nav>
        <a href="#user-tabs:general" data-ln-tab>General</a>
        <a href="#user-tabs:permissions" data-ln-tab>Permissions</a>
    </nav>
    <section data-ln-panel="general">...</section>
    <section data-ln-panel="permissions" class="hidden">...</section>
</section>
```

## SCSS

```scss
[data-ln-tabs] nav { @include tabs-nav; }
[data-ln-tabs] [data-ln-tab] { @include tabs-tab; }
[data-ln-tabs] [data-ln-panel] { @include tabs-panel; }
```

The active trigger carries `data-active` (an attribute, not a class) + `aria-selected="true"`, synced from `data-ln-tabs-active` on the wrapper.

## Events

| Event | When |
|-------|------|
| `ln-tabs:change` | Tab switched. Detail: `{ key, tab, panel }` |
