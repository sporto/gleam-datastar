import datastar as dt
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn merge_fragments_minimal_test() {
  let expected =
    "event: datastar-merge-fragments
data: fragments <span>1</span>
"

  dt.merge_fragments(fragments: "<span>1</span>", options: [])
  |> dt.event_to_string
  |> should.equal(expected)
}

pub fn merge_fragments_maximal_test() {
  let expected =
    "event: datastar-merge-fragments
id: 123
retry: 2000
data: mergeMode inner
data: selector #feed
data: settleDuration 10
data: useViewTransition true
data: fragments <span>1</span>
"

  dt.merge_fragments(fragments: "<span>1</span>", options: [
    dt.merge_mode(dt.Inner),
    dt.view_transition(True),
    dt.selector("#feed"),
    dt.event_id("123"),
    dt.retry(2000),
    dt.settle_duration(10),
  ])
  |> dt.event_to_string
  |> should.equal(expected)
}

pub fn event_has_empty_lines_test() {
  let expected =
    "event: datastar-remove-fragments
data: selector #id1

event: datastar-remove-fragments
data: selector #id2

"

  [dt.remove_fragments("#id1", []), dt.remove_fragments("#id2", [])]
  |> dt.events_to_string
  |> should.equal(expected)
}
