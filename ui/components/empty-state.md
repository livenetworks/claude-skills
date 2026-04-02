# Empty State

> What the user sees when there is no content to display.

---

## Two Types

### No Data Exists (Onboarding)

The entity has never been created. Guide the user to their first action.

```
    No documents yet
    Create your first document to get started
    [+ Create Document]
```

- Heading: what's missing
- Description: what to do about it
- CTA button: the action that resolves the empty state

### Filter / Search Returned Zero

Data exists but the current filters exclude everything.

```
    No results match your filters
    Try adjusting your search or filters
    [Clear all filters]
```

- Heading: why it's empty
- Description: how to fix it
- CTA: clear filters / adjust search

---

## Rules

- Both types are visually similar but have different copy and CTA
- Data-table uses named templates for this: `{table}-empty`, `{table}-empty-filtered`
- For standalone lists — same pattern, HTML rendered by backend
- Not a JS component — HTML template + CSS styling
- Icon above heading is optional, not required

---

## Anti-Patterns

- **Same message for both types** — "no data" and "filter returned zero" need different guidance
- **Empty state without CTA** — always give the user a next step
- **Technical language** — "No records found" → "No documents yet"
