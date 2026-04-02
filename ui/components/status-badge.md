# Status Badge

> Visual indicator for entity state — dot + text + tinted background.

---

## Anatomy

```
┌──────────────────┐
│ ● Approved       │  ← dot + text + tinted pill background
└──────────────────┘
```

---

## Semantic Categories

| Category | Examples | Color token |
|---|---|---|
| Success | Approved, Active, Completed | `--color-success` |
| Warning | Pending, Expiring, Review | `--color-warning` |
| Error | Rejected, Failed, Overdue | `--color-error` |
| Info | In Progress, New, Updated | `--color-info` |
| Neutral | Draft, Archived, Inactive | `--color-muted` |

---

## Rules

- Never color-only without text (accessibility)
- Not a JS component — pure CSS (mixin)
- Color comes from CSS variable on element or parent
- Dot is same color as text, background is tinted (low opacity)

---

## Actionable Variant

For inline status change without opening a modal:

- **2 statuses** (active/inactive) → `<button>` styled as badge + `ln-confirm` for toggle
- **3+ statuses** → `<button>` styled as badge + `ln-dropdown` for selection

This is not a new component — it's badge CSS on a `<button>` combined with existing ln-confirm or ln-dropdown JS components.

---

## Anti-Patterns

- **Color without text** — inaccessible, meaningless to colorblind users
- **Custom colors per status** — use the 5 semantic categories, not per-value colors
- **Icons inside badge** — dot + text is sufficient, icons add noise
