// Refer to https://github.com/starfederation/datastar/blob/develop/sdk/README.md

import gleam/bool
import gleam/int
import gleam/list
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
  EventMergeFragment(MergeFragmentEventConfig)
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

pub opaque type MergeFragmentEventConfig {
  MergeFragmentEventConfig(
    fragments: String,
    options: List(EventOption(MergeFragmentOptionType)),
  )
}

pub opaque type MergeFragmentOptionType {
  MergeFragmentOptionType
}

pub opaque type RemoveFragmentOptionType {
  RemoveFragmentOptionType
}

pub opaque type MergeSignalsOptionType {
  MergeSignalsOptionType
}

pub opaque type RemoveSignalsOptionType {
  RemoveSignalsOptionType
}

pub opaque type ExecuteScriptOptionType {
  ExecuteScriptOptionType
}

pub opaque type EventOption(phantom) {
  EventOptionAttributes(List(#(String, String)))
  EventOptionAutoRemove(Bool)
  EventOptionEventId(String)
  EventOptionMergeMode(MergeMode)
  EventOptionOnlyIfMissing(Bool)
  EventOptionRetry(Int)
  EventOptionSelector(String)
  EventOptionSettleDuration(Int)
  EventOptionViewTransition(Bool)
}

/// This option is only used by event_execute_script
///
/// ```
/// data_auto_remove(False),
/// ```
/// Generates:
///
/// ```
/// data: autoRemove false
/// ```
pub fn data_auto_remove(value: Bool) -> EventOption(ExecuteScriptOptionType) {
  EventOptionAutoRemove(value)
}

/// This option is only used by event_execute_script
///
/// ```
/// data_attributes([#("type", "text/javascript")]),
/// ```
///
/// Generates:
/// ```
/// data: attributes type text/javascript
/// ```
///
pub fn data_attributes(
  value: List(#(String, String)),
) -> EventOption(ExecuteScriptOptionType) {
  EventOptionAttributes(value)
}

/// This option is only used by event_merge_fragments
///
/// ```gleam
/// data_merge_mode(MergeMode.Inner),
/// ```
///
/// Generates:
/// ```
/// data: mergeMode inner
/// ```
///
pub fn data_merge_mode(mode: MergeMode) -> EventOption(MergeFragmentOptionType) {
  EventOptionMergeMode(mode)
}

/// This option is used by event_merge_fragments and event_remove_fragments
pub fn data_view_transition(value: Bool) -> EventOption(p) {
  EventOptionViewTransition(value)
}

/// Optional for all SSE events
///
/// ```
/// dt.event_id("123"),
/// ```
/// Generates:
/// ```
/// id: 123
/// ```
pub fn event_id(value: String) -> EventOption(a) {
  EventOptionEventId(value)
}

/// Option only used by event_merge_signals
pub fn data_only_if_missing(value: Bool) -> EventOption(MergeSignalsOptionType) {
  EventOptionOnlyIfMissing(value)
}

/// Option used by all events
///
/// ```gleam
/// retry(3000),
/// ```
/// Generates:
/// ```
/// retry: 3000
/// ```
pub fn retry(value: Int) -> EventOption(a) {
  EventOptionRetry(value)
}

/// Option only used by event_merge_fragments
///
/// ```gleam
/// data_selector("#feed"),
/// ```
/// Generates:
/// ```
/// data: selector #feed
/// ```
pub fn data_selector(value: String) -> EventOption(MergeFragmentOptionType) {
  EventOptionSelector(value)
}

/// Option used by event_merge_fragments and event_remove_fragments
pub fn data_settle_duration(value: Int) -> EventOption(a) {
  EventOptionSettleDuration(value)
}

/// Event to send new fragments to the client
///
/// ```gleam
/// event_merge_fragments("<span>1</span>", [data_selector("#feed")]),
/// ```
/// Generates:
/// ```
/// event: datastar-merge-fragments
/// data: selector #feed
/// data: fragments <span>1</span>
///
/// ```
pub fn event_merge_fragments(
  fragments fragments: String,
  options options: List(EventOption(MergeFragmentOptionType)),
) -> Event {
  MergeFragmentEventConfig(fragments:, options:)
  |> EventMergeFragment
}

pub opaque type RemoveFragmentsConfig {
  RemoveFragmentsConfig(
    selector: String,
    options: List(EventOption(RemoveFragmentOptionType)),
  )
}

/// Event to remove fragments on the client
///
/// ```gleam
/// event_remove_fragments("#feed", []),
/// ```
/// Generates:
/// ```
/// event: datastar-remove-fragments
/// data: selector #feed
///
/// ```
pub fn event_remove_fragments(
  selector: String,
  options: List(EventOption(RemoveFragmentOptionType)),
) {
  RemoveFragmentsConfig(selector:, options:)
  |> EventRemoveFragments
}

pub opaque type MergeSignalsConfig {
  MergeSignalsConfig(
    signals: String,
    options: List(EventOption(MergeSignalsOptionType)),
  )
}

/// Generate a `datastar-merge-signals` event
///
/// ```gleam
/// event_merge_signals("{\"output\":\"Output Test\"}", []),
/// ```
/// Generates:
/// ```
/// event: datastar-merge-signals
/// data: signals {\"output\":\"Output Test\"}
///
/// ```
pub fn event_merge_signals(
  signals: String,
  options: List(EventOption(MergeSignalsOptionType)),
) {
  MergeSignalsConfig(signals:, options:)
  |> EventMergeSignals
}

pub opaque type RemoveSignalsConfig {
  RemoveSignalsConfig(
    signals: List(String),
    options: List(EventOption(RemoveSignalsOptionType)),
  )
}

/// Generate a `datastar-remove-signals` event
///
/// ```gleam
/// event_remove_signals(["user.name", "user.email"], [])
/// ```
/// Generates:
/// ```
/// event: datastar-remove-signals
/// data: paths user.name
/// data: paths user.email
///
/// ```
pub fn event_remove_signals(
  signals: List(String),
  options: List(EventOption(RemoveSignalsOptionType)),
) {
  RemoveSignalsConfig(signals:, options:)
  |> EventRemoveSignals
}

pub opaque type ExecuteScriptConfig {
  ExecuteScriptConfig(
    script: String,
    options: List(EventOption(ExecuteScriptOptionType)),
  )
}

/// Generate a `datastar-execute-script` event
///
/// ```gleam
/// event_execute_script("window.location = \"https://data-star.dev\"", [ event_id("123") ])
/// |> event_to_string
/// ```
/// Generates
/// ```
/// event: datastar-execute-script
/// id: 123
/// data: script window.location = \"https://data-star.dev\"
/// ```
pub fn event_execute_script(
  script: String,
  options: List(EventOption(ExecuteScriptOptionType)),
) {
  ExecuteScriptConfig(script:, options:)
  |> EventExecuteScript
}

// Build the event strings
fn merge_fragments_event_to_string(config: MergeFragmentEventConfig) {
  [
    [LineEventType(MergeFragments)],
    add_event_id(config.options),
    add_retry(config.options),
    add_merge_mode(config.options),
    add_selector(config.options),
    add_settle_duration(config.options),
    add_view_transition(config.options),
    [LineData("fragments " <> config.fragments)],
  ]
  |> list.flatten
  |> event_lines_to_strings
}

fn remove_fragments_event_to_string(config: RemoveFragmentsConfig) {
  [
    [LineEventType(RemoveFragments)],
    add_event_id(config.options),
    add_retry(config.options),
    [LineData("selector " <> config.selector)],
    add_settle_duration(config.options),
    add_view_transition(config.options),
  ]
  |> list.flatten
  |> event_lines_to_strings
}

fn merge_signals_event_to_string(config: MergeSignalsConfig) {
  [
    [LineEventType(MergeSignals)],
    add_event_id(config.options),
    add_retry(config.options),
    add_only_if_missing(config.options),
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
    add_event_id(config.options),
    add_retry(config.options),
    signals,
  ]
  |> list.flatten
  |> event_lines_to_strings
}

fn execture_script_event_to_string(config: ExecuteScriptConfig) {
  [
    [LineEventType(ExecuteScript)],
    add_event_id(config.options),
    add_retry(config.options),
    add_auto_remove(config.options),
    add_attributes(config.options),
    [LineData("script " <> config.script)],
  ]
  |> list.flatten
  |> event_lines_to_strings
}

fn add_attributes(options: List(EventOption(ExecuteScriptOptionType))) {
  options
  |> list.filter_map(fn(option) {
    case option {
      EventOptionAttributes(values) -> Ok(values)
      _ -> Error("No attributes")
    }
  })
  |> list.flat_map(fn(values) {
    list.filter_map(values, fn(value) {
      let #(k, v) = value
      case k, v {
        "type", "module" -> Error("Default")
        _, _ -> Ok(LineData("attributes " <> k <> " " <> v))
      }
    })
  })
}

fn add_auto_remove(options: List(EventOption(ExecuteScriptOptionType))) {
  options
  |> list.filter_map(fn(option) {
    case option {
      EventOptionAutoRemove(value) -> {
        case value {
          True -> Error("Default value")
          False -> {
            let str = value |> bool.to_string |> string.lowercase
            Ok(LineData("autoRemove " <> str))
          }
        }
      }
      _ -> Error("")
    }
  })
}

fn add_event_id(options: List(EventOption(p))) {
  options
  |> list.filter_map(fn(option) {
    case option {
      EventOptionEventId(id) -> Ok(LineEventId(id))
      _ -> Error("")
    }
  })
}

fn add_merge_mode(options: List(EventOption(p))) {
  options
  |> list.filter_map(fn(option) {
    case option {
      EventOptionMergeMode(merge_mode) -> {
        case merge_mode {
          Morph -> Error("")
          _ -> Ok(LineData("mergeMode " <> merge_mode_to_string(merge_mode)))
        }
      }
      _ -> Error("")
    }
  })
}

fn add_only_if_missing(options: List(EventOption(MergeSignalsOptionType))) {
  options
  |> list.filter_map(fn(option) {
    case option {
      EventOptionOnlyIfMissing(value) -> {
        case value {
          True -> {
            let str = value |> bool.to_string |> string.lowercase
            Ok(LineData("onlyIfMissing " <> str))
          }
          False -> Error("Default")
        }
      }
      _ -> Error("Not included")
    }
  })
}

fn add_retry(options: List(EventOption(p))) {
  options
  |> list.filter_map(fn(option) {
    case option {
      EventOptionRetry(id) -> Ok(LineRetry(id))
      _ -> Error("")
    }
  })
}

fn add_settle_duration(options: List(EventOption(p))) {
  options
  |> list.filter_map(fn(option) {
    case option {
      EventOptionSettleDuration(val) -> {
        case val {
          300 -> Error("Default")
          _ -> Ok(LineData("settleDuration " <> int.to_string(val)))
        }
      }
      _ -> Error("")
    }
  })
}

fn add_selector(options: List(EventOption(p))) {
  options
  |> list.filter_map(fn(option) {
    case option {
      EventOptionSelector(sel) -> Ok(LineData("selector " <> sel))
      _ -> Error("Not included")
    }
  })
}

fn add_view_transition(options: List(EventOption(p))) {
  options
  |> list.filter_map(fn(option) {
    case option {
      EventOptionViewTransition(val) -> {
        case val {
          True -> {
            let str = val |> bool.to_string |> string.lowercase
            Ok(LineData("useViewTransition " <> str))
          }
          False -> {
            Error("Default")
          }
        }
      }
      _ -> Error("Not included")
    }
  })
}
