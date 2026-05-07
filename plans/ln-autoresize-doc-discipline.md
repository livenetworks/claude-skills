# Doc-discipline pass — ln-autoresize

> Scope: `js/ln-autoresize/README.md` + `docs/js/autoresize.md` only.
> Source (`js/ln-autoresize/ln-autoresize.js`, 47 lines), the (non-existent)
> co-located CSS, and `demo/admin/autoresize.html` are UNTOUCHED.

## Source-contract verification (executor: do not change source)

Confirmed by reading `js/ln-autoresize/ln-autoresize.js`:

- Single attribute: `data-ln-autoresize` on `<textarea>`. Presence creates
  the instance and runs the initial `_resize`. No attribute value contract
  (no "open"/"close" alphabet).
- Constructor stores `dom`, binds `_onInput`, attaches the `input`
  listener, runs initial `_resize`. Validates `tagName === 'TEXTAREA'`
  with a `console.warn` + early `return this` otherwise.
- `_resize` is the two-step (`style.height = 'auto'` → read
  `scrollHeight` → `style.height = scrollHeight + 'px'`).
- `destroy` is the only public mutator besides `_resize`: removes the
  listener, clears inline `style.height`, deletes `dom[DOM_ATTRIBUTE]`.
  Idempotency guard `if (!this.dom[DOM_ATTRIBUTE]) return`.
- Init pipeline is delegated to shared `registerComponent`. No
  per-component MutationObserver code.
- No custom events dispatched, no listeners besides `input`.
- No `_init`, no `setAttribute('data-ln-autoresize', …)` mutator path
  beyond presence/absence — the attribute is a boolean marker, not a
  state alphabet.

**Attribute-first vs imperative-first framing (skill §8).** The attribute
*is* the entire contract; there is no JS state mutator at all (`_resize`
is a re-measure, not a state setter; `destroy` is teardown, not a write).
The README already leads with the attribute. No flip needed; just keep
it that way and remove the imperative-side prose drift in §API.

**No source bugs surfaced.** All audit findings are doc-only.

## Benchmarks for context (no targets-as-quotas)

| Component | README | docs/js |
|---|---|---|
| ln-tabs | ~215-230 (post-pass) | ~310-325 (post-pass) |
| ln-toggle | 164 | 541 |
| ln-modal | 269 | 288 |
| ln-accordion | 414 | 264 |
| **ln-autoresize (current)** | **433** | **238** |

The component contract is tiny (one attribute, one event listener, one
visual behaviour). README at 433 lines is ~3× what the contract warrants.
docs/js at 238 is closer to right-sized but has its own drift to trim.

## Audit findings — README.md (currently 433 lines)

### R1. Tagline includes a line-count brag (rule §4 drift bait)

Current lines 1–4:

```
# ln-autoresize

> A `<textarea>` whose height tracks its content — set the attribute, the
> field grows as the user types and shrinks when text is deleted. 47 lines
> of JS that exist so no project ever writes them again.
```

The "47 lines of JS that exist so no project ever writes them again" half
is rule §4 — "X-line component" bragging is drift bait (any source change
makes this wrong). The rest of the tagline is good — one sentence stating
the contract.

**Edit.** Replace lines 1–4 with:

```
# ln-autoresize

> A `<textarea>` whose height tracks its content — set the attribute,
> the field grows as the user types and shrinks when text is deleted.
```

### R2. §Philosophy is bloated — drop the "What this component does NOT do" list entirely; trim the prose to two paragraphs

Current lines 6–58 (~52 lines). Structure:

- Paragraph 1 (lines 8–19): "The browser does not auto-size … so
  ln-autoresize is the canonical version." Rationale + contract — keep
  but tighten.
- Paragraph 2 (lines 21–29): "The component does one trick that
  matters … no visible flash." The two-step explanation. Keep tightened
  — the two-step IS the architectural insight worth surfacing here.
- Lines 31–58: "What this component does **not** do:" five-bullet list
  covering rows-shrinking, min/max-height, lnForm.reset re-measure,
  programmatic .value re-measure, and visual-styling ownership.

The bullet list is the worst double-coverage offender in the file:

- Bullet 1 ("does not shrink to fit `rows`") is covered by §Markup
  anatomy → "rows='1'" sub-section AND by §Common mistakes 2.
- Bullet 2 ("does not enforce min/max-height") is covered by §Markup
  anatomy → "Pairing with max-height" sub-section.
- Bullet 3 ("Re-measures on lnForm.reset()") is covered by §Examples →
  "Reset inside [data-ln-form]" AND §Common mistakes 4 AND
  `docs/js/autoresize.md` §Cross-component coordination.
- Bullet 4 ("Does not re-measure when .value is set programmatically")
  is covered by §Examples → "Inside [data-ln-form] with fill" AND
  §Common mistakes 1.
- Bullet 5 ("Does not own visual styling") — true but trivial; the
  component is a JS instance, of course it doesn't own SCSS.

Per skill §3 (no double-coverage) and §1 (no speculative edge cases) —
the list is pure drift accumulation. The two paragraphs of prose contain
the contract; the list belongs nowhere in this README.

**Edit.** Replace the entire §Philosophy body (lines 8–58) with:

```
The browser does not auto-size `<textarea>`. Every project that wants
growing comment fields, note inputs, or chat composers ends up writing
the same five lines: listen for `input`, set `height` to `auto`, read
`scrollHeight`, set `height` to that. The five lines are easy to write
and hard to write *right* — the naive version flickers on every
keystroke, miscounts when the textarea inherits a fixed `rows`, drifts
across font loads, and silently breaks if anyone hides the parent.
`ln-autoresize` is the canonical version, and that is the entire
feature surface — no resize sensor, no "max-rows" config, no "shrink
gracefully" mode.

The trick that matters: to make the textarea shrink as well as grow,
the height has to be reset to `auto` *before* `scrollHeight` is read —
otherwise the previous tall height keeps `scrollHeight` pinned and the
textarea never collapses. Browsers reflow synchronously inside the
single function call, so the user only ever sees the final height.
```

That is the entire §Philosophy body — two paragraphs, ~14 lines. Drops
~38 lines of bullets that are covered elsewhere.

### R3. §Markup anatomy is too long — compress to a tight contract block

Current lines 60–117 (~57 lines). Sub-structure:

- Lines 62–70: contract statement + `<textarea data-ln-autoresize rows="1" …>` snippet. Keep.
- Lines 72–81 (### `rows="1"` — initial height before JS runs): two-paragraph essay on snap-shut behaviour. Demo's §Anatomy section already covers this. Compress to one sentence.
- Lines 83–103 (### Pairing with `max-height` for capped growth): code snippet + 2 paragraphs explaining `resize: none`, `max-height`, `overflow-y: auto`. Demo §Anatomy → "Pairing with CSS for capped growth" duplicates this verbatim. Compress to the snippet + one sentence.
- Lines 105–117 (### What state goes where): table + paragraph. The table is genuine value (consumer-facing "where does each concern live") — keep. The trailing paragraph "Inline `style.height` is the only thing the component writes…" duplicates the table's "Current height" row — drop.

**Edit.** Replace lines 60–117 with:

```
## Markup anatomy

The complete invocation. There is no markup contract beyond this:

```html
<textarea data-ln-autoresize rows="1" placeholder="Notes..."></textarea>
```

The element MUST be a `<textarea>`; the component logs a warning and
bails on anything else. The attribute takes no value — its presence
creates the instance.

`rows="1"` is the *initial* render height before JS attaches. Without
it, browsers default to `rows="2"` and the textarea snaps shut on first
paint when the initial `_resize` runs. `rows` is NOT a "max rows" cap —
once the inline `style.height` is written, it overrides `rows` for the
lifetime of the instance.

To cap growth at a ceiling and scroll past it, pair the attribute with
CSS `max-height` and `overflow-y: auto`:

```scss
textarea[data-ln-autoresize] {
    resize: none;
    max-height: 6rem;
    overflow-y: auto;
}
```

`resize: none` removes the manual drag handle (the global
`@mixin form-textarea` ships `resize: vertical` by default — the manual
handle and auto-grow are the same affordance done two different ways
and they fight each other).

### What state goes where

| Concern | Lives on | Owned by |
|---|---|---|
| Should this textarea auto-size? | `data-ln-autoresize` (presence) | `ln-autoresize` |
| Current height | `style.height` (inline) | `ln-autoresize` (writes after `input` and on construct) |
| Maximum height | CSS `max-height` on the selector | Project SCSS |
| Minimum height | CSS `min-height` on the selector | Project SCSS |
| Initial height before JS | `rows` attribute | Browser layout |
```

Net: drops ~30 lines while keeping the anatomy contract intact.

### R4. §States & visual feedback — drop entirely

Current lines 119–131 (13 lines). The lead sentence says "There is no
'resize state'" — the section's first claim contradicts its own
existence as a "States & visual feedback" heading. The four-row table
that follows describes JS triggers and what they do, which is
mechanism, not state. The closing line "There are no JS-driven
classes…" is a non-feature claim per rule §1.

For a component with no state alphabet, a §States section is rule §1
(speculative — describes scenarios consumers don't ask about) and
rule §6 (drift bait — what is "trigger" supposed to teach a consumer
that §Markup anatomy hasn't already taught?).

**Edit.** Delete the entire `## States & visual feedback` heading and
body (lines 119–131).

### R5. §Attributes — keep, but trim trailing prose paragraph

Current lines 133–142.

- Lines 133–137 (heading + table): Single-row table with one attribute. Keep.
- Lines 139–142 (paragraph): "`rows`, `placeholder`, `id`, `name`, `required`, `maxlength`, etc. are all native textarea attributes — ln-autoresize does not read or write any of them. … Width is whatever CSS the project applies; the component is purely a height controller." — speculative scope-bracketing per rule §1. Consumers do not arrive at the §Attributes section to learn that native textarea attributes are native. Drop.

**Edit.** Delete lines 139–142 entirely. Keep the heading and the table.

### R6. §Events — drop entirely

Current lines 144–153 (10 lines). The component dispatches no events
and listens to one platform event. The section currently exists to say
"there are no events." Per rule §1 (no speculative edge cases) and
rule §3 (no double-coverage — `docs/js/autoresize.md` already says this
under §Position in the architecture), drop the section.

**Edit.** Delete the entire `## Events` heading and body (lines
144–153).

### R7. §API — compress to the table; drop the prose drift

Current lines 155–176. Sub-structure:

- Lines 157–162 (paragraph + `window.lnAutoresize(root)` description): the "global MutationObserver already covers AJAX inserts" sentence is true but covered by `docs/js/autoresize.md` §MutationObserver via registerComponent. Pointer rather than re-explanation.
- Lines 164–169 (table): three rows — `dom`, `_resize()`, `destroy()`. Keep. Tighten the destroy row (drops the "(DOM-state remains for the user to clean up if they want)" tail — covered by rule §4).
- Lines 171–176 (paragraph on `_resize` underscore convention): rule §1 — speculative meta-prose about a naming convention. Drop.

**Edit.** Replace lines 155–176 with:

```
## API (component instance)

`el.lnAutoresize` on a DOM element exposes:

| Property | Type | Description |
|---|---|---|
| `dom` | `HTMLTextAreaElement` | Back-reference to the textarea |
| `_resize()` | method | Force a re-measure. Use after programmatic `.value` writes, after revealing a hidden parent, or after a font load completes. |
| `destroy()` | method | Remove the `input` listener and clear inline `style.height`. The `data-ln-autoresize` attribute is left in place. |

`window.lnAutoresize(root)` re-runs the init scan over `root` — only
needed for Shadow DOM / iframe roots that the global `MutationObserver`
cannot see. Live document inserts are picked up automatically; see
[`docs/js/autoresize.md`](../../docs/js/autoresize.md#mutationobserver-via-registercomponent).
```

### R8. §Examples — keep three canonical, drop four that duplicate the demo

Current lines 178–308 (~130 lines). Seven examples:

1. **Minimal — basic auto-grow** (180–190): canonical 1-line example. Keep.
2. **With max-height cap and scrolling** (192–207): keep — pairs with R3's anatomy table on `max-height`.
3. **Pre-filled content (server-rendered)** (209–218): the contract here is "constructor calls `_resize` once before returning." Keep — non-obvious.
4. **Inside `[data-ln-form]` with fill** (220–243): canonical coordinator path for programmatic value writes. Keep — this is the supported answer to "how do I set the value and have height update."
5. **Reset inside `<form data-ln-form>` — works automatically** (245–274): demo has this exact example interactively. README is teaching the same lesson twice. Drop — covered by demo + `docs/js/autoresize.md` §Cross-component coordination + §Common mistakes 4.
6. **Dynamically inserted textareas** (276–290): rule §3 — covered by demo's §Example "Dynamically inserted textareas" + `docs/js/autoresize.md` §MutationObserver via registerComponent. Drop.
7. **Hidden-then-revealed (collapsed nav, lazy tab)** (292–308): rule §3 — covered by demo + §Common mistakes 3 + `docs/js/autoresize.md` §Initial resize. Drop the example block; the §Common mistakes 3 entry already gives the workaround.

**Edit.** Drop examples 5, 6, 7 entirely. After R8 lands, §Examples
contains: Minimal → Capped+scroll → Pre-filled → Inside [data-ln-form]
with fill. Four examples, ~60 lines.

### R9. §Common mistakes — keep but compress mistakes 1, 4 to remove now-redundant prose; drop mistake 5

Current lines 310–415 (~105 lines). Audit:

- **Mistake 1** ("Setting `.value` directly"): canonical and useful — the most common autoresize foot-gun. Keep but compress the prose intro from two paragraphs + two snippets to one paragraph + one snippet showing the fix.
- **Mistake 2** ("Using `rows` as a 'max rows' cap"): canonical. Keep.
- **Mistake 3** ("Adding `data-ln-autoresize` to a hidden parent"): canonical. Keep.
- **Mistake 4** ("Bare `<button type='reset'>` outside `[data-ln-form]`"): canonical foot-gun. Keep, but the two-fix structure ("1. Add `data-ln-form` and replace the button. 2. If you cannot use `data-ln-form`, dispatch input manually…") expands to two code blocks. Compress to one fix (the lnForm path) + a one-sentence pointer for the manual fallback. After R8 drops the §Examples version, §Common mistakes is the ONLY home for this guidance, so keep both fixes — but compress.
- **Mistake 5** ("Applying `data-ln-autoresize` to something other than a `<textarea>`"): rule §1 — describes a scenario consumers don't actually attempt (and which is caught by `console.warn` immediately on dev iteration). The component validates and warns; that is the contract; consumers don't need a §Common mistakes entry teaching them not to do something the source actively rejects. Drop.
- **Mistake 6** ("Forgetting to override `resize: vertical`"): canonical. Keep.

**Edit.** Apply per-mistake trims:

- Mistake 1 — replace lines 312–328 (the body) with:

```
### Mistake 1 — Setting `.value` directly and expecting the height to update

Setting `.value` programmatically does not fire `input`, so
`ln-autoresize`'s listener never runs. Either dispatch the event
yourself or use `[data-ln-form]`'s `ln-form:fill`.

```js
const ta = document.querySelector('[data-ln-autoresize]');
ta.value = longString;
ta.dispatchEvent(new Event('input'));
```
```

- Mistake 4 — replace lines 358–386 with:

```
### Mistake 4 — Bare `<button type="reset">` outside `[data-ln-form]` leaves the height stuck

Native `reset` clears values but does not fire `input`, so the height
stays tall. Two fixes:

1. **Wrap the form in `data-ln-form`** and call `form.lnForm.reset()` —
   the API path dispatches synthetic `input` on every field, which
   `ln-autoresize` catches and uses to shrink. This is the supported
   path; see the §Examples block above.
2. **If `data-ln-form` is not an option**, dispatch `input` manually
   inside a `setTimeout` after the native `reset` event:

   ```js
   form.addEventListener('reset', function () {
       setTimeout(function () {
           form.querySelectorAll('[data-ln-autoresize]').forEach(function (ta) {
               ta.dispatchEvent(new Event('input'));
           });
       }, 0);
   });
   ```
```

(After R8 drops the §Examples "Reset inside `<form data-ln-form>`"
section, the back-link "see the §Examples block above" needs adjustment
— actually there will be no Reset example in §Examples post-R8. Edit
the back-link sentence to "see [`ln-form` README](../ln-form/README.md)
for the full `lnForm.reset()` contract.")

Final version of Mistake 4 (after the §Examples back-link fix):

```
### Mistake 4 — Bare `<button type="reset">` outside `[data-ln-form]` leaves the height stuck

Native `reset` clears values but does not fire `input`, so the height
stays tall. Two fixes:

1. **Wrap the form in `data-ln-form`** and call `form.lnForm.reset()` —
   the API path dispatches synthetic `input` on every field, which
   `ln-autoresize` catches and uses to shrink. See
   [`ln-form` README](../ln-form/README.md) for the `lnForm.reset()`
   contract.
2. **If `data-ln-form` is not an option**, dispatch `input` manually
   inside a `setTimeout` after the native `reset` event:

   ```js
   form.addEventListener('reset', function () {
       setTimeout(function () {
           form.querySelectorAll('[data-ln-autoresize]').forEach(function (ta) {
               ta.dispatchEvent(new Event('input'));
           });
       }, 0);
   });
   ```
```

- Mistake 5 — delete the entire `### Mistake 5 — Applying...` heading
  and body (lines 388–401).

- Mistake 6 — keep as-is. After Mistake 5 is gone, renumber Mistake 6
  to Mistake 5 to keep the list contiguous.

### R10. §Related — trim cross-component anti-pattern naming and the `data-flow.md` bullet

Current lines 417–433 (17 lines), four bullets:

- `@mixin form-textarea` bullet — keep; concrete useful pointer to the SCSS
  default that conflicts with autoresize.
- `@mixin form-input` bullet — drop. "Padding, border, focus ring used by
  every textarea regardless of autoresize" is generic SCSS-stack info that
  has nothing autoresize-specific. Rule §1.
- `ln-form` bullet — keep; concrete useful pointer to the supported
  programmatic-value-write path.
- "Architecture deep-dive" bullet — keep; standard footer.
- "Cross-component principles: data-flow.md … sits outside the four-layer
  data flow (it is a pure presentation utility — no events, no state, no
  data)" — rule §3 (already covered in `docs/js/autoresize.md` §Position
  in the architecture) and rule §2 (cross-architectural-doc framing dates
  fast). Drop.

**Edit.** Replace lines 417–433 with:

```
## Related

- **`@mixin form-textarea`** (`scss/config/mixins/_form.scss`) — the
  default textarea chrome (`min-height: 6rem`, `resize: vertical`).
  Override `resize` to `none` whenever you apply `data-ln-autoresize`.
- **[`ln-form`](../ln-form/README.md)** — the only library component
  that programmatically sets textarea values via a path that ALSO
  dispatches `input`. Use `ln-form:fill` instead of direct
  `.value =` writes whenever the textarea lives inside a
  `[data-ln-form]`.
- **Architecture deep-dive:** [`docs/js/autoresize.md`](../../docs/js/autoresize.md).
```

## Audit findings — docs/js/autoresize.md (currently 238 lines)

### D1. §Position in the architecture — keep, with one tweak

Current lines 9–24. The placement claim ("ln-autoresize is a pure
presentation utility … sits outside the four-layer data flow") is the
architectural value of opening this doc — keep.

The second paragraph "The reason it exists as a component rather than
a copy-paste snippet …" is borderline philosophy/historical (rule §6,
maybe rule §4). The paragraph does carry one architectural beat: "every
project would otherwise reinvent the two-step `auto → scrollHeight`
dance." That beat is in scope for an architecture doc — keep, but
tighten.

**Edit.** Replace lines 17–23 with:

```
The component exists as a centralisation: every project would otherwise
reinvent the two-step `auto → scrollHeight` dance, and most reinventions
ship with at least one of the bugs the canonical version avoids
(flicker, no-shrink, no initial measure).
```

(Drops the "observer leak" item — the component does not own a
MutationObserver, so "observer leak" was conceptual padding.)

### D2. §State — keep as-is

Lines 26–40. Clean architecture content. Two-row instance-state table
is the canonical reference. Keep.

### D3. §Resize mechanism — the two-step — keep as-is

Lines 42–68. The mechanism explanation is the architectural reason this
doc exists. Skill §"Don't trim protected sections" applies; the
§Lifecycle / §Mechanism sections of any architecture doc are protected.

### D4. §Why no requestAnimationFrame? — drop entirely

Current lines 70–86 (17 lines). This is rule §2 — naming an
alternative the component intentionally rejects. The "Why not rAF?"
question is not a frequent real-reader question; it is the contributor's
self-justification for not wrapping the resize call.

The architectural reason ("synchronous handler triggers forced layout
flush") is real and useful — it could be a one-line note inside §Resize
mechanism. But the existence of a dedicated 17-line "Why no rAF?" section
is anti-pattern naming on stilts.

**Edit.** Delete the entire `## Why no requestAnimationFrame?` heading
and body (lines 70–86). To preserve the one architectural beat worth
keeping, append one sentence to §Resize mechanism's closing paragraph:

Current `## Resize mechanism` closes at line 68 with: "The user sees
one transition: old height → new height. There is no flicker, no
`requestAnimationFrame`, no scheduled re-measure."

That last sentence already states the conclusion. After D4 lands, the
"no `requestAnimationFrame`, no scheduled re-measure" framing is the
total signal — the dropped section just elaborated. No further edit
needed; the §Resize mechanism closing line carries the residual claim.

### D5. §Initial resize — keep as-is

Lines 88–106. Canonical — covers the "constructor runs `_resize` once"
contract and the hidden-parent zero-height failure mode. Keep.

### D6. §MutationObserver via `registerComponent` — keep, with one tweak

Lines 108–129. The first paragraph (lines 109–112) describing the
`registerComponent` delegation is correct and architecturally useful.
The middle bullets (lines 114–122) describing the global observer's
config are accurate — keep.

The final paragraph (lines 124–129) about "no `onAttributeChange`
callback registered" is a contributor's-eye-view detail. Reading the
source, `registerComponent`'s `onAttributeChange` parameter genuinely
exists and genuinely is omitted by ln-autoresize — so this paragraph
is factually correct contributor information. Keep — that is the kind
of internals reference docs/js exists for (skill §3, "what an INTERNAL
reader / contributor needs").

### D7. §Tag validation — drop the post-warning-state speculation

Current lines 131–144. The first paragraph (lines 133–134) — "checks
`dom.tagName !== 'TEXTAREA'` immediately and, if true, logs a warning
and returns `this` early" — is the architectural fact. Keep.

The second paragraph (lines 136–144) describing the "neutered instance
… element is now marked as initialized even though the instance is
non-functional" is rule §1 (speculative edge case — consumers do not
hit this; if they do, the warning surfaces it on first dev iteration)
combined with rule §4 (post-warning narrative — historical-feeling
prose explaining why a corner case isn't a bug).

**Edit.** Replace lines 136–144 with:

```
The early-`return this` produces an instance with no `dom` property
and no listener. The element is still marked as initialized via
`element[DOM_ATTRIBUTE]`, so re-attaching `data-ln-autoresize` after
swapping to a real `<textarea>` will not re-init — the developer must
remove and re-add the attribute (or call `destroy()`) to recover.
```

(One-paragraph factual note replacing the multi-paragraph
"is-this-a-bug" narrative.)

### D8. §Destroy lifecycle — drop the line citation, keep the rest

Current lines 146–166. The lead sentence (line 148) cites
"`js/ln-autoresize/ln-autoresize.js` lines 37–42." Per rule §5 — line
citations drift on every refactor. Drop the citation; readers can grep.

The three numbered steps (lines 150–160) and the closing paragraph
about the attribute being preserved (lines 162–166) are accurate
architecture content — keep.

**Edit.** Replace line 148 with:

```
Three steps (see the `destroy` prototype in `ln-autoresize.js`):
```

### D9. §Cross-component coordination — keep, with one tightening

Lines 168–205. This is genuine architectural content — explains how
ln-autoresize works with ln-form's `fill()` and `reset()` paths. The
README's §Examples (after R8) keeps the "Inside [data-ln-form] with
fill" example but drops the reset example; this docs/js section is now
the sole home for the architectural detail of HOW ln-form synthesises
the `input` event. Keep.

One tightening: lines 197–203 (the "bare native path" paragraph)
already says everything the README §Common mistakes 4 says, in
architecture-flavoured prose. Per rule §3 — README §Common mistakes 4
is consumer-facing fix; docs/js §Cross-component coordination is the
architectural mechanism. The cross-link is useful but currently it
points at the README "Common mistakes" item by ordinal ("see README
'Common mistakes' item 4"). Ordinal references break when the list
changes; switch to section-relative wording.

**Edit.** Replace line 202–203:

```
must wire it manually (see README "Common mistakes" item 4) or
switch to the `lnForm.reset()` API path.
```

with:

```
must wire it manually (see the README's §Common mistakes section for
the `setTimeout`-after-native-`reset` fallback) or switch to the
`lnForm.reset()` API path.
```

### D10. §Performance notes — keep as-is

Lines 207–221. Concrete, accurate, and the kind of architecture content
that protects against speculative optimisation requests. Keep.

### D11. §Source map — drop entirely

Current lines 223–238 (16 lines). This is the maximal form of rule §5
drift bait — a verbatim line-by-line table mapping line numbers to
concerns. Any source change makes this wrong. The closing line "47
lines total" is also rule §4 (line-count brag).

The contributor value (which lines do what) is recoverable in seconds
by reading the 47-line source. The doc's existence is overhead that
the source's brevity already obviates.

**Edit.** Delete the entire `## Source map` heading and body (lines
223–238).

## Cross-doc consistency

After all edits land:

- **§Philosophy (README) ↔ §Position in the architecture (docs/js).**
  README's §Philosophy carries the consumer "why this exists + the
  two-step trick"; docs/js's §Position carries the architectural
  placement claim. No double coverage.
- **§Markup anatomy (README) ↔ §Resize mechanism (docs/js).** README
  teaches the contract (what to write, what attributes mean, what state
  goes where); docs/js teaches the mechanism (the two-step, why
  `auto`-then-`scrollHeight`). No double coverage.
- **§API (README) ↔ §Destroy lifecycle (docs/js).** README's
  three-row table is the consumer-facing API surface; docs/js
  §Destroy lifecycle is the internal mechanism. After R7, the
  README's destroy row is one sentence; docs/js's §Destroy lifecycle
  is the three-step internal walkthrough. Clean split.
- **§Common mistakes 1 (README) + §Examples "Inside [data-ln-form]
  with fill" (README) ↔ §Cross-component coordination (docs/js).**
  README addresses the consumer foot-gun and the supported path;
  docs/js explains the architectural mechanism (how ln-form
  synthesises `input`). No double coverage.
- **§Common mistakes 4 (README) ↔ §Cross-component coordination →
  reset paragraph (docs/js).** README gives the consumer fix
  (one-line `setTimeout` snippet); docs/js explains why the bare
  native `reset` path doesn't dispatch `input`. After D9's tweak,
  the cross-link is section-relative, not ordinal. No double coverage.
- **§Related (README) ↔ §Position in the architecture (docs/js).**
  After R10 drops the README's `data-flow.md` bullet, only docs/js
  references the architecture data-flow doc. Single source of truth.

## Acceptance-criteria greps (executor MUST run all)

Run from repository root.

### Negative checks (dead patterns gone)

1. **No "47 lines of JS" tagline brag in README** (R1):
   ```
   grep -n "47 lines of JS" js/ln-autoresize/README.md
   ```
   PASS = no output.

2. **No `## States & visual feedback` section in README** (R4):
   ```
   grep -n "^## States & visual feedback" js/ln-autoresize/README.md
   ```
   PASS = no output.

3. **No `## Events` section in README** (R6):
   ```
   grep -n "^## Events" js/ln-autoresize/README.md
   ```
   PASS = no output.

4. **No "Mistake 5 — Applying" section in README** (R9):
   ```
   grep -n "Mistake 5 — Applying\|other than a \`<textarea>\`" js/ln-autoresize/README.md
   ```
   PASS = no output.

5. **No `## Why no requestAnimationFrame?` section in docs/js** (D4):
   ```
   grep -n "^## Why no requestAnimationFrame" docs/js/autoresize.md
   ```
   PASS = no output.

6. **No `## Source map` section in docs/js** (D11):
   ```
   grep -n "^## Source map" docs/js/autoresize.md
   ```
   PASS = no output.

7. **No "What this component does **not** do" subsection in README** (R2):
   ```
   grep -n "What this component does \*\*not\*\* do" js/ln-autoresize/README.md
   ```
   PASS = no output.

### Positive checks (canonical content present)

8. **README tagline is one sentence** (R1) — confirm the new tagline lands without the line-count brag:
   ```
   grep -n "set the attribute, the\|the field grows as the user types and shrinks when text is deleted." js/ln-autoresize/README.md
   ```
   PASS = at least one hit, AND grep for "47 lines" in same file is empty (covered by check #1).

9. **README §API table row for `destroy` is the trimmed version** (R7):
   ```
   grep -n "The \`data-ln-autoresize\` attribute is left in place." js/ln-autoresize/README.md
   ```
   PASS = exactly one hit.

10. **docs/js §Destroy lifecycle no longer carries the line-citation** (D8):
    ```
    grep -n "lines 37–42\|lines 37-42" docs/js/autoresize.md
    ```
    PASS = no output.

### Source untouched

11. **Source files unchanged**:
    ```
    git diff --stat js/ln-autoresize/ln-autoresize.js demo/admin/autoresize.html
    ```
    PASS = no output (or "0 files changed"). (`ln-autoresize.scss` does
    not exist — confirmed by the source IIFE only importing
    `registerComponent` and there being no `.scss` file in the
    component directory.)

## Final line-count targets

These are derived from the audit (drops + compressions), NOT chosen to
hit a benchmark.

- **`js/ln-autoresize/README.md`** — current 433, target **~150–180**.
  Net change:
  - R1: −1 line (tagline brag dropped)
  - R2: ~−38 lines (Philosophy bullet list dropped, prose tightened)
  - R3: ~−30 lines (Markup anatomy compressed)
  - R4: −13 lines (States & visual feedback dropped)
  - R5: −4 lines (Attributes trailing prose dropped)
  - R6: −10 lines (Events section dropped)
  - R7: ~−15 lines (API prose drift dropped, table tightened)
  - R8: ~−70 lines (3 redundant examples dropped)
  - R9: ~−40 lines (Mistake 1 + 4 compressed, Mistake 5 dropped)
  - R10: ~−5 lines (Related trimmed)
  - Total: ~−225 to −250 lines.

- **`docs/js/autoresize.md`** — current 238, target **~180–200**. Net
  change:
  - D1: ~−4 lines (philosophy paragraph tightened)
  - D4: −17 lines (Why no rAF dropped)
  - D7: ~−5 lines (Tag-validation post-warning narrative compressed)
  - D8: 0 (line-citation removed; one-line replacement)
  - D9: 0 (wording tweak; same line count)
  - D11: −16 lines (Source map dropped)
  - Total: ~−40 to −45 lines.

If the executor lands within ±15 lines of these targets, that's PASS.
The README target range is wider than usual because the cumulative
trim is large (≥225 lines); landing at exactly 165 vs 175 vs 180 is
not the discipline question. Larger drift (e.g. README ending at 250+
or under 130) is a plan-estimation error to report, not a discipline
failure.

---

## Executor Prompt

You are running a doc-discipline pass on `ln-autoresize`. Touch ONLY two files:

- `/home/ashlar/ln-ashlar/js/ln-autoresize/README.md`
- `/home/ashlar/ln-ashlar/docs/js/autoresize.md`

Do NOT modify:

- `/home/ashlar/ln-ashlar/js/ln-autoresize/ln-autoresize.js`
- `/home/ashlar/ln-ashlar/js/ln-autoresize/ln-autoresize.scss` (does not exist; do not create)
- `/home/ashlar/ln-ashlar/demo/admin/autoresize.html`
- Any other component's docs.

This is a documentation tightening pass. No source changes, no demo
changes, no new sections — only trims and rephrases per the §Audit
findings above in this plan.

### Steps

1. **Read both target files end-to-end** before editing — line numbers
   in this plan are based on current state and may shift as you edit.
   Apply edits top-to-bottom in each file so later line numbers stay
   valid relative to YOUR current view.

2. **README.md edits** — apply R1 → R2 → R3 → R4 → R5 → R6 → R7 → R8
   → R9 → R10 in order. Each edit's exact replacement text is in the
   audit finding. Use the `Edit` tool with full-context `old_string`
   to avoid mismatches; if multiple instances exist, expand context.

3. **docs/js/autoresize.md edits** — apply D1 → D4 → D7 → D8 → D9 →
   D11 in order (D2, D3, D5, D6, D10 are leave-alone). Same `Edit`
   tool discipline.

4. **Run all 11 acceptance-criteria greps** from the §Acceptance-criteria
   greps section. Report PASS/FAIL for each one explicitly. Use the
   exact commands as written.

5. **Report final line counts**:
   ```
   wc -l /home/ashlar/ln-ashlar/js/ln-autoresize/README.md /home/ashlar/ln-ashlar/docs/js/autoresize.md
   ```
   State actual numbers vs the targets (~150–180 for README, ~180–200
   for docs/js).

6. **Confirm source untouched**:
   ```
   git diff --stat js/ln-autoresize/ln-autoresize.js demo/admin/autoresize.html
   ```
   Output should be empty / no changes. (`ln-autoresize.scss` does not
   exist — that's expected.)

### Reporting format

Return:

- One paragraph summary: "Applied N edits to README, M edits to
  docs/js. Net line change: README −X, docs/js −Y."
- Numbered grep results: "1. PASS — no output. 2. PASS — no output.
  ... 11. PASS — no output."
- Final line counts: "README: actual / target. docs/js: actual /
  target."
- Source-untouched confirmation: "git diff for source files: clean."
- Any deviations from the plan: explicit list. If any acceptance grep
  FAILS, STOP and report — do not paper over.

### Out-of-scope reminders

- Do not invent new sections.
- Do not restructure heading order.
- Do not "improve" prose outside the explicit edits in this plan —
  drift discipline cuts both ways.
- If you find a real bug in source while reading, FLAG it in your
  report; do NOT fix.
