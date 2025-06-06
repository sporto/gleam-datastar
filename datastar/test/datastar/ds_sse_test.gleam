import datastar/ds_sse
import gleam/json
import gleeunit/should

pub fn merge_fragments_minimal_test() {
  let expected =
    "event: datastar-merge-fragments
data: fragments <span>Hello</span>
"

  ds_sse.merge_fragments("<span>Hello</span>")
  |> ds_sse.merge_fragments_end
  |> ds_sse.event_to_string
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

  ds_sse.merge_fragments(fragments: "<span>1</span>")
  |> ds_sse.merge_fragments_event_id("123")
  |> ds_sse.merge_fragments_merge_mode(ds_sse.Inner)
  |> ds_sse.merge_fragments_retry(2000)
  |> ds_sse.merge_fragments_selector("#feed")
  |> ds_sse.merge_fragments_settle_duration(10)
  |> ds_sse.merge_fragments_view_transition(True)
  |> ds_sse.merge_fragments_end
  |> ds_sse.event_to_string
  |> should.equal(expected)
}

pub fn merge_fragments_defaults_test() {
  let expected =
    "event: datastar-merge-fragments
data: fragments <span>1</span>
"

  ds_sse.merge_fragments(fragments: "<span>1</span>")
  |> ds_sse.merge_fragments_merge_mode(ds_sse.Morph)
  |> ds_sse.merge_fragments_settle_duration(300)
  |> ds_sse.merge_fragments_view_transition(False)
  |> ds_sse.merge_fragments_end
  |> ds_sse.event_to_string
  |> should.equal(expected)
}

pub fn remove_fragments_minimal_test() {
  let expected =
    "event: datastar-remove-fragments
data: selector #target
"

  ds_sse.remove_fragments("#target")
  |> ds_sse.remove_fragments_end
  |> ds_sse.event_to_string
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

  ds_sse.remove_fragments("#target")
  |> ds_sse.remove_fragments_event_id("123")
  |> ds_sse.remove_fragments_retry(2000)
  |> ds_sse.remove_fragments_settle_duration(500)
  |> ds_sse.remove_fragments_view_transition(True)
  |> ds_sse.remove_fragments_end
  |> ds_sse.event_to_string
  |> should.equal(expected)
}

pub fn remove_fragments_defaults_test() {
  let expected =
    "event: datastar-remove-fragments
data: selector #target
"

  ds_sse.remove_fragments("#target")
  |> ds_sse.remove_fragments_settle_duration(300)
  |> ds_sse.remove_fragments_view_transition(False)
  |> ds_sse.remove_fragments_end
  |> ds_sse.event_to_string
  |> should.equal(expected)
}

pub fn merge_signals_minimal_test() {
  let expected =
    "event: datastar-merge-signals
data: signals {\"name\":\"sam\"}
"

  let json = json.object([#("name", json.string("sam"))])

  ds_sse.merge_signals(json)
  |> ds_sse.merge_signals_end
  |> ds_sse.event_to_string
  |> should.equal(expected)
}

pub fn merge_signals_maximal_test() {
  let expected =
    "event: datastar-merge-signals
id: 123
retry: 2000
data: onlyIfMissing true
data: signals {\"name\":\"sam\"}
"

  let json = json.object([#("name", json.string("sam"))])

  ds_sse.merge_signals(json)
  |> ds_sse.merge_signals_event_id("123")
  |> ds_sse.merge_signals_only_if_missing(True)
  |> ds_sse.merge_signals_retry(2000)
  |> ds_sse.merge_signals_end
  |> ds_sse.event_to_string
  |> should.equal(expected)
}

pub fn merge_signals_defaults_test() {
  let expected =
    "event: datastar-merge-signals
data: signals {\"name\":\"sam\"}
"

  let json = json.object([#("name", json.string("sam"))])

  ds_sse.merge_signals(json)
  |> ds_sse.merge_signals_only_if_missing(False)
  |> ds_sse.merge_signals_end
  |> ds_sse.event_to_string
  |> should.equal(expected)
}

pub fn remove_signals_minimal_test() {
  let expected =
    "event: datastar-remove-signals
data: paths user.name
data: paths user.email
"

  ds_sse.remove_signals(["user.name", "user.email"])
  |> ds_sse.remove_signals_end
  |> ds_sse.event_to_string
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

  ds_sse.remove_signals(["user.name", "user.email"])
  |> ds_sse.remove_signals_event_id("123")
  |> ds_sse.remove_signals_retry(2000)
  |> ds_sse.remove_signals_end
  |> ds_sse.event_to_string
  |> should.equal(expected)
}

pub fn execute_script_minimal_test() {
  let expected =
    "event: datastar-execute-script
data: script window.location = \"https://data-star.dev\"
"

  ds_sse.execute_script("window.location = \"https://data-star.dev\"")
  |> ds_sse.execute_script_end
  |> ds_sse.event_to_string
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

  ds_sse.execute_script("window.location = \"https://data-star.dev\"")
  |> ds_sse.execute_script_event_id("123")
  |> ds_sse.execute_script_retry(2000)
  |> ds_sse.execute_script_auto_remove(False)
  |> ds_sse.execute_script_attributes([#("type", "text/javascript")])
  |> ds_sse.execute_script_end
  |> ds_sse.event_to_string
  |> should.equal(expected)
}

pub fn execute_script_defaults_test() {
  let expected =
    "event: datastar-execute-script
data: script window.location = \"https://data-star.dev\"
"

  ds_sse.execute_script("window.location = \"https://data-star.dev\"")
  |> ds_sse.execute_script_auto_remove(True)
  |> ds_sse.execute_script_attributes([])
  |> ds_sse.execute_script_end
  |> ds_sse.event_to_string
  |> should.equal(expected)
}

pub fn event_has_empty_lines_test() {
  let expected =
    "event: datastar-merge-fragments
data: fragments <span>Hello</span>

event: datastar-remove-fragments
data: selector #id2

"

  [
    ds_sse.merge_fragments("<span>Hello</span>") |> ds_sse.merge_fragments_end,
    ds_sse.remove_fragments("#id2") |> ds_sse.remove_fragments_end,
  ]
  |> ds_sse.events_to_string
  |> should.equal(expected)
}

pub fn readme_example_test() {
  let expected =
    "event: datastar-remove-fragments
data: selector #error

event: datastar-merge-fragments
data: mergeMode inner
data: selector #notice
data: fragments <span>Hello</span>

"

  [
    ds_sse.remove_fragments("#error")
      |> ds_sse.remove_fragments_end,
    ds_sse.merge_fragments("<span>Hello</span>")
      |> ds_sse.merge_fragments_selector("#notice")
      |> ds_sse.merge_fragments_merge_mode(ds_sse.Inner)
      |> ds_sse.merge_fragments_end,
  ]
  |> ds_sse.events_to_string
  |> should.equal(expected)
}
