# Prose

> Canonical docs: `docs/css/prose.md`
> Source: `scss/config/mixins/_prose.scss` + `scss/components/_prose.scss`

---

## Decision: when to use prose

`[data-ln-prose]` (or `@include prose`) is the scoped wrapper for arbitrary long-form HTML — TipTap output, Markdown renders, help articles, document body content. It applies typography rhythm using child selectors (`> * + * { margin-top: 1em }`).

**Do NOT apply globally.** Scoping it to a specific content block prevents the heading/list styles from leaking into form UIs or navigation elements.

---

## What it styles

| Element | Token |
|---|---|
| `h1` | `heading-lg`, `margin-top: 2em` |
| `h2` | `heading-md`, `margin-top: 1.5em` |
| `h3` | `heading-sm`, `margin-top: 1.25em` |
| `h4` | `title-md`, `margin-top: 1em` |
| `p` | `body-md` |
| `a` | Primary colour, underline, `text-underline-offset: 2px` |
| `ul` | `list-style: disc`, `padding-left: 1.5em` |
| `ol` | `list-style: decimal`, `padding-left: 1.5em` |
| `blockquote` | Primary left border (3px), italic, secondary text |
| `code` (inline) | Mono, `bg-secondary`, primary text color |
| `pre > code` | Code block, `bg-secondary`, rounded, `overflow-x: auto` |
| `img` | `max-width: 100%`, rounded-md |
| `figure / figcaption` | Caption typography, muted, centered |
| `table` | Collapse borders, `th` semibold |
| `hr` | 1px border, `margin: 2em 0` |

---

## Max width

`max-width: var(--max-w-prose)` — defaults to 65ch. Optimized for line length. Override per consumer if the layout provides its own width constraint.

---

## HTML pattern

```html
<article data-ln-prose>
	<h2>Introduction</h2>
	<p>Lorem ipsum dolor sit amet...</p>
	<ul>
		<li>Point one</li>
		<li>Point two</li>
	</ul>
	<blockquote>Key insight from the standard.</blockquote>
	<pre><code>code sample here</code></pre>
</article>
```

---

## Project usage

```scss
// Default selector via attribute — no extra CSS needed.
// For custom selectors:
#document-viewer { @include prose; }
#help-article    { @include prose; }
```
