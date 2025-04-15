import datastar/ds_sse
import datastar/ds_wisp
import gleeunit/should
import wisp
import wisp/testing

// gleeunit test functions end in `_test`
pub fn send_test() {
  let events = [ds_sse.merge_fragments("<div />") |> ds_sse.merge_fragments_end]

  let response =
    wisp.ok()
    |> ds_wisp.send(events)

  let expected_headers = [
    #("cache-control", "no-cache"),
    #("content-type", "text/event-stream"),
  ]

  response.headers
  |> should.equal(expected_headers)

  response
  |> testing.string_body
  |> should.equal(
    "event: datastar-merge-fragments\ndata: fragments <div />\n\n",
  )
}
