# ln-ashlar — Loading State Implementation

> For WHAT loading states must have → global ui/components/loading-state.md.

## Philosophy

ln-ashlar consumers are SSR-first: the server returns ready markup with real data on every navigation. There are no placeholder / shimmer rows, no skeleton blocks. If a view genuinely needs a loading indicator (e.g. cold-cache client-cache mode, async form submission, background refresh), use the spinner or button-busy state below.

## Spinner

```scss
.my-spinner { @include loader; }
```

The default CSS binding is the `.loader` class (`scss/components/_loader.scss`). No JS — pure CSS spinner.

## Button Loading

Coordinator toggles `aria-busy="true"` and `disabled` on submit button during request.
