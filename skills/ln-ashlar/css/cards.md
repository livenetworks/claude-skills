# ln-ashlar — Cards Mixin Reference

Quick reference for card and panel mixins. Full source: `scss/config/mixins/_card.scss`.

---

## Core card variants

### `card`

Full card chrome: border, border-radius, `flex-col`, `overflow: hidden`, resting shadow,
hover border + floating shadow. Direct children `> header/main/footer` auto-get
`panel-header/panel-body/panel-footer`. Applied globally to `.card`.

Nesting ladder: `card` nested inside `section-card` or another `card` elevates its
background to `--bg-elevated` automatically.

```scss
#user-profile article { @include card; }
```

### `section-card`

Structural page section wrapper — border, radius, `overflow: clip` (allows sticky
`<thead>` inside), resting shadow, bottom margin. Applied globally to `.section-card`.

```scss
#users-panel { @include section-card; }
```

---

## Panel regions (applied inside card/section-card)

### `panel-header`

Flex row (space-between + center), `border-bottom`, sunken bg, card-padding.
Tightens button and label padding to align with a geometric height lock.
Applied globally to `.card > header`, `.section-card > header`.

### `panel-body`

Card padding. Auto-flushes padding and strips inner table radius/shadow when the
table is the only child (pure table card). Applied globally to `.card > main`,
`.section-card > main`.

### `panel-footer`

Card padding, `border-top`, sunken bg, `flex justify-end`. Applied globally to
`.card > footer`, `.section-card > footer`.

---

## Card accents

### `card-accent-top` / `card-accent-bottom` / `card-accent-left`

3px solid accent stripe. Reads `--color-accent` (default: `hsl(var(--color-primary))`).
Layer on top of `card`:

```scss
#featured-doc article {
	@include card;
	@include card-accent-top;
}
```

### `card-bg`

Translucent accent tint background (6%) + accent-tinted border (15%).
Use for highlighted/selected card state — no border stripe.

### `card-stacked`

Visual depth illusion via `::after` pseudo-element shadow card below. Gives the
appearance of a stack of documents.

---

## Floating panels

### `floating-panel`

Chrome for floating overlays: elevated bg, subtle border (SOFT per-side tokens),
floating shadow, `z-index: var(--z-dropdown)`. The visual shell for dropdowns,
popovers, and menus.

```scss
[data-ln-dropdown-menu] { @include floating-panel; @include menu-items; }
```

---

## Card field list

### `card-field-list`

Parent-scope mixin. Styles `.field` rows (`.label` + `.value`) as a bordered
label/value list inside a card body. Separator between rows; none after last row.

```scss
#user-detail-card > main { @include card-field-list; }
```

HTML structure expected:
```html
<main>
	<div class="field">
		<span class="label">Name</span>
		<span class="value">Marko</span>
	</div>
</main>
```

---

## Section (standalone)

### `section`

Margin-bottom + bottom-padded header (`h2`, `.section-actions`). For page sections
that don't need a card border — just spacing and a titled block.

```scss
#dashboard-stats { @include section; }
```
