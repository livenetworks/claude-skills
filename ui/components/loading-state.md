# Loading State

> Visual feedback during async operations.

---

## Two Mechanisms

### Button Spinner

For action feedback — submit, save, delete. Spinner replaces or appears next to button text while the request is in progress. Button is disabled during loading.

### Shimmer

CSS animation on placeholder elements — a light wave moving across a gray surface, indicating content is loading. Use when waiting for first data load (e.g. first visit, IndexedDB empty). After first load, stale-while-revalidate means content appears instantly from cache — shimmer is rarely seen.

---

## Rules

- Never full-page spinner — always scoped to the affected section
- Button spinner for actions (user-initiated)
- Shimmer for content areas (system-initiated loading)
- Complex loading patterns (progress bars, multi-stage) are per-project, not ln-acme

---

## Anti-Patterns

- **Full-page spinner** — blocks everything, no context for the user
- **Spinner for content loading** — shimmer is more informative (shows shape of expected content)
- **Loading state without disabling interaction** — user clicks again, causes double action
