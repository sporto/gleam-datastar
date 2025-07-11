import datastar/ds_sse
import gleam/json

pub fn patch_elements_minimal_test() {
  let expected =
    "event: datastar-patch-elements
data: elements <span>Hello</span>
"

  let actual =
    ds_sse.patch_elements()
    |> ds_sse.patch_elements_elements("<span>Hello</span>")
    |> ds_sse.patch_elements_end
    |> ds_sse.event_to_string

  assert actual == expected
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

  let actual =
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

  assert actual == expected
}

pub fn patch_elements_defaults_test() {
  let expected =
    "event: datastar-patch-elements
data: elements <span>1</span>
"

  let actual =
    ds_sse.patch_elements()
    |> ds_sse.patch_elements_elements("<span>1</span>")
    |> ds_sse.patch_elements_merge_mode(ds_sse.Outer)
    |> ds_sse.patch_elements_settle_duration(300)
    |> ds_sse.patch_elements_view_transition(False)
    |> ds_sse.patch_elements_end
    |> ds_sse.event_to_string

  assert actual == expected
}

pub fn patch_signals_minimal_test() {
  let expected =
    "event: datastar-patch-signals
data: signals {\"name\":\"sam\"}
"

  let json = json.object([#("name", json.string("sam"))])

  let actual =
    ds_sse.patch_signals(json)
    |> ds_sse.patch_signals_end
    |> ds_sse.event_to_string

  assert actual == expected
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

  let actual =
    ds_sse.patch_signals(json)
    |> ds_sse.patch_signals_event_id("123")
    |> ds_sse.patch_signals_only_if_missing(True)
    |> ds_sse.patch_signals_retry(2000)
    |> ds_sse.patch_signals_end
    |> ds_sse.event_to_string

  assert actual == expected
}

pub fn patch_signals_defaults_test() {
  let expected =
    "event: datastar-patch-signals
data: signals {\"name\":\"sam\"}
"

  let json = json.object([#("name", json.string("sam"))])

  let actual =
    ds_sse.patch_signals(json)
    |> ds_sse.patch_signals_only_if_missing(False)
    |> ds_sse.patch_signals_end
    |> ds_sse.event_to_string

  assert actual == expected
}

pub fn event_has_empty_lines_test() {
  let expected =
    "event: datastar-patch-elements
data: elements <span>Hello</span>

event: datastar-patch-elements
data: selector #id2

"

  let actual =
    [
      ds_sse.patch_elements()
        |> ds_sse.patch_elements_elements("<span>Hello</span>")
        |> ds_sse.patch_elements_end,
      ds_sse.patch_elements()
        |> ds_sse.patch_elements_selector("#id2")
        |> ds_sse.patch_elements_end,
    ]
    |> ds_sse.events_to_string

  assert actual == expected
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

  let actual =
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

  assert actual == expected
}
