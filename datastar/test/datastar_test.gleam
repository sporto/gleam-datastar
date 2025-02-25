import datastar as dt
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn event_merge_fragments_test() {
  let expected =
    "event: datastar-merge-fragments
data: fragments <span>1</span>
"

  dt.merge_fragments(fragments: "<span>1</span>")
  |> dt.merge_fragments_done
  |> dt.event_to_string
  |> should.equal(expected)
}

pub fn event_has_empty_lines_test() {
  let expected =
    "event: datastar-remove-fragments
data: selector #id1

event: datastar-remove-fragments
data: selector #id2

"

  [
    dt.remove_fragments("#id1")
      |> dt.remove_fragments_done,
    dt.remove_fragments("#id2")
      |> dt.remove_fragments_done,
  ]
  |> dt.events_to_string
  |> should.equal(expected)
}
