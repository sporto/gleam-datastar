//// This module provides functions to work with Datastar server sent events.
////
//// See reference here <https://data-star.dev/reference/sse_events>.

// Refer to https://github.com/starfederation/datastar/blob/develop/sdk/README.md

import gleam/bool
import gleam/int
import gleam/json.{type Json}
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string

/// The merge mode used by patch elements
pub type MergeMode {
  After
  Append
  Before
  Inner
  Outer
  Prepend
  Replace
  Remove
}

fn merge_mode_to_string(merge_mode: MergeMode) {
  case merge_mode {
    After -> "after"
    Append -> "append"
    Before -> "before"
    Inner -> "inner"
    Outer -> "outer"
    Prepend -> "prepend"
    Replace -> "replace"
    Remove -> "remove"
  }
}

type EventType {
  ExecuteScript
  PatchElements
  PatchSignals
}

fn event_type_to_string(event_type: EventType) {
  case event_type {
    ExecuteScript -> "datastar-execute-script"
    PatchElements -> "datastar-patch-elements"
    PatchSignals -> "datastar-patch-signals"
  }
}

type Line {
  LineEventType(EventType)
  LineData(String)
  LineEventId(String)
  LineRetry(Int)
}

/// SSE Events that can be send to the client.
/// Like `datastar-patch-elements`.
pub opaque type Event {
  EventPatchElement(PatchElementConfig)
  EventPatchSignals(PatchSignalsConfig)
  EventExecuteScript(ExecuteScriptConfig)
}

fn event_line_to_string(line: Line) {
  case line {
    LineEventType(event_type) -> "event: " <> event_type_to_string(event_type)
    LineData(data) -> "data: " <> data
    LineEventId(id) -> "id: " <> id
    LineRetry(duration) -> "retry: " <> int.to_string(duration)
  }
}

fn event_lines_to_strings(lines lines: List(Line)) {
  lines
  |> list.map(event_line_to_string)
  |> string.join("\n")
  |> string.append("\n")
}

/// Takes an `Event` and generates a string to send back to the client
///
/// ```gleam
/// patch_elements("#target")
/// |> patch_elements_end
/// |> event_to_string
/// ```
/// Generates:
/// ```text
/// event: datastar-patch-elements
/// data: selector #target
///
/// ```
///
pub fn event_to_string(event: Event) -> String {
  case event {
    EventPatchElement(config) -> patch_elements_event_to_string(config)
    EventPatchSignals(config) -> patch_signals_event_to_string(config)
    EventExecuteScript(config) -> execture_script_event_to_string(config)
  }
}

/// Takes a list of `Event` and generates the string to send to the client
///
/// ```gleam
/// [
///   patch_elements("<span>Hello</span>")
///   |> patch_elements_end,
///   patch_elements("#target")
///   |> patch_elements_mode(Remove)
///   |> patch_elements_end,
/// ]
/// |> events_to_string
/// ```
/// Generates:
/// ```text
/// event: datastar-patch-elements
/// data: elements <span>Hello</span>
///
/// event: datastar-patch-elements
/// data: mode remove
/// data: selector #target
///
/// ```
///
pub fn events_to_string(events events: List(Event)) {
  events
  |> list.map(event_to_string)
  |> string.join("\n")
  |> string.append("\n")
}

pub opaque type PatchElementConfig {
  PatchElementConfig(options: PatchElementOptions)
}

pub opaque type PatchElementOptions {
  PatchElementOptions(
    elements: Option(String),
    event_id: Option(String),
    merge_mode: MergeMode,
    retry: Option(Int),
    selector: Option(String),
    settle_duration: Int,
    view_transition: Bool,
  )
}

/// Event to send new elements to the client
///
/// ```gleam
/// patch_elements()
/// |> patch_elements_element("<span>1</span>")
/// |> patch_elements_selector("#feed")
/// |> patch_elements_end
/// ```
/// Generates:
/// ```text
/// event: datastar-patch-elements
/// data: selector #feed
/// data: elements <span>1</span>
///
/// ```
pub fn patch_elements() {
  let options =
    PatchElementOptions(
      elements: None,
      event_id: None,
      merge_mode: Outer,
      retry: None,
      selector: None,
      settle_duration: 300,
      view_transition: False,
    )

  PatchElementConfig(options:)
}

/// ```
/// |> patch_elements_elements("<div>Hello</div>"),
/// ```
/// Generates:
/// ```text
/// id: 123
/// ```
pub fn patch_elements_elements(
  config: PatchElementConfig,
  value: String,
) -> PatchElementConfig {
  PatchElementConfig(
    options: PatchElementOptions(..config.options, elements: Some(value)),
  )
}

/// ```
/// |> patch_elements_event_id("123"),
/// ```
/// Generates:
/// ```text
/// id: 123
/// ```
pub fn patch_elements_event_id(
  config: PatchElementConfig,
  value: String,
) -> PatchElementConfig {
  PatchElementConfig(
    options: PatchElementOptions(..config.options, event_id: Some(value)),
  )
}

/// ```gleam
/// |> patch_elements_merge_mode(MergeMode.Inner),
/// ```
/// Generates:
/// ```text
/// data: mode inner
/// ```
pub fn patch_elements_merge_mode(
  config: PatchElementConfig,
  value: MergeMode,
) -> PatchElementConfig {
  PatchElementConfig(
    options: PatchElementOptions(..config.options, merge_mode: value),
  )
}

/// ```gleam
/// |> patch_elements_retry(3000),
/// ```
/// Generates:
/// ```text
/// retry: 3000
/// ```
pub fn patch_elements_retry(
  config: PatchElementConfig,
  value: Int,
) -> PatchElementConfig {
  PatchElementConfig(
    options: PatchElementOptions(..config.options, retry: Some(value)),
  )
}

/// ```gleam
/// |> patch_elements_selector("#feed"),
/// ```
/// Generates:
/// ```text
/// data: selector #feed
/// ```
pub fn patch_elements_selector(
  config: PatchElementConfig,
  value: String,
) -> PatchElementConfig {
  PatchElementConfig(
    ..config,
    options: PatchElementOptions(..config.options, selector: Some(value)),
  )
}

pub fn patch_elements_settle_duration(
  config: PatchElementConfig,
  value: Int,
) -> PatchElementConfig {
  PatchElementConfig(
    options: PatchElementOptions(..config.options, settle_duration: value),
  )
}

pub fn patch_elements_view_transition(
  config: PatchElementConfig,
  value: Bool,
) -> PatchElementConfig {
  PatchElementConfig(
    options: PatchElementOptions(..config.options, view_transition: value),
  )
}

pub fn patch_elements_end(config: PatchElementConfig) -> Event {
  EventPatchElement(config)
}

pub opaque type PatchSignalsConfig {
  PatchSignalsConfig(signals: Json, options: PatchSignalsOptions)
}

pub opaque type PatchSignalsOptions {
  PatchSignalsOptions(
    event_id: Option(String),
    retry: Option(Int),
    only_if_missing: Bool,
  )
}

/// Generate a `datastar-patch-signals` event
///
/// ```gleam
/// let json = json.object([
///   #("name", json.string("sam"))
/// ])
///
/// patch_signals(json)
/// |> patch_signals_end
/// ```
/// Generates:
/// ```text
/// event: datastar-patch-signals
/// data: signals {\"name\":\"Sam\"}
///
/// ```
pub fn patch_signals(signals: Json) {
  // TODO signals should be json
  let options =
    PatchSignalsOptions(event_id: None, retry: None, only_if_missing: False)

  PatchSignalsConfig(signals:, options:)
}

/// ```
/// ...
/// |> patch_signals_event_id("123")
/// ```
/// Generates:
/// ```text
/// id: 123
/// ```
pub fn patch_signals_event_id(config: PatchSignalsConfig, value: String) {
  PatchSignalsConfig(
    ..config,
    options: PatchSignalsOptions(..config.options, event_id: Some(value)),
  )
}

/// ```gleam
/// |> patch_signals_retry(3000),
/// ```
/// Generates:
/// ```text
/// retry: 3000
/// ```
pub fn patch_signals_retry(config: PatchSignalsConfig, value: Int) {
  PatchSignalsConfig(
    ..config,
    options: PatchSignalsOptions(..config.options, retry: Some(value)),
  )
}

/// ```gleam
/// |> patch_signals_only_if_missing(True),
/// ```
/// Generates:
/// ```text
/// data: onlyIfMissing true
/// ```
pub fn patch_signals_only_if_missing(config: PatchSignalsConfig, value: Bool) {
  PatchSignalsConfig(
    ..config,
    options: PatchSignalsOptions(..config.options, only_if_missing: value),
  )
}

pub fn patch_signals_end(config: PatchSignalsConfig) {
  EventPatchSignals(config)
}

pub opaque type ExecuteScriptConfig {
  ExecuteScriptConfig(script: String, options: ExecuteScriptOptions)
}

pub opaque type ExecuteScriptOptions {
  ExecuteScriptOptions(
    attributes: List(#(String, String)),
    auto_remove: Bool,
    event_id: Option(String),
    retry: Option(Int),
  )
}

/// Generate a `datastar-execute-script` event
///
/// ```gleam
/// execute_script("window.location = \"https://data-star.dev\"")
/// |> execute_script_event_id("123")
/// |> execute_script_end
/// ```
/// Generates
/// ```text
/// event: datastar-execute-script
/// id: 123
/// data: script window.location = \"https://data-star.dev\"
/// ```
pub fn execute_script(script: String) {
  let options =
    ExecuteScriptOptions(
      attributes: [],
      auto_remove: True,
      event_id: None,
      retry: None,
    )

  ExecuteScriptConfig(script:, options:)
}

/// ```gleam
/// |> execute_script_attributes([#("type", "text/javascript")]),
/// ```
/// Generates:
/// ```text
/// data: attributes type text/javascript
/// ```
pub fn execute_script_attributes(
  config: ExecuteScriptConfig,
  value: List(#(String, String)),
) {
  ExecuteScriptConfig(
    ..config,
    options: ExecuteScriptOptions(..config.options, attributes: value),
  )
}

/// ```gleam
/// |> execute_script_auto_remove(False),
/// ```
/// Generates:
/// ```text
/// data: autoRemove false
/// ```
pub fn execute_script_auto_remove(config: ExecuteScriptConfig, value: Bool) {
  ExecuteScriptConfig(
    ..config,
    options: ExecuteScriptOptions(..config.options, auto_remove: value),
  )
}

/// ```
/// ...
/// |> execute_script_event_id("123")
/// ```
/// Generates:
/// ```text
/// id: 123
/// ```
pub fn execute_script_event_id(config: ExecuteScriptConfig, value: String) {
  ExecuteScriptConfig(
    ..config,
    options: ExecuteScriptOptions(..config.options, event_id: Some(value)),
  )
}

/// ```gleam
/// |> execute_script_retry(3000),
/// ```
/// Generates:
/// ```text
/// retry: 3000
/// ```
pub fn execute_script_retry(config: ExecuteScriptConfig, value: Int) {
  ExecuteScriptConfig(
    ..config,
    options: ExecuteScriptOptions(..config.options, retry: Some(value)),
  )
}

pub fn execute_script_end(config: ExecuteScriptConfig) {
  EventExecuteScript(config)
}

// Build the event strings
fn patch_elements_event_to_string(config: PatchElementConfig) {
  [
    [LineEventType(PatchElements)],
    add_event_id(config.options.event_id),
    add_retry(config.options.retry),
    add_merge_mode(config.options.merge_mode),
    add_selector(config.options.selector),
    add_settle_duration(config.options.settle_duration),
    add_view_transition(config.options.view_transition),
    add_elements(config.options.elements),
  ]
  |> list.flatten
  |> event_lines_to_strings
}

fn patch_signals_event_to_string(config: PatchSignalsConfig) {
  [
    [LineEventType(PatchSignals)],
    add_event_id(config.options.event_id),
    add_retry(config.options.retry),
    add_only_if_missing(config.options.only_if_missing),
    [LineData("signals " <> json.to_string(config.signals))],
  ]
  |> list.flatten
  |> event_lines_to_strings
}

fn execture_script_event_to_string(config: ExecuteScriptConfig) {
  [
    [LineEventType(ExecuteScript)],
    add_event_id(config.options.event_id),
    add_retry(config.options.retry),
    add_auto_remove(config.options.auto_remove),
    add_attributes(config.options.attributes),
    [LineData("script " <> config.script)],
  ]
  |> list.flatten
  |> event_lines_to_strings
}

fn add_attributes(attributes: List(#(String, String))) {
  attributes
  |> list.flat_map(fn(values) {
    let #(k, v) = values
    case k, v {
      "type", "module" -> []
      _, _ -> [LineData("attributes " <> k <> " " <> v)]
    }
  })
}

fn add_auto_remove(value: Bool) {
  case value {
    True -> []
    False -> {
      let str = value |> bool.to_string |> string.lowercase
      [LineData("autoRemove " <> str)]
    }
  }
}

fn option_to_list(option: Option(a)) {
  case option {
    Some(value) -> [value]
    None -> []
  }
}

fn add_elements(maybe: Option(String)) {
  case maybe {
    None -> []
    Some(data) -> [LineData("elements " <> data)]
  }
}

fn add_event_id(maybe: Option(String)) {
  maybe
  |> option_to_list
  |> list.map(LineEventId)
}

fn add_merge_mode(merge_mode: MergeMode) {
  case merge_mode {
    Outer -> []
    _ -> [LineData("mode " <> merge_mode_to_string(merge_mode))]
  }
}

fn add_only_if_missing(value: Bool) {
  case value {
    True -> {
      let str = value |> bool.to_string |> string.lowercase
      [LineData("onlyIfMissing " <> str)]
    }
    False -> []
  }
}

fn add_retry(maybe: Option(Int)) {
  maybe
  |> option_to_list
  |> list.map(LineRetry)
}

fn add_settle_duration(value: Int) {
  case value {
    300 -> []
    _ -> [LineData("settleDuration " <> int.to_string(value))]
  }
}

fn add_selector(maybe: Option(String)) {
  maybe
  |> option_to_list
  |> list.map(fn(sel) { LineData("selector " <> sel) })
}

fn add_view_transition(value: Bool) {
  case value {
    True -> {
      let str = value |> bool.to_string |> string.lowercase
      [LineData("useViewTransition " <> str)]
    }
    False -> []
  }
}
