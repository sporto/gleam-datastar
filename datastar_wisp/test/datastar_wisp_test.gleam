import datastar
import datastar_wisp
import gleeunit
import gleeunit/should
import wisp
import wisp/testing

pub fn main() {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn send_test() {
  let events = [datastar.event_merge_fragments("<div />", [])]

  let response =
    wisp.ok()
    |> datastar_wisp.send(events)

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
