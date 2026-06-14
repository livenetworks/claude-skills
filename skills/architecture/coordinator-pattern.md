# Coordinator Pattern

> Thin glue layer that connects decoupled components via events and attributes. No DOM, no rendering.
>
> **Note:** Examples use ln-ashlar conventions (data attributes, CustomEvents, MutationObserver). The pattern itself is framework-agnostic — adapt the communication mechanism to your stack.

---

## Core Principle

Components don't know about each other. A coordinator listens to events from one component and sets attributes on another. If you replace a component, only the coordinator changes.

---

## How It Works

```
Component A fires event
  → Coordinator listens
  → Coordinator sets attribute on Component B
  → Component B's MutationObserver detects attribute change
  → Component B reacts independently
```

The coordinator never calls methods directly. It sets attributes — the component decides how to respond. This is declarative, inspectable in DevTools, and consistent with how Web Components work.

---

## Two Types

### Library Coordinator (ln-ashlar)

Generic, reusable. Coordinates primitives from the same family.

| Coordinator | Primitives | What it does |
|---|---|---|
| `ln-accordion` | `ln-toggle` children | Listens `ln-toggle:open` → closes siblings via attribute |
| `ln-form` | `ln-validate` children | Listens `ln-validate:valid/invalid` → enables/disables submit |

Library coordinators live in ln-ashlar and are available to all projects.

### Project Coordinator (project-specific)

Application-specific. Connects components from different families across the page.

Example from ln-mixer:

```
ln-profile:switched  →  coordinator  →  sidebar[data-ln-playlist-profile] = id
                                              │
                                              ▼
                                         ln-playlist reloads

ln-playlist:changed  →  coordinator  →  lnProfile.persist()
```

Example for a CRUD page (coordinator / store-driven fills):

```
ln-table:row-action      →  coordinator  →  modal[data-ln-modal] = "open"
  (edit, record)                            lnFill(modal, record)   // fans out: form + [data-ln-fillable]

ln-form:submit           →  coordinator  →  ln-store:request-update { data }

ln-store:confirmed       →  coordinator  →  modal[data-ln-modal] = "close"
                                           toast("Saved")

ln-store:reverted        →  coordinator  →  toast("Error: " + error)
```

> **Note:** for click-triggered fills from table rows or inline buttons, the declarative `data-ln-fill-form` + `data-ln-fill-*` attributes (and `data-ln-modal-*` for modal display) handle the fill with **no coordinator code** — see `js/ln-fill/README.md`. Use the coordinator above only for programmatic / store-driven fills (e.g. conflict resolution, deep-link pre-fill).

Project coordinators live in the project's JS (e.g. `resources/js/coordinators/`), not in ln-ashlar.

---

## Rules

1. **No DOM, no rendering** — coordinator is pure event wiring
2. **No direct method calls** — set attributes, dispatch events. Never `el.lnComponent.doSomething()`
3. **Single point of coupling** — coordinator is the only place that knows which components exist together
4. **Replaceable components** — swap ln-profile for a different auth system → only coordinator changes
5. **Attributes as communication** — declarative, inspectable, triggers MutationObserver
6. **One coordinator per scope** — page-level coordinator per page, or one app-level coordinator for SPA

---

## When to Use a Coordinator

| Situation | Coordinator? |
|---|---|
| Two components on the same page need to communicate | Yes — project coordinator |
| Primitive components form a family (toggle/accordion, validate/form) | Yes — library coordinator in ln-ashlar |
| Component reacts to its own user input (click, keyup) | No — component handles internally |
| Component needs data from server | No — ln-store handles, coordinator wires store events to UI |
| Single component, no inter-component communication | No |

---

## Anti-Patterns

- **Component imports another component** — components don't know about each other, coordinator connects them
- **Coordinator renders DOM** — it's glue, not a component
- **Coordinator calls `.open()`, `.close()`, `.loadData()`** — set attributes, let the component react
- **Fat coordinator with business logic** — coordinator is thin. Business logic lives in services (backend) or in the component itself
- **Global coordinator for everything** — scope coordinators to pages or features. One god-coordinator is an anti-pattern
