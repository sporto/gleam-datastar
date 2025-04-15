import datastar/ds_sse
import wisp

pub fn send(response: wisp.Response, events: List(ds_sse.Event)) {
  let body = ds_sse.events_to_string(events)

  response
  |> wisp.string_body(body)
  |> wisp.set_header("Cache-Control", "no-cache")
  |> wisp.set_header("Content-Type", "text/event-stream")
}
