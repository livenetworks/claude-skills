# Visual Language Rules

> Rules for visual consistency — not "what component to use" but "how the design must behave as a system."

---

## 1. Radius + Spacing Consistency

**The rule:** A design either uses rounded corners or it doesn't. The two modes have different spatial implications and must be applied consistently.

### Rounded corners (radius > 0)

Rounded corners imply that elements **float** — they are objects on a surface, not part of the surface. Floating objects need air around them.

**Nav links with radius — WRONG:**
```
┌──────────────────┐
│╭────────────────╮│  ← rounded link touches the walls = awkward
││    ● Members   ││     the radius fights the flush alignment
│╰────────────────╯│
│╭────────────────╮│
││    ● Content   ││
│╰────────────────╯│
└──────────────────┘
```

**Nav links with radius — CORRECT:**
```
┌──────────────────┐
│                  │
│  ╭────────────╮  │  ← breathing room on left and right
│  │ ● Members  │  │     the element clearly "floats"
│  ╰────────────╯  │
│  ╭────────────╮  │
│  │ ● Content  │  │
│  ╰────────────╯  │
└──────────────────┘
```

### Sharp corners (radius = 0)

Sharp corners imply **structure** — elements are part of a grid, attached to the container. Flush alignment is correct and expected.

**Nav links without radius — CORRECT:**
```
┌──────────────────┐
│ ● Members        │  ← full-width, flush = intentional and clean
│──────────────────│
│ ● Content        │
│──────────────────│
└──────────────────┘
```

### The rule in code

```scss
// Rounded nav links MUST have mx() — never flush to container
.nav a {
    @include rounded-md;
    @include mx(0.5rem);   // ← required when radius is applied
    @include px(0.75rem);
}

// Sharp nav links CAN be flush — no mx() needed
.nav a {
    // no border-radius
    @include px(1rem);     // padding for content, not for floating
}
```

**Applied to all components:** Any element with `border-radius` that sits inside a container must have horizontal margin so its rounded corners don't touch the container wall.

---

## 2. Shadow + Border: Pick One

Shadows imply **elevation** (the element lifts off the page). Borders imply **containment** (the element is bounded on a flat surface). Both together usually cancel each other visually.

| Context | Use | Reason |
|---|---|---|
| Cards, panels, modals | Shadow only, thin border | They sit above the surface |
| Inputs, selects | Border only, no shadow | They sit on the surface |
| Focused inputs | Border (primary color) + focus ring | Ring is not a decorative shadow |
| Active/hover cards | Shadow increases, border fades | They lift further |

**Exception:** A very subtle border (`color-border`) alongside a subtle shadow (`shadow-xs`) is acceptable — it reinforces the card edge on screens where shadows wash out. This is the ln-acme card pattern.

---

## 3. Icon Consistency

All icons in a UI must come from the same set and same weight.

- **ln-acme standard:** Tabler Icons, outline variant, stroke-width 2
- Never mix Tabler with Heroicons, Material Icons, Font Awesome, etc.
- Never mix outline and filled variants of the same set within one UI

If a needed icon doesn't exist in Tabler, pick the closest equivalent — do not import a single icon from another set.

```bash
# Check Tabler first — 4000+ icons available in source library
ls js/ln-icons/tabler/ | grep "keyword"

# Copy to bundled set if found
cp js/ln-icons/tabler/icon-name.svg js/ln-icons/icons/icon-name.svg
```

---

## 4. Spacing Scale Discipline

Never invent spacing values. Use the token scale: `0.25 / 0.5 / 0.75 / 1 / 1.25 / 1.5 / 2 / 3rem`.

If you reach for `0.6rem` or `1.1rem` or `14px`, stop — you are compensating for a different problem (wrong component size, wrong font size, wrong layout). Fix the root cause, don't patch with a custom spacing value.

**Common traps:**
- Input/button "not quite aligned" → they have different padding tokens, fix that
- Text "not quite centered" → use `align-items: center`, not a padding hack
- Section "needs just a bit more breathing room" → go up to the next spacing step

---

## 5. Color Has Meaning — Never Decorative

Color communicates state, not style.

| Color | Meaning | When to use |
|---|---|---|
| Primary (brand blue) | Interactive, selected, active | Links, active nav, selected state, primary buttons |
| Success (green) | Positive outcome | Approved, active, online, completed |
| Error (red) | Problem, destruction | Rejected, failed, delete action |
| Warning (amber) | Caution, attention | Pending, expiring, approaching limit |
| Muted (grey) | Inactive, disabled, metadata | Disabled state, timestamps, labels |

**Never use color to "make it pretty."** If you are about to add a colored border, a colored background, or a colored icon to something that has no state meaning — stop.

**Never use a custom color not in the token set.** If the existing semantic tokens don't cover the case, the problem is likely an information architecture decision, not a missing color.

---

## 6. Typography Is Not Decoration

- **One font family** — Inter for all UI text. No decorative fonts, no mixing.
- **Four weights used:** 400 (body), 500 (labels/medium), 600 (headings/semibold), 700 (bold KPIs)
- **Uppercase only for:** labels inside components (nav section headings, table column indicators). Never for body text or headings.
- **Line-height for UI vs reading:** UI elements (buttons, nav, labels) = `1.1`. Body text = `1.5–1.75`. Never apply reading line-height to UI elements — it creates visible extra space above/below.

---

## 7. Interactive Element Consistency

All interactive elements must behave consistently:

| State | How |
|---|---|
| Default | Visible but quiet — not competing with content |
| Hover | Color change only — no `translateY`, no `box-shadow` appears |
| Active | Slightly darker than hover |
| Focus | Visible ring — `hsl(var(--color-primary) / 0.12)` soft ring, not thick outline |
| Disabled | 50% opacity, `cursor-not-allowed` |

**No hover animations:** `translateY`, `scale`, `box-shadow` appearing on hover are marketing-page patterns. Business UI uses color-only hover.

---

## 8. Radius Scale

Use the token scale consistently:

| Context | Radius |
|---|---|
| Buttons, inputs, small elements | `rounded-md` (8px) |
| Cards, panels, modals | `rounded-md` (8px) |
| Badges, pills, tags | `rounded-full` (9999px) |
| Dropdown menus | `rounded-md` (8px) |
| Tooltips | `rounded-sm` (4px) |

**Never mix radius scales within the same design.** If buttons are `rounded-md`, everything else in the same interface should also use `rounded-md` or `rounded-full` (pills) — not `rounded-lg` or `rounded-xl`.

The ln-acme default is `rounded-md` throughout — this matches Tabler's visual language.

---

## 9. Navigation Link Indicators

Navigation links communicate two states: **hover** (I can click here) and **active** (I am here). The visual weight must always follow this hierarchy — hover is softer than active, never the reverse.

Four indicator styles are available as presets. Pick one and apply it consistently across all navigation in the same interface.

| Preset | Style | Use when |
|---|---|---|
| `nav-links-rounded` | Floating pill, tinted bg | Sidebar with light or coloured bg |
| `nav-links-border-left` | Instant inset left bar | Sidebar, minimal motion preference |
| `nav-links-border-grow` | Animated spring left bar | Sidebar, motion adds character |
| `nav-links-border-top` | Top bar grows from center | Horizontal nav, tab rows |

**Hover vs active rule:**

| State | Signal |
|---|---|
| Default | No indicator, muted text |
| Hover | Partial indicator (e.g. 45% bar height, 40% opacity) or very faint bg |
| Active | Full indicator + primary text + semibold |

**Exception to §7 (no hover animations):** Navigation link bar indicators are allowed to animate on *active state change* (click/navigation), not on hover. Hover still uses opacity/scale-only — no transform triggered by the pointer moving. The spring animation fires when the route changes, which is a user-initiated state change, not a decorative hover effect.