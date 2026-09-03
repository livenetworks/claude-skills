# Status Badge

> Visual indicator of an item's current state.

## Core Principle

A badge communicates state through THREE signals: color dot + text + tinted background. Never color alone (accessibility — WCAG 1.4.1).

## Requirements

### Five Semantic Categories
| Category | Color | Examples |
|----------|-------|---------|
| Success | Green | Active, Approved, Completed, Online |
| Error | Red | Rejected, Failed, Expired, Offline |
| Warning | Amber | Pending, Draft, Expiring, Attention |
| Info | Blue | In Progress, Scheduled, New |
| Neutral | Gray | Archived, Inactive, Unknown |

### Behavior
- Dot + text + tinted background — all three always present
- Actionable variant: badge is a trigger for dropdown or confirm action
- No custom colors beyond the five categories
- Badge text is always a readable word, never a code

## Anti-Patterns
- Color-only status (inaccessible)
- Custom colors per status (fragments visual language)
- Status codes instead of human text

> For implementation in a specific design system → query that system's own documentation (in this project, via the ln-ashlar routing skill). This file covers WHAT the component must contain, not how any one library spells it.
