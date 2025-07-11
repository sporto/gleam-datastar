import datastar/ds_sse
import gleam/json
import gleeunit/should

pub fn patch_elements_minimal_test() {
  let expected =
    "event: datastar-patch-elements
data: elements <span>Hello</span>
"

  ds_sse.patch_elements()
  |> ds_sse.patch_elements_elements("<span>Hello</span>")
  |> ds_sse.patch_elements_end
  |> ds_sse.event_to_string
  |> should.equal(expected)
}

pub fn patch_elements_maximal_test() {
  let expected =
    "event: datastar-patch-elements
id: 123
retry: 2000
data: mode inner
data: selector #feed
data: settleDuration 10
data: useViewTransition true
data: elements <span>1</span>
"

  ds_sse.patch_elements()
  |> ds_sse.patch_elements_elements("<span>1</span>")
  |> ds_sse.patch_elements_event_id("123")
  |> ds_sse.patch_elements_merge_mode(ds_sse.Inner)
  |> ds_sse.patch_elements_retry(2000)
  |> ds_sse.patch_elements_selector("#feed")
  |> ds_sse.patch_elements_settle_duration(10)
  |> ds_sse.patch_elements_view_transition(True)
  |> ds_sse.patch_elements_end
  |> ds_sse.event_to_string
  |> should.equal(expected)
}

pub fn patch_elements_defaults_test() {
  let expected =
    "event: datastar-patch-elements
data: elements <span>1</span>
"

  ds_sse.patch_elements()
  |> ds_sse.patch_elements_elements("<span>1</span>")
  |> ds_sse.patch_elements_merge_mode(ds_sse.Outer)
  |> ds_sse.patch_elements_settle_duration(300)
  |> ds_sse.patch_elements_view_transition(False)
  |> ds_sse.patch_elements_end
  |> ds_sse.event_to_string
  |> should.equal(expected)
}

pub fn patch_signals_minimal_test() {
  let expected =
    "event: datastar-patch-signals
data: signals {\"name\":\"sam\"}
"

  let json = json.object([#("name", json.string("sam"))])

  ds_sse.patch_signals(json)
  |> ds_sse.patch_signals_end
  |> ds_sse.event_to_string
  |> should.equal(expected)
}

pub fn patch_signals_maximal_test() {
  let expected =
    "event: datastar-patch-signals
id: 123
retry: 2000
data: onlyIfMissing true
data: signals {\"name\":\"sam\"}
"

  let json = json.object([#("name", json.string("sam"))])

  ds_sse.patch_signals(json)
  |> ds_sse.patch_signals_event_id("123")
  |> ds_sse.patch_signals_only_if_missing(True)
  |> ds_sse.patch_signals_retry(2000)
  |> ds_sse.patch_signals_end
  |> ds_sse.event_to_string
  |> should.equal(expected)
}

pub fn patch_signals_defaults_test() {
  let expected =
    "event: datastar-patch-signals
data: signals {\"name\":\"sam\"}
"

  let json = json.object([#("name", json.string("sam"))])

  ds_sse.patch_signals(json)
  |> ds_sse.patch_signals_only_if_missing(False)
  |> ds_sse.patch_signals_end
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
    "event: datastar-patch-elements
data: elements <span>Hello</span>

event: datastar-patch-elements
data: selector #id2

"

  [
    ds_sse.patch_elements()
      |> ds_sse.patch_elements_elements("<span>Hello</span>")
      |> ds_sse.patch_elements_end,
    ds_sse.patch_elements()
      |> ds_sse.patch_elements_selector("#id2")
      |> ds_sse.patch_elements_end,
  ]
  |> ds_sse.events_to_string
  |> should.equal(expected)
}

pub fn readme_example_test() {
  let expected =
    "event: datastar-patch-elements
data: mode remove
data: selector #error

event: datastar-patch-elements
data: mode inner
data: selector #notice
data: elements <span>Hello</span>

"

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
  |> should.equal(expected)
}
