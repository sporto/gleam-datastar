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

  dt.event_merge_fragments(fragments: "<span>1</span>", options: [])
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

  dt.event_merge_fragments(fragments: "<span>1</span>", options: [
    dt.data_merge_mode(dt.Inner),
    dt.data_view_transition(True),
    dt.data_selector("#feed"),
    dt.event_id("123"),
    dt.retry(2000),
    dt.data_settle_duration(10),
  ])
  |> dt.event_to_string
  |> should.equal(expected)
}

pub fn remove_fragments_minimal_test() {
  let expected =
    "event: datastar-remove-fragments
data: selector #target
"

  dt.event_remove_fragments("#target", [])
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

  dt.event_remove_fragments("#target", [
    dt.event_id("123"),
    dt.retry(2000),
    dt.data_settle_duration(200),
    dt.data_view_transition(True),
  ])
  |> dt.event_to_string
  |> should.equal(expected)
}

pub fn merge_signals_minimal_test() {
  let expected =
    "event: datastar-merge-signals
data: signals {\"output\":\"Output Test\"}
"

  dt.event_merge_signals("{\"output\":\"Output Test\"}", [])
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

  dt.event_merge_signals("{\"output\":\"Output Test\"}", [
    dt.event_id("123"),
    dt.data_only_if_missing(True),
    dt.retry(2000),
  ])
  |> dt.event_to_string
  |> should.equal(expected)
}

pub fn remove_signals_minimal_test() {
  let expected =
    "event: datastar-remove-signals
data: paths user.name
data: paths user.email
"

  dt.event_remove_signals(["user.name", "user.email"], [])
  |> dt.event_to_string
  |> should.equal(expected)
}

pub fn remove_signals_maximal_test() {
  let expected =
    "event: datastar-remove-signals
id: 123
retry: 2000
data: paths user.name
data: paths user.email
"

  dt.event_remove_signals(["user.name", "user.email"], [
    dt.event_id("123"),
    dt.retry(2000),
  ])
  |> dt.event_to_string
  |> should.equal(expected)
}

pub fn execute_script_minimal_test() {
  let expected =
    "event: datastar-execute-script
data: script window.location = \"https://data-star.dev\"
"

  dt.event_execute_script("window.location = \"https://data-star.dev\"", [])
  |> dt.event_to_string
  |> should.equal(expected)
}

pub fn execute_script_maximal_test() {
  let expected =
    "event: datastar-execute-script
id: 123
retry: 2000
data: autoRemove false
data: attributes type text/javascript
data: script window.location = \"https://data-star.dev\"
"

  dt.event_execute_script("window.location = \"https://data-star.dev\"", [
    dt.event_id("123"),
    dt.retry(2000),
    dt.data_auto_remove(False),
    dt.data_attributes([#("type", "text/javascript")]),
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

  [
    dt.event_merge_fragments("<span>1</span>", []),
    dt.event_remove_fragments("#id2", []),
  ]
  |> dt.events_to_string
  |> should.equal(expected)
}
