# ln-ashlar — Loading State Implementation

> For WHAT loading states must have → global ui/components/loading-state.md.

## Philosophy

ln-ashlar consumers are SSR-first: the server returns ready markup with real data on every navigation. SSR-first views carry no placeholder / shimmer rows, no skeleton blocks — use the spinner or button-busy state below for async form submission or background refresh.

Data-driven / windowed views (client-fetched pages, cold-cache client-cache mode) are the exception: `ln-table`/`ln-list` render a placeholder row per not-yet-cached logical index while scrolling ahead of the fetch. Their sanctioned affordance is a static token fill (`--bg-sunken`), row-height chrome only. Shimmer stays forbidden everywhere, including here.

## Spinner

```scss
.my-spinner { @include loader; }
```

The default CSS binding is the `.loader` class (`theme/components/_loader.scss`). No JS — pure CSS spinner.

## Button Loading

Coordinator toggles `aria-busy="true"` and `disabled` on submit button during request.
