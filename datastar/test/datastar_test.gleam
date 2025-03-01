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

  dt.merge_fragments("<span>1</span>")
  |> dt.merge_fragments_close
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

  dt.merge_fragments(fragments: "<span>1</span>")
  |> dt.merge_fragments_w_id("123")
  |> dt.merge_fragments_w_merge_mode(dt.Inner)
  |> dt.merge_fragments_w_retry(2000)
  |> dt.merge_fragments_w_selector("#feed")
  |> dt.merge_fragments_w_settle_duration(10)
  |> dt.merge_fragments_w_view_transition(True)
  |> dt.merge_fragments_close
  |> dt.event_to_string
  |> should.equal(expected)
}

pub fn remove_fragments_minimal_test() {
  let expected =
    "event: datastar-remove-fragments
data: selector #target
"

  dt.remove_fragments("#target")
  |> dt.remove_fragments_close
  |> dt.event_to_string
  |> should.equal(expected)
}

pub fn remove_fragments_maximal_test() {
  let expected =
    "event: datastar-remove-fragments
id: 123
retry: 2000
data: selector #target
data: settleDuration 500
data: useViewTransition true
"

  dt.remove_fragments("#target")
  |> dt.remove_fragments_w_id("123")
  |> dt.remove_fragments_w_retry(2000)
  |> dt.remove_fragments_w_settle_duration(500)
  |> dt.remove_fragments_w_view_transition(True)
  |> dt.remove_fragments_close
  |> dt.event_to_string
  |> should.equal(expected)
}

pub fn merge_signals_minimal_test() {
  let expected =
    "event: datastar-merge-signals
data: signals {\"output\":\"Output Test\"}
"

  dt.merge_signals("{\"output\":\"Output Test\"}")
  |> dt.merge_signals_close
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

  dt.merge_signals("{\"output\":\"Output Test\"}")
  |> dt.merge_signals_w_id("123")
  |> dt.merge_signals_w_only_if_missing(True)
  |> dt.merge_signals_w_retry(2000)
  |> dt.merge_signals_close
  |> dt.event_to_string
  |> should.equal(expected)
}

pub fn remove_signals_minimal_test() {
  let expected =
    "event: datastar-remove-signals
data: paths user.name
data: paths user.email
"

  dt.remove_signals(["user.name", "user.email"])
  |> dt.remove_signals_close
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

  dt.remove_signals(["user.name", "user.email"])
  |> dt.remove_signals_w_id("123")
  |> dt.remove_signals_w_retry(2000)
  |> dt.remove_signals_close
  |> dt.event_to_string
  |> should.equal(expected)
}

pub fn execute_script_minimal_test() {
  let expected =
    "event: datastar-execute-script
data: script window.location = \"https://data-star.dev\"
"

  dt.execute_script("window.location = \"https://data-star.dev\"")
  |> dt.execute_script_close
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

  dt.execute_script("window.location = \"https://data-star.dev\"")
  |> dt.execute_script_w_id("123")
  |> dt.execute_script_w_retry(2000)
  |> dt.execute_script_auto_remove(False)
  |> dt.execute_script_attributes([#("type", "text/javascript")])
  |> dt.execute_script_close
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
    dt.merge_fragments("<span>1</span>") |> dt.merge_fragments_close,
    dt.remove_fragments("#id2") |> dt.remove_fragments_close,
  ]
  |> dt.events_to_string
  |> should.equal(expected)
}
