# DataStar

[![Package Version](https://img.shields.io/hexpm/v/datastar)](https://hex.pm/packages/datastar)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/datastar/)

Gleam bindings for 🚀 <https://data-star.dev/>.

This library provides Gleam functions for building **server sent events (SSE)** in the backend to use with **Datastar**.

```gleam
[
  remove_fragments("#error")
  |> remove_fragments_end,
  merge_fragments("<span>Hello</span>")
  |> merge_fragments_selector("#notice")
  |> merge_fragments_merge_mode(Inner)
  |> merge_fragments_end,
]
|> events_to_string
```

This generates:

```text
event: datastar-remove-fragments
data: selector #error

event: datastar-merge-fragments
data: mergeMode inner
data: selector #notice
data: fragments <span>Hello</span>
```

API documentation at <https://hexdocs.pm/datastar>.

Datastar SSE reference <https://data-star.dev/reference/sse_events>.
