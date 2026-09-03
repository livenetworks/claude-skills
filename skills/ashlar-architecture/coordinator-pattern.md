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

### Library Coordinator

Generic and reusable, shipped with the component library. Coordinates primitives
from the same family — a disclosure container closing its sibling panels, a form
enabling its submit button when its fields report valid.

You do not write these. Query the library's documentation for which ones exist
and what they listen for; never assume from the name.

### Project Coordinator

Application-specific. Connects components from different families across a page.
This is the kind you write.

**Use your own attribute namespace, never the library's.** Below, `data-app-*` is
a placeholder — substitute your project's prefix. The library owns `data-{lib}-*`;
a project coordinator writing into that namespace couples your application to
library internals that will be refactored out from under you.

```
app-profile:switched   →  coordinator  →  sidebar[data-app-active-profile] = id
                                                │
                                                ▼
                                        dependent panel reloads

app-panel:changed      →  coordinator  →  profileStore.persist()
```

Example for a CRUD page (coordinator-driven, store-backed):

```
<table>:row-action     →  coordinator  →  open the dialog via its state attribute
  (edit, record)                          fill it with the record

<form> submit intake   →  coordinator  →  store: request-update { id, data }
                                          transport: request-update { url, data }

store: updated         →  coordinator  →  close the dialog
                                          notify the user
```

> **Before writing any of this, check whether it is needed at all.** Component
> libraries increasingly express click-triggered fills, dialog opening and form
> wiring declaratively in markup, with zero coordinator code. Query the library
> docs first. Reserve a coordinator for genuinely programmatic or store-driven
> flows — conflict resolution, deep-link pre-fill, cross-family sequencing.

Project coordinators live in the project's own JS, not in the library.

---

## Rules

1. **No DOM, no rendering** — coordinator is pure event wiring
2. **No direct method calls** — set attributes, dispatch events. Never `el.lnComponent.doSomething()`
3. **Single point of coupling** — coordinator is the only place that knows which components exist together
4. **Replaceable components** — swap one component for a different implementation → only the coordinator changes
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
