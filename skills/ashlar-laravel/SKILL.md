---
name: ashlar-laravel
description: "Pointer for building ln-ashlar UI inside a Laravel project — e.g. a modal, form, table or toast rendered from Blade. Holds no Laravel rules: all Laravel conventions, including Blade components (<x-…>), live in the ln-laravel skill. Triggers on any mention of ashlar or ln-ashlar together with Blade, Laravel views or Blade components."
---

# ln-ashlar in a Laravel project

This skill holds no Laravel rules. Laravel conventions — controllers, read/write
models, view composers, routes, services, Blade templates and Blade components —
live in the **ln-laravel** skill.

When an ln-ashlar UI element is built in Blade (for example, a modal):

1. Build the Blade side by **ln-laravel**: §7 "Blade Components — `@include` vs
   `<x-component>`" for the component, and `toFormPayload()` (§4) when it is a
   create/edit form prefilled from a table row.
2. Take the ln-ashlar markup, attributes and events from the ln-ashlar
   documentation, as the **ashlar-routing** skill directs. Never invent them.
