// Refer to https://github.com/starfederation/datastar/blob/develop/sdk/README.md

import gleam/bool
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string

/// The merge mode used by merge fragments
pub type MergeMode {
  Morph
  Inner
  Outer
  Prepend
  Append
  Before
  After
  UpsertAttributes
}

fn merge_mode_to_string(merge_mode: MergeMode) {
  case merge_mode {
    Morph -> "morph"
    Inner -> "inner"
    Outer -> "outer"
    Prepend -> "prepend"
    Append -> "append"
    Before -> "before"
    After -> "after"
    UpsertAttributes -> "upsertAttributes"
  }
}

type EventType {
  ExecuteScript
  MergeFragments
  MergeSignals
  RemoveFragments
  RemoveSignals
}

fn event_type_to_string(event_type: EventType) {
  case event_type {
    ExecuteScript -> "datastar-execute-script"
    MergeFragments -> "datastar-merge-fragments"
    MergeSignals -> "datastar-merge-signals"
    RemoveFragments -> "datastar-remove-fragments"
    RemoveSignals -> "datastar-remove-signals"
  }
}

type Line {
  LineEventType(EventType)
  LineData(String)
  LineEventId(String)
  LineRetry(Int)
}

/// SSE Events that can be send to the client
pub type Event {
  EventMergeFragment(MergeFragmentConfig)
  EventRemoveFragments(RemoveFragmentsConfig)
  EventMergeSignals(MergeSignalsConfig)
  EventRemoveSignals(RemoveSignalsConfig)
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

/// Takes an Event and generates a string to send back to the client
///
/// ```gleam
/// remove_fragments("#target", [])
/// |> event_to_string
/// ```
/// Generates
/// ```
/// event: datastar-remove-fragments
/// data: selector #target
///
/// ```
///
pub fn event_to_string(event: Event) -> String {
  case event {
    EventMergeFragment(config) -> merge_fragments_event_to_string(config)
    EventRemoveFragments(config) -> remove_fragments_event_to_string(config)
    EventMergeSignals(config) -> merge_signals_event_to_string(config)
    EventRemoveSignals(config) -> remove_signals_event_to_string(config)
    EventExecuteScript(config) -> execture_script_event_to_string(config)
  }
}

/// Takes a list of Events and generates the string to send to the client
pub fn events_to_string(events events: List(Event)) {
  events
  |> list.map(event_to_string)
  |> string.join("\n")
  |> string.append("\n")
}

pub type MergeFragmentConfig {
  MergeFragmentConfig(fragments: String, options: MergeFragmentOptions)
}

pub type MergeFragmentOptions {
  MergeFragmentOptions(
    event_id: Option(String),
    merge_mode: MergeMode,
    retry: Option(Int),
    selector: Option(String),
    settle_duration: Int,
    view_transition: Bool,
  )
}

/// Event to send new fragments to the client
///
/// ```gleam
/// merge_fragments("<span>1</span>")
/// |> merge_fragments_selector("#feed")
/// |> merge_fragments_end
/// ```
/// Generates:
/// ```
/// event: datastar-merge-fragments
/// data: selector #feed
/// data: fragments <span>1</span>
///
/// ```
pub fn merge_fragments(fragments fragments: String) {
  let options =
    MergeFragmentOptions(
      event_id: None,
      merge_mode: Morph,
      retry: None,
      selector: None,
      settle_duration: 300,
      view_transition: False,
    )

  MergeFragmentConfig(fragments:, options:)
}

/// ```
/// |> merge_fragments_event_id("123"),
/// ```
/// Generates:
/// ```
/// id: 123
/// ```
pub fn merge_fragments_event_id(
  config: MergeFragmentConfig,
  value: String,
) -> MergeFragmentConfig {
  MergeFragmentConfig(
    ..config,
    options: MergeFragmentOptions(..config.options, event_id: Some(value)),
  )
}

/// ```gleam
/// |> merge_fragments_merge_mode(MergeMode.Inner),
/// ```
/// Generates:
/// ```
/// data: mergeMode inner
/// ```
pub fn merge_fragments_merge_mode(
  config: MergeFragmentConfig,
  value: MergeMode,
) -> MergeFragmentConfig {
  MergeFragmentConfig(
    ..config,
    options: MergeFragmentOptions(..config.options, merge_mode: value),
  )
}

/// ```gleam
/// |> merge_fragments_retry(3000),
/// ```
/// Generates:
/// ```
/// retry: 3000
/// ```
pub fn merge_fragments_retry(
  config: MergeFragmentConfig,
  value: Int,
) -> MergeFragmentConfig {
  MergeFragmentConfig(
    ..config,
    options: MergeFragmentOptions(..config.options, retry: Some(value)),
  )
}

/// ```gleam
/// |> merge_fragments_selector("#feed"),
/// ```
/// Generates:
/// ```
/// data: selector #feed
/// ```
pub fn merge_fragments_selector(
  config: MergeFragmentConfig,
  value: String,
) -> MergeFragmentConfig {
  MergeFragmentConfig(
    ..config,
    options: MergeFragmentOptions(..config.options, selector: Some(value)),
  )
}

pub fn merge_fragments_settle_duration(
  config: MergeFragmentConfig,
  value: Int,
) -> MergeFragmentConfig {
  MergeFragmentConfig(
    ..config,
    options: MergeFragmentOptions(..config.options, settle_duration: value),
  )
}

pub fn merge_fragments_view_transition(
  config: MergeFragmentConfig,
  value: Bool,
) -> MergeFragmentConfig {
  MergeFragmentConfig(
    ..config,
    options: MergeFragmentOptions(..config.options, view_transition: value),
  )
}

pub fn merge_fragments_end(config: MergeFragmentConfig) -> Event {
  EventMergeFragment(config)
}

pub type RemoveFragmentsConfig {
  RemoveFragmentsConfig(selector: String, options: RemoveFragmentsOptions)
}

pub type RemoveFragmentsOptions {
  RemoveFragmentsOptions(
    event_id: Option(String),
    retry: Option(Int),
    settle_duration: Int,
    view_transition: Bool,
  )
}

/// Event to remove fragments on the client
///
/// ```gleam
/// remove_fragments("#feed")
/// |> remove_fragments_end
/// ```
/// Generates:
/// ```
/// event: datastar-remove-fragments
/// data: selector #feed
///
/// ```
pub fn remove_fragments(selector: String) {
  let options =
    RemoveFragmentsOptions(
      event_id: None,
      retry: None,
      settle_duration: 300,
      view_transition: False,
    )
  RemoveFragmentsConfig(selector:, options:)
}

/// ```
/// |> remove_fragments_event_id("123"),
/// ```
/// Generates:
/// ```
/// id: 123
/// ```
pub fn remove_fragments_event_id(
  config: RemoveFragmentsConfig,
  value: String,
) -> RemoveFragmentsConfig {
  RemoveFragmentsConfig(
    ..config,
    options: RemoveFragmentsOptions(..config.options, event_id: Some(value)),
  )
}

/// ```gleam
/// |> remove_fragments_retry(3000),
/// ```
/// Generates:
/// ```
/// retry: 3000
/// ```
pub fn remove_fragments_retry(
  config: RemoveFragmentsConfig,
  value: Int,
) -> RemoveFragmentsConfig {
  RemoveFragmentsConfig(
    ..config,
    options: RemoveFragmentsOptions(..config.options, retry: Some(value)),
  )
}

pub fn remove_fragments_settle_duration(
  config: RemoveFragmentsConfig,
  value: Int,
) -> RemoveFragmentsConfig {
  RemoveFragmentsConfig(
    ..config,
    options: RemoveFragmentsOptions(..config.options, settle_duration: value),
  )
}

pub fn remove_fragments_view_transition(
  config: RemoveFragmentsConfig,
  value: Bool,
) -> RemoveFragmentsConfig {
  RemoveFragmentsConfig(
    ..config,
    options: RemoveFragmentsOptions(..config.options, view_transition: value),
  )
}

pub fn remove_fragments_end(config: RemoveFragmentsConfig) {
  EventRemoveFragments(config)
}

pub type MergeSignalsConfig {
  MergeSignalsConfig(signals: String, options: MergeSignalsOptions)
}

pub type MergeSignalsOptions {
  MergeSignalsOptions(
    event_id: Option(String),
    retry: Option(Int),
    only_if_missing: Bool,
  )
}

/// Generate a `datastar-merge-signals` event
///
/// ```gleam
/// merge_signals("{\"output\":\"Output Test\"}")
/// |> merge_signals_end
/// ```
/// Generates:
/// ```
/// event: datastar-merge-signals
/// data: signals {\"output\":\"Output Test\"}
///
/// ```
pub fn merge_signals(signals: String) {
  // TODO signals should be json
  let options =
    MergeSignalsOptions(event_id: None, retry: None, only_if_missing: False)

  MergeSignalsConfig(signals:, options:)
}

/// ```
/// ...
/// |> merge_signals_event_id("123")
/// ```
/// Generates:
/// ```
/// id: 123
/// ```
pub fn merge_signals_event_id(config: MergeSignalsConfig, value: String) {
  MergeSignalsConfig(
    ..config,
    options: MergeSignalsOptions(..config.options, event_id: Some(value)),
  )
}

/// ```gleam
/// |> merge_signals_retry(3000),
/// ```
/// Generates:
/// ```
/// retry: 3000
/// ```
pub fn merge_signals_retry(config: MergeSignalsConfig, value: Int) {
  MergeSignalsConfig(
    ..config,
    options: MergeSignalsOptions(..config.options, retry: Some(value)),
  )
}

/// ```gleam
/// |> merge_signals_only_if_missing(True),
/// ```
/// Generates:
/// ```
/// data: onlyIfMissing true
/// ```
pub fn merge_signals_only_if_missing(config: MergeSignalsConfig, value: Bool) {
  MergeSignalsConfig(
    ..config,
    options: MergeSignalsOptions(..config.options, only_if_missing: value),
  )
}

pub fn merge_signals_end(config: MergeSignalsConfig) {
  EventMergeSignals(config)
}

pub type RemoveSignalsConfig {
  RemoveSignalsConfig(signals: List(String), options: RemoveSignalsOptions)
}

pub type RemoveSignalsOptions {
  RemoveSignalsOptions(event_id: Option(String), retry: Option(Int))
}

/// Generate a `datastar-remove-signals` event
///
/// ```gleam
/// remove_signals(["user.name", "user.email"])
/// |> remove_signals_end
/// ```
/// Generates:
/// ```
/// event: datastar-remove-signals
/// data: paths user.name
/// data: paths user.email
///
/// ```
pub fn remove_signals(signals: List(String)) {
  let options = RemoveSignalsOptions(event_id: None, retry: None)

  RemoveSignalsConfig(signals:, options:)
}

/// ```
/// ...
/// |> remove_signals_event_id("123")
/// ```
/// Generates:
/// ```
/// id: 123
/// ```
pub fn remove_signals_event_id(config: RemoveSignalsConfig, value: String) {
  RemoveSignalsConfig(
    ..config,
    options: RemoveSignalsOptions(..config.options, event_id: Some(value)),
  )
}

/// ```gleam
/// |> remove_signals_retry(3000),
/// ```
/// Generates:
/// ```
/// retry: 3000
/// ```
pub fn remove_signals_retry(config: RemoveSignalsConfig, value: Int) {
  RemoveSignalsConfig(
    ..config,
    options: RemoveSignalsOptions(..config.options, retry: Some(value)),
  )
}

pub fn remove_signals_end(config: RemoveSignalsConfig) {
  EventRemoveSignals(config)
}

pub type ExecuteScriptConfig {
  ExecuteScriptConfig(script: String, options: ExecuteScriptOptions)
}

pub type ExecuteScriptOptions {
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
/// ```
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
/// ```
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
/// ```
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
/// ```
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
/// ```
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
fn merge_fragments_event_to_string(config: MergeFragmentConfig) {
  [
    [LineEventType(MergeFragments)],
    add_event_id(config.options.event_id),
    add_retry(config.options.retry),
    add_merge_mode(config.options.merge_mode),
    add_selector(config.options.selector),
    add_settle_duration(config.options.settle_duration),
    add_view_transition(config.options.view_transition),
    [LineData("fragments " <> config.fragments)],
  ]
  |> list.flatten
  |> event_lines_to_strings
}

fn remove_fragments_event_to_string(config: RemoveFragmentsConfig) {
  [
    [LineEventType(RemoveFragments)],
    add_event_id(config.options.event_id),
    add_retry(config.options.retry),
    [LineData("selector " <> config.selector)],
    add_settle_duration(config.options.settle_duration),
    add_view_transition(config.options.view_transition),
  ]
  |> list.flatten
  |> event_lines_to_strings
}

fn merge_signals_event_to_string(config: MergeSignalsConfig) {
  [
    [LineEventType(MergeSignals)],
    add_event_id(config.options.event_id),
    add_retry(config.options.retry),
    add_only_if_missing(config.options.only_if_missing),
    [LineData("signals " <> config.signals)],
  ]
  |> list.flatten
  |> event_lines_to_strings
}

fn remove_signals_event_to_string(config: RemoveSignalsConfig) {
  let signals =
    list.map(config.signals, fn(signal) { LineData("paths " <> signal) })

  [
    [LineEventType(RemoveSignals)],
    add_event_id(config.options.event_id),
    add_retry(config.options.retry),
    signals,
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

fn add_event_id(maybe: Option(String)) {
  maybe
  |> option_to_list
  |> list.map(LineEventId)
}

fn add_merge_mode(merge_mode: MergeMode) {
  case merge_mode {
    Morph -> []
    _ -> [LineData("mergeMode " <> merge_mode_to_string(merge_mode))]
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
