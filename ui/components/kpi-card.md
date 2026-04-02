# KPI Card

> Single metric with context — the headline of a dashboard.

---

## Anatomy

```
┌─────────────────────┐
│ Total Documents      │  ← label
│ 1,247                │  ← value
│ ↑ 12% vs last month │  ← trend (optional)
└─────────────────────┘
```

- **Label** — what is being measured. Short, noun-based ("Total Documents", "Pending Review")
- **Value** — the number. Largest, heaviest element. Formatted by backend according to page locale (thousands separator, currency, abbreviation)
- **Trend** — optional. Direction arrow + percentage + comparison period. Color reflects whether the direction is good or bad (↑ revenue = green, ↑ errors = red)

---

## Rules

- One primary metric per card — never two numbers competing
- 3-5 cards per dashboard, no more (SKILL.md §4)
- Clickable — card links to the list/detail page for that dataset
- Pure HTML/CSS — not a JS component. Backend renders the values.
- Number formatting is backend responsibility (locale-aware)

---

## Trend Indicators

| Direction | Good | Bad |
|---|---|---|
| ↑ Up | Green (revenue, users, completions) | Red (errors, overdue, complaints) |
| ↓ Down | Green (bugs, incidents, complaints) | Red (revenue, users, completions) |
| — Flat | Neutral | Neutral |

Context determines color — "up" is not always good.

---

## Responsive

- Desktop: 3-5 cards in a row
- Tablet: 2-3 per row
- Mobile: stack vertically, full width

---

## Anti-Patterns

- **More than 5 KPI cards** — if everything is key, nothing is
- **Two numbers in one card** — one card, one metric
- **Number formatting in frontend JS** — backend formats according to locale
- **Non-clickable cards** — every KPI should lead to its detail/list page
- **Decorative icons as focal point** — the number is the focal point, not the icon
