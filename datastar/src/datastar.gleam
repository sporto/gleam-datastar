import gleam/list
import gleam/option.{type Option, None, Some}
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
  RemoveFragments
}

fn event_type_to_string(event_type: EventType) {
  case event_type {
    ExecuteScript -> "datastar-execute-script"
    MergeFragments -> "datastar-merge-fragments"
    RemoveFragments -> "datastar-remove-fragments"
  }
}

pub type Data {
  Data(data: String)
}

type Line {
  LineEventType(EventType)
  LineData(Data)
}

pub type Event {
  Event(event_type: EventType, data_lines: List(Data))
}

@internal
pub fn event_to_string(event: Event) -> String {
  [LineEventType(event.event_type), ..list.map(event.data_lines, LineData)]
  |> stringify_event_lines
}

fn stringify_event_line(line: Line) {
  case line {
    LineEventType(event_type) -> "event: " <> event_type_to_string(event_type)
    LineData(data) -> "data: " <> data.data
  }
}

fn stringify_event_lines(lines lines: List(Line)) {
  lines
  |> list.map(stringify_event_line)
  |> string.join("\n")
  |> string.append("\n")
}

pub fn events_to_string(events events: List(Event)) {
  events
  |> list.map(event_to_string)
  |> string.join("\n")
  |> string.append("\n")
}

fn add_selector(maybe_selector) {
  maybe_selector
  |> option.map(fn(sel) { Data("selector " <> sel) })
}

fn add_merge_mode(maybe_merge_mode) {
  maybe_merge_mode
  |> option.then(fn(merge_mode) {
    case merge_mode {
      Morph -> None
      _ -> Some(Data("mergeMode " <> merge_mode_to_string(merge_mode)))
    }
  })
}

pub type MergeFragmentConfig {
  MergeFragmentConfig(
    fragments: String,
    selector: Option(String),
    merge_mode: Option(MergeMode),
  )
}

pub fn merge_fragments(fragments fragments: String) -> MergeFragmentConfig {
  MergeFragmentConfig(fragments:, selector: None, merge_mode: None)
}

pub fn with_merge_mode(options: MergeFragmentConfig, merge_mode: MergeMode) {
  MergeFragmentConfig(..options, merge_mode: Some(merge_mode))
}

pub fn with_selector(options: MergeFragmentConfig, selector: String) {
  MergeFragmentConfig(..options, selector: Some(selector))
}

pub fn merge_fragments_done(config: MergeFragmentConfig) {
  let data_lines =
    [
      add_selector(config.selector),
      add_merge_mode(config.merge_mode),
      Some(Data("fragments " <> config.fragments)),
    ]
    |> option.values

  Event(MergeFragments, data_lines)
}

pub type RemoveFragmentsConfig {
  RemoveFragmentsConfig(selector: String)
}

pub fn remove_fragments(selector selector: String) {
  RemoveFragmentsConfig(selector:)
}

pub fn remove_fragments_done(config: RemoveFragmentsConfig) {
  let data_lines = [Data("selector " <> config.selector)]

  Event(RemoveFragments, data_lines)
}

pub fn event_console_log(message) -> Event {
  Event(ExecuteScript, [Data("script console.log(\"" <> message <> "\")")])
}
