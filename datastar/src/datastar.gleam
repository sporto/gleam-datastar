//// Refer to https://github.com/starfederation/datastar/blob/develop/sdk/README.md

import gleam/bool
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string

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

pub type EventType {
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

pub type Event {
  EventMergeFragment(MergeFragmentEventConfig)
  EventRemoveFragments(RemoveFragmentsConfig)
}

pub fn event_to_string(event: Event) -> String {
  case event {
    EventMergeFragment(config) -> merge_fragments_event_to_string(config)
    EventRemoveFragments(config) -> remove_fragments_event_to_string(config)
  }
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

pub fn events_to_string(events events: List(Event)) {
  events
  |> list.map(event_to_string)
  |> string.join("\n")
  |> string.append("\n")
}

pub type MergeFragmentOptions {
  MergeFragmentOptions(
    selector: Option(String),
    merge_mode: Option(MergeMode),
    use_view_transition: Bool,
    event_id: Option(String),
    retry_duration: Option(Int),
  )
}

pub fn merge_fragment_options() -> MergeFragmentOptions {
  MergeFragmentOptions(
    selector: None,
    merge_mode: None,
    use_view_transition: False,
    event_id: None,
    retry_duration: None,
  )
}

pub type MergeFragmentEventConfig {
  MergeFragmentEventConfig(
    fragments: String,
    options: List(EventOption(MergeFragmentOptionType)),
  )
}

pub type MergeFragmentOptionType {
  MergeFragmentOptionType
}

pub type RemoveFragmentOptionType {
  RemoveFragmentOptionType
}

pub type EventOption(phantom) {
  EventOptionMergeMode(MergeMode)
  EventOptionEventId(String)
  EventOptionRetry(Int)
  EventOptionSelector(String)
  EventOptionSettleDuration(Int)
  EventOptionViewTransition(Bool)
}

pub fn merge_mode(mode: MergeMode) -> EventOption(MergeFragmentOptionType) {
  EventOptionMergeMode(mode)
}

pub fn view_transition(value: Bool) -> EventOption(MergeFragmentOptionType) {
  EventOptionViewTransition(value)
}

pub fn event_id(value: String) -> EventOption(a) {
  EventOptionEventId(value)
}

pub fn retry(value: Int) -> EventOption(a) {
  EventOptionRetry(value)
}

pub fn selector(value: String) -> EventOption(MergeFragmentOptionType) {
  EventOptionSelector(value)
}

pub fn settle_duration(value: Int) -> EventOption(MergeFragmentOptionType) {
  EventOptionSettleDuration(value)
}

pub fn merge_fragments(
  fragments fragments: String,
  options options: List(EventOption(MergeFragmentOptionType)),
) -> Event {
  MergeFragmentEventConfig(fragments:, options:)
  |> EventMergeFragment
}

pub fn merge_fragments_event_to_string(config: MergeFragmentEventConfig) {
  [
    Ok(LineEventType(MergeFragments)),
    add_event_id(config.options),
    add_retry(config.options),
    add_merge_mode(config.options),
    add_selector(config.options),
    add_settle_duration(config.options),
    add_view_transition(config.options),
    Ok(LineData("fragments " <> config.fragments)),
  ]
  |> result.values
  |> event_lines_to_strings
}

pub fn remove_fragments_event_to_string(config: RemoveFragmentsConfig) {
  [
    Ok(LineEventType(RemoveFragments)),
    Ok(LineData("selector " <> config.selector)),
    add_event_id(config.options),
    add_retry(config.options),
  ]
  |> result.values
  |> event_lines_to_strings
}

fn add_event_id(options: List(EventOption(p))) {
  options
  |> list.find_map(fn(option) {
    case option {
      EventOptionEventId(id) -> Ok(LineEventId(id))
      _ -> Error("")
    }
  })
}

fn add_merge_mode(options: List(EventOption(p))) {
  options
  |> list.find_map(fn(option) {
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

fn add_retry(options: List(EventOption(p))) {
  options
  |> list.find_map(fn(option) {
    case option {
      EventOptionRetry(id) -> Ok(LineRetry(id))
      _ -> Error("")
    }
  })
}

fn add_settle_duration(options: List(EventOption(p))) {
  options
  |> list.find_map(fn(option) {
    case option {
      EventOptionSettleDuration(val) ->
        Ok(LineData("settleDuration " <> int.to_string(val)))
      _ -> Error("")
    }
  })
}

fn add_selector(options: List(EventOption(p))) {
  options
  |> list.find_map(fn(option) {
    case option {
      EventOptionSelector(sel) -> Ok(LineData("selector " <> sel))
      _ -> Error("")
    }
  })
}

fn add_view_transition(options: List(EventOption(p))) {
  options
  |> list.find_map(fn(option) {
    case option {
      EventOptionViewTransition(val) -> {
        let str = val |> bool.to_string |> string.lowercase
        Ok(LineData("useViewTransition " <> str))
      }
      _ -> Error("")
    }
  })
}

pub type RemoveFragmentsConfig {
  RemoveFragmentsConfig(
    selector: String,
    options: List(EventOption(RemoveFragmentOptionType)),
  )
}

pub fn remove_fragments(
  selector: String,
  options: List(EventOption(RemoveFragmentOptionType)),
) {
  RemoveFragmentsConfig(selector:, options:)
  |> EventRemoveFragments
}
// TODO should be execute_script
// pub fn event_console_log(message) -> Event {
//   Event(
//     ExecuteScript,
//     [Data("script console.log(\"" <> message <> "\")")],
//     event_id: None,
//     retry_duration: None,
//   )
// }
