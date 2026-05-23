# Pills & Switches Skill Guide

> Canonical docs: `docs/css/toggles-and-pills.md`
> Source: `scss/config/mixins/_form.scss` + `scss/components/_form.scss`

---

## Decision Matrix: When to use which control?

| Control | Visual Style | Use Case | Action / Submission |
|---|---|---|---|
| **Filled Pill** | Horizontal joined tabs | Filtering lists, category selections, quick-switch tabs | **Grouped**: Acts as a checkbox/radio list, usually submitted together |
| **Outline Pill** | Horizontal joined outline | Choice tags, optional methods, standalone toggling | **Deferred**: Value submitted as part of a form, input icon remains visible |
| **Switch Pill** | iOS sliding switch stack | Settings, preferences, theme toggling, feature flags | **Immediate / Deferred**: Standard list item settings stacked vertically |

---

## Symmetric HTML Structure Rule

Always structure Filled, Outline, and Switch Pills with the exact same clean, nested layout. Do not write nested `id` / `for` attributes, no wrapper `div`s, and no classes on inner labels/inputs:

```html
<ul class="[pills|pills-outline|pills-switch]">
	<li>
		<label>
			<input type="[checkbox|radio]" name="..." value="..." [checked]>
			Label Text
		</label>
	</li>
</ul>
```

---

## 1. Filled Pills (Joined Group)

Applied to horizontal segmented selection bars using the `.pills` class on the container `<ul>` element.

### HTML Structure
```html
<ul class="pills">
	<li>
		<label>
			<input type="radio" name="role" value="admin" checked>
			Admin
		</label>
	</li>
	<li>
		<label>
			<input type="radio" name="role" value="employee">
			Employee
		</label>
	</li>
</ul>
```

### SCSS Mixin
```scss
.my-pills-selector {
	@include pills;
}
```

---

## 2. Outline Pills

Applied to horizontal outline segmented selection bars using the `.pills-outline` class, or as individual options using `.pill-outline` on a standalone `<label>`.

### Grouped HTML Structure
```html
<ul class="pills-outline">
	<li>
		<label>
			<input type="checkbox" name="options[]" value="notify" checked>
			Notifications
		</label>
	</li>
	<li>
		<label>
			<input type="checkbox" name="options[]" value="2fa">
			Two-factor Auth
		</label>
	</li>
</ul>
```

### Standalone Option Structure
```html
<label class="pill-outline">
	<input type="checkbox" name="advanced" checked>
	Advanced Options
</label>
```

### SCSS Mixins
```scss
// Group
.my-outline-selector {
	@include pills-outline;
}

// Standalone
.my-standalone-option {
	@include pill-outline;
}
```

---

## 3. Switch Pills (iOS Toggle Switches)

Applied to settings stacks using the `.pills-switch` class on the container `<ul>` element, or as individual toggle switches using `.pill-switch` on a standalone `<label>`.

### Grouped HTML Structure
```html
<ul class="pills-switch">
	<li>
		<label>
			<input type="checkbox" name="settings-email" checked>
			Email notifications
		</label>
	</li>
	<li>
		<label>
			<input type="checkbox" name="settings-sms">
			SMS alerts
		</label>
	</li>
</ul>
```

### Standalone Option Structure
```html
<label class="pill-switch">
	<input type="checkbox" name="advanced-analytics" checked>
	Advanced Analytics Reporting
</label>
```

### SCSS Mixins
```scss
// Stack
.my-settings-stack {
	@include pills-switch;
}

// Standalone
.my-standalone-switch {
	@include pill-switch;
}
```

---

## Directives for AI Assistants

1. **Pure Tab Indentation**: All SCSS, HTML, and Markdown code blocks written for these components must use tab-based indentation.
2. **No Data Attributes for Styling**: Do not add custom attributes (like `data-demo-settings-form`) to style layouts. Styling must be driven exclusively via classes.
3. **No fieldset dependencies**: Do not rely on `<fieldset>` direct child selectors for styling. Always use class-based mappings (`.pills`, `.pills-outline`, `.pills-switch`).
