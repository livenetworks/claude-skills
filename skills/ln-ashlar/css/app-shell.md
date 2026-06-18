# Skill: App Shell

Decision guide for building application layouts with ln-ashlar's
app-shell mixins. Full spec: `docs/css/app-shell.md`.

## When to use

Any application UI with a fixed header + sidebar navigation + main
content area + optional footer. Not for landing pages / marketing
pages.

## The mixin cluster

| Mixin | Role |
|---|---|
| `app-wrapper` | Outer flex column, `min-height: 100vh` |
| `app-header` | Fixed top bar; descendant `button` defaults to ghost surface |
| `app-header-left` / `-right` / `-actions` | Header region recipes (flex + gap + child bindings) |
| `header-avatar` | 2rem circular image thumbnail (NOT `@mixin avatar`) |
| `app-main` | Main column below the header; sidebar-open padding shift |
| `sidebar` + `sidebar-drawer` | Apply both — base shell + drawer positioning |
| `app-scrim` | Mobile overlay behind drawer |
| `app-footer` | Bottom chrome bar; `> span:last-child` gets `--fg-subtle` |

## Global bindings (prototyping)

`.app-wrapper`, `.app-header`, `.app-main`, `.app-sidebar`,
`.app-scrim`, `.app-footer`, `.header-left`, `.header-right`,
`.header-actions`, `.header-avatar`.

In production: semantic selectors + `@include`.

## Intrinsic tokens

| Token | Dense base (`:root`) | comfortable | spacious |
|---|---|---|---|
| `--app-header-height` | `3.25rem` (52px) | `3.5rem` (56px) | `4rem` (64px) |
| `--app-sidebar-width` | `14.5rem` (232px) | `16rem` (256px) | `17.5rem` (280px) |
| `--app-scrim-bg` | `hsl(var(--color-neutral-900) / 0.4)` | — | — |

These ARE density-reactive — `[data-density="comfortable|spacious"]` overrides them
in `_density.scss`. They are not spacing-rhythm tokens (do not read `--size-*`), but
they do scale with density tiers.

## Key behaviors

1. **Sidebar-open padding shift** — `app-main` uses
   `&:has(.app-sidebar[data-ln-toggle="open"])` to shift content +
   footer together. On `mq-down(md)` the shift is suppressed because
   the drawer overlays content instead.
2. **Header buttons default to ghost** — `app-header` applies
   `--btn-bg: transparent; --btn-border: transparent; padding: 0;
   color: var(--fg-muted)` to every descendant `<button>`.
   `app-header-actions` layers a bordered variant on top.
3. **Content column is `> section`** — `app-main > section` is the
   centred, capped, padded, stack-with-gap content column. Projects
   put all page content inside `<section>`.
4. **Sidebar header** absorbs brand row + close button + search
   field via `@mixin sidebar > header`. `flex-wrap` lets the search
   drop to a second full-width row without extra wrappers.

## Anti-patterns

- Do NOT put `margin-left: var(--app-sidebar-width)` on the content
  or footer directly — overflows at viewport width. Let
  `app-main`'s parent-padding trick handle the shift.
- Do NOT manually re-override `--app-header-height` / `--app-sidebar-width`
  outside of a density scope — they are already density-reactive via
  `[data-density]`. Only override them for project-specific geometry
  deviations, never to "undo" density behavior.
- Do NOT use `@mixin avatar` in the header bar — it has a ring +
  hover that compete with the header's chrome. Use
  `@mixin header-avatar`.
