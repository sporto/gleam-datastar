# DataStar

[![Package Version](https://img.shields.io/hexpm/v/datastar)](https://hex.pm/packages/datastar)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/datastar/)

Gleam bindings for 🚀 <https://data-star.dev/>.

This library provides Gleam functions for building **server sent events (SSE)** in the backend to use with **Datastar**.

```sh
gleam add datastar
```

```gleam
import datastar/ds_sse

[
  ds_sse.patch_elements()
    |> ds_sse.patch_elements_selector("#error")
    |> ds_sse.patch_elements_merge_mode(ds_sse.Remove)
    |> ds_sse.patch_elements_end,
  ds_sse.patch_elements()
    |> ds_sse.patch_elements_elements("<span>Hello</span>")
    |> ds_sse.patch_elements_selector("#notice")
    |> ds_sse.patch_elements_merge_mode(ds_sse.Inner)
    |> ds_sse.patch_elements_end,
]
|> ds_sse.events_to_string
```

This generates:

```text
event: datastar-patch-elements
data: mode remove
data: selector #error

event: datastar-patch-elements
data: mode inner
data: selector #notice
data: elements <span>Hello</span>
```

API documentation at <https://hexdocs.pm/datastar>.

Datastar SSE reference <https://data-star.dev/reference/sse_events>.

To use this with **wisp**, see <https://hexdocs.pm/datastar_wisp>.
