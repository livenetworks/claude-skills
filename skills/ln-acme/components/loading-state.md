# ln-acme — Loading State Implementation

> For WHAT loading states must have → global ui/components/loading-state.md.

## Philosophy

ln-acme consumers are SSR-first: the server returns ready markup with real data on every navigation. There are no placeholder / shimmer rows, no skeleton blocks. If a view genuinely needs a loading indicator (e.g. cold-cache client-cache mode, async form submission, background refresh), use the spinner or button-busy state below.

## Spinner

```scss
.my-spinner { @include loader; }
```

## Button Loading

Coordinator toggles `aria-busy="true"` and `disabled` on submit button during request.
