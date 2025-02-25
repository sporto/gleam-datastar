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

pub fn remove_fragments_minimal_test() {
  let expected =
    "event: datastar-remove-fragments
data: selector #target
"

  dt.remove_fragments("#target", [])
  |> dt.event_to_string
  |> should.equal(expected)
}

pub fn remove_fragments_maximal_test() {
  let expected =
    "event: datastar-remove-fragments
id: 123
retry: 2000
data: selector #target
data: settleDuration 200
data: useViewTransition true
"

  dt.remove_fragments("#target", [
    dt.event_id("123"),
    dt.retry(2000),
    dt.settle_duration(200),
    dt.view_transition(True),
  ])
  |> dt.event_to_string
  |> should.equal(expected)
}

pub fn merge_signals_minimal_test() {
  let expected =
    "event: datastar-merge-signals
data: signals {\"output\":\"Output Test\"}
"

  dt.merge_signals("{\"output\":\"Output Test\"}", [])
  |> dt.event_to_string
  |> should.equal(expected)
}

pub fn merge_signals_maximal_test() {
  let expected =
    "event: datastar-merge-signals
id: 123
retry: 2000
data: onlyIfMissing true
data: signals {\"output\":\"Output Test\"}
"

  dt.merge_signals("{\"output\":\"Output Test\"}", [
    dt.event_id("123"),
    dt.only_if_missing(True),
    dt.retry(2000),
  ])
  |> dt.event_to_string
  |> should.equal(expected)
}

pub fn event_has_empty_lines_test() {
  let expected =
    "event: datastar-merge-fragments
data: fragments <span>1</span>

event: datastar-remove-fragments
data: selector #id2

"

  [dt.merge_fragments("<span>1</span>", []), dt.remove_fragments("#id2", [])]
  |> dt.events_to_string
  |> should.equal(expected)
}
