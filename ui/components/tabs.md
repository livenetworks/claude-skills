# Tabs

> Switch between categories of information for the same entity.

---

## Core Principle

Tabs organize related but distinct categories of the same entity — not different steps, not different entities. All tab content is in the DOM from the start (backend-rendered HTML). Tabs just show/hide sections. URL hash sync is mandatory.

---

## Anatomy

```
┌─────────────────────────────────────────────────────────────────┐
│  [Info]  [Documents (12)]  [History]                            │ ← nav > ul > li
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Tab content — full HTML, backend-rendered                      │
│  Only the active tab's section is visible                       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Tabs vs Sections — When to Use Which

| Tabs | Sections (scroll) |
|---|---|
| Categories of **different** information (Info / Documents / History) | **Same type** of information grouped (Settings page) |
| User works in one category at a time | User needs to see/compare multiple groups |
| Content is long enough to justify hiding the rest | Content fits or benefits from scrollable overview |

**Rule: if the user needs to compare content from two "tabs" — those are sections, not tabs.**

---

## Tabs in Forms

**Never.** Tabs inside a form hide validation state — the user can't see that a hidden tab has errors. If a form is complex enough to need tabs, use form steps (future) or sections with scroll.

---

## Content Loading

- All tab content is **in the DOM from the start** — backend renders full HTML for every tab
- `ln-tabs` only toggles visibility (show/hide sections)
- No dynamic content fetching, no lazy loading
- Exception: if tab content requires a separate API call (e.g. large dataset per tab), coordinator may load on first tab activation and inject into DOM. This is rare — default is all content in DOM from start.

---

## URL Hash Sync

**Mandatory.** Active tab is reflected in the URL hash.

### Format

Single tab group:
```
#user-tabs:settings
```

Multiple tab groups on the same page:
```
#user-tabs:settings&project-tabs:members
```

### Namespace

Each tab group needs a unique namespace — comes from `id` attribute or `data-ln-tabs-key`:

```html
<section id="user-tabs" data-ln-tabs>       ← namespace = "user-tabs"
<section data-ln-tabs-key="project" ...>    ← namespace = "project"
```

Two tab groups can have tabs with the same key (e.g. both have "info") — the namespace prevents collision.

### Behavior

- Browser back/forward navigates between tab states
- Direct link to a tab works (bookmarkable, shareable)
- Default tab (no hash or namespace not in hash) = `data-ln-tabs-default` value
- Without `id` or `data-ln-tabs-key` → no hash sync, only default tab

---

## Badge Counts

When relevant, tab label includes a count. Badge is a sibling of the button inside the `<li>`:

```html
<li>
    <button data-ln-tab="documents">Documents</button>
    <span class="tab-badge">12</span>
</li>
```

- Count reflects current data (updated when content changes)
- No count when not meaningful (Info tab doesn't need a count)

---

## HTML Structure

```html
<section id="user-tabs" data-ln-tabs data-ln-tabs-default="info">
    <nav>
        <ul>
            <li><button data-ln-tab="info">Information</button></li>
            <li>
                <button data-ln-tab="documents">Documents</button>
                <span class="tab-badge">12</span>
            </li>
            <li><button data-ln-tab="history">History</button></li>
        </ul>
    </nav>

    <section data-ln-panel="info">
        <!-- full HTML, backend-rendered -->
    </section>

    <section data-ln-panel="documents" class="hidden">
        <!-- full HTML, backend-rendered -->
    </section>

    <section data-ln-panel="history" class="hidden">
        <!-- full HTML, backend-rendered -->
    </section>
</section>
```

### Attributes

| Attribute | On | Description |
|---|---|---|
| `data-ln-tabs` | wrapper | Marks the tab container |
| `data-ln-tabs-default="key"` | wrapper | Default active tab |
| `data-ln-tabs-key="name"` | wrapper | Namespace for hash (alternative to `id`) |
| `data-ln-tabs-focus` | wrapper | Focus first input in panel on tab change |
| `data-ln-tab="key"` | `<button>` | Tab trigger |
| `data-ln-panel="key"` | `<section>` | Panel content |

### Events

| Event | When | `detail` |
|---|---|---|
| `ln-tabs:change` | After activating a new tab | `{ key, tab, panel }` |

---

## Anti-Patterns

- **Tabs inside forms** — hides validation state, user can't see errors in hidden tabs
- **Dynamic content loading** — content is in the DOM from the start, backend-rendered
- **Tabs without URL sync** — breaks back button, not bookmarkable, not shareable
- **Tabs for comparing content** — if user needs to see both, use sections with scroll
- **Vertical tabs** — not supported
- **Tabs for steps/wizard** — tabs are categories, not sequential steps
- **Too many tabs** — if more than 5-6, reconsider the information architecture
- **Missing namespace** — without `id` or `data-ln-tabs-key`, multiple tab groups on one page will collide
- **Badge inside button** — badge is a sibling in `<li>`, not a child of `<button>`
