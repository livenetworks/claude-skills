# Loading State

> Visual feedback that the system is working.

## Two Patterns

| Pattern | Visual | When |
|---------|--------|------|
| Spinner | Rotating icon | Short wait (<2s), button-level actions |
| Shimmer | Animated sweep on structural elements | Longer load, section/page level |

## Rules
- Shimmer on real structural elements (table rows, card slots) — not separate placeholder rectangles
- Button spinner: replaces or accompanies label, button is disabled
- Spinner → progress bar when operation exceeds a few seconds and percentage is available
- Always scoped — never full-page loading for a button-level operation
- Shimmer layout matches the final content layout

## Anti-Patterns
- Full-page spinner for a section load
- Blank screen during loading (no indicator at all)
- Spinner for a 45-second operation (use progress bar)

> For implementation in a specific design system → query that system's own documentation (in this project, via the ln-ashlar routing skill). This file covers WHAT the component must contain, not how any one library spells it.
