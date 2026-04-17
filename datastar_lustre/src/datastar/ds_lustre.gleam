//// This module provides functions to add Datastar data attributes to html elements
//// as shown here <https://data-star.dev/reference/attributes>

import gleam/dict
import gleam/function
import gleam/int
import gleam/json
import gleam/list
import gleam/string
import lustre/attribute as attr

fn serialise_expressions(pairs: List(#(String, String))) {
  let inner =
    pairs
    |> list.map(fn(pair) {
      let #(key, expression) = pair
      "'" <> key <> "':" <> expression
    })
    |> string.join(",")

  "{" <> inner <> "}"
}

/// Sets the value of any HTML attribute to an expression, and keeps it in sync.
///
/// See <https://data-star.dev/reference/attributes#data-attr>.
///
/// e.g.
/// ```gleam
/// div([ds_lustre.data_attr("title", "$foo")], [])
/// ```
///
/// ```html
/// <div data-attr-title="$foo"></div>
/// ```
pub fn data_attr(key, expression) {
  attr.attribute("data-attr:" <> key, expression)
}

/// Similar to `data_attr` but sets multiple attrs at once.
///
/// See <https://data-star.dev/reference/attributes#data-attr>
///
/// e.g.
/// ```html
/// <div data-attr="{title: $foo, disabled: $bar}"></div>
/// ```
pub fn data_attrs(pairs) {
  let expression = serialise_expressions(pairs)
  attr.attribute("data-attr", expression)
}

/// Creates a signal and sets up two-way data binding.
/// This takes the name of a signal (without the $).
///
/// See <https://data-star.dev/reference/attributes#data-bind>
///
/// ```gleam
/// ds_lustre.data_bind("first_name")
/// ```
///
/// ```html
/// <input data-bind="first_name" />
/// ```
///
pub fn data_bind(value) {
  attr.attribute("data-bind", value)
}

/// Adds or removes a class.
///
/// See <https://data-star.dev/reference/attributes#data-class>
///
/// The first value is the class name.
///
/// The second value is an expression.
///   e.g. a signal $selected or a complex expression
///
pub fn data_class(key, expression) {
  data_classes([#(key, expression)])
}

/// Control multiple classes at once
///
/// See <https://data-star.dev/reference/attributes#data-class>
///
pub fn data_classes(pairs: List(#(String, String))) {
  let expression = serialise_expressions(pairs)

  attr.attribute("data-class", expression)
}

/// Creates a signal that is computed based on an expression.
///
/// See <https://data-star.dev/reference/attributes#data-computed>
///
pub fn data_computed(key, value) {
  attr.attribute("data-computed:" <> key, value)
}

/// Executes an expression on page load and whenever any signals in the expression change.
///
/// See <https://data-star.dev/reference/attributes#data-effect>
pub fn data_effect(expression: String) {
  attr.attribute("data-effect", expression)
}

// Missing https://data-star.dev/reference/attributes#data-ignore

// Missing https://data-star.dev/reference/attributes#data-ignore-morph

/// See <https://data-star.dev/reference/attributes#data-indicator>
pub fn data_indicator(signal: String) {
  attr.attribute("data-indicator", signal)
}

///Runs an expression when the attribute is initialized. This can happen on page load, when an element is patched into the DOM, and any time the attribute is modified (via a backend action or otherwise).
/// ```gleam
/// data_init("$count = 1")
/// ```
/// https://data-star.dev/reference/attributes#data-init
pub fn data_init(expression: String) {
  attr.attribute("data-init", expression)
}

///Sets the text content of an element to a reactive JSON stringified version of signals
/// ```gleam
/// data_json_signals(include: "^app", exclude: "temp$") //use regexp
/// ```
/// https://data-star.dev/reference/attributes#data-json-signals
pub fn data_json_signals(include: String, exclude: String) {
  attr.attribute(
    "data-json-signals",
    "{include: /" <> include <> "/, exclude: /" <> exclude <> "/}",
  )
}

/// Attaches an event listener to an element.
///
/// See <https://data-star.dev/reference/attributes#data-on>
pub fn data_on(event, expression) {
  attr.attribute("data-on:" <> event, expression)
}

/// Shorcut for `data_on("click", _)`.
pub fn data_on_click(expression) {
  data_on("click", expression)
}

/// Shorcut for `data_on("submit", _)`.
///
/// This prevents the default submission behavior of forms.
pub fn data_on_submit(expression) {
  data_on("submit", expression)
}

/// Runs an expression when the element intersects with the viewport.
/// ```html
/// data_on_intersect("$intersected = true")
/// ```
/// ```html
/// <div data-on-intersect="$intersected = true"></div>
/// ```
/// https://data-star.dev/reference/attributes#data-on-intersect
pub fn data_on_intersect(expression) {
  attr.attribute("data-on-intersect", expression)
}

/// Runs an expression at a regular interval.
/// ```gleam
/// data_on_interval("$count++", 1000) //milliseconds
/// ```
/// ```html
/// <div data-on-interval="$count++"></div>
/// ```
/// https://data-star.dev/reference/attributes#data-on-interval
pub fn data_on_interval(expression, duration) {
  attr.attribute(
    "data-on-interval__duration." <> int.to_string(duration) <> "ms",
    expression,
  )
}

/// Runs an expression whenever any signals are patched. This is useful for tracking changes, updating computed values, or triggering side effects when data updates.
/// ```gleam
/// data_on_signal_patch("console.log('A signal changed!', patch)")
/// ```
/// ```html
/// <div data-on-signal-patch="console.log('Signal patch:', patch)"></div>
/// ```
/// https://data-star.dev/reference/attributes#data-on-signal-patch
pub fn data_on_signal_patch(expression) {
  attr.attribute("data-on-signal-patch", expression)
}

/// Filters which signals to watch when using the data-on-signal-patch attribute.
/// ```gleam
/// data_on_signal_patch_filter(include: "user|name", exclude: "password") //use regexp
/// ```
/// ```html
/// <div data-on-signal-patch-filter="{include: /user|name/, exclude: /password/}"></div>
/// ```
/// https://data-star.dev/reference/attributes#data-on-signal-patch-filter
pub fn data_on_signal_patch_filter(include: String, exclude: String) {
  attr.attribute(
    "data-persist",
    "{include: /" <> include <> "/, exclude: /" <> exclude <> "/}",
  )
}

/// Preserves the value of an attribute when morphing DOM elements..
/// ```gleam
/// data_preserve_attr("open class")
/// ```
/// ```html
/// <details open class="foo" data-preserve-attr="open class">
/// ...
/// </details>
/// ```
///
/// https://data-star.dev/reference/attributes#data-preserve-attr
pub fn data_preserve_attr(value) {
  attr.attribute("data-preserve-attr", value)
}

/// Creates a signal that is a reference to this DOM element.
///
/// See <https://data-star.dev/reference/attributes#data-ref>
pub fn data_ref(value) {
  attr.attribute("data-ref", value)
}

/// Show or hides an element based on an expression.
///
/// See <https://data-star.dev/reference/attributes#data-show>
pub fn data_show(value) {
  attr.attribute("data-show", value)
}

/// Patches one signals into the existing signals.
///
/// See <https://data-star.dev/reference/attributes#data-signals>
pub fn data_signal(signal, value) {
  attr.attribute("data-signals:" <> signal, value)
}

/// Merges one or more signals into the existing signals.
///
/// See <https://data-star.dev/reference/attributes#data-signals>
pub fn data_signals(signals: List(#(String, json.Json))) {
  let signals_json =
    signals
    |> dict.from_list
    |> json.dict(function.identity, function.identity)
    |> json.to_string

  attr.attribute("data-signals", signals_json)
}

/// Binds the text content of an element to an expression.
///
/// See <https://data-star.dev/reference/attributes#data-text>
///
/// e.g.
/// ```html
/// <div data-text="$foo"></div>
/// ```
///
pub fn data_text(value: String) {
  attr.attribute("data-text", value)
}

/// The signals to be persisted can be filtered by providing a value that is an object with include and/or exclude properties that are regular expressions.
/// ```gleam
/// data_persist(include: "foo|bar", exclude: "baz") //use regexp
/// ```
/// ```html
/// <div data-persist="{include: /foo/, exclude: /bar/}"></div>
/// ```
/// https://data-star.dev/reference/attributes#data-persist
pub fn data_persist(include: String, exclude: String) {
  attr.attribute(
    "data-persist",
    "{include: /" <> include <> "/, exclude: /" <> exclude <> "/}",
  )
}
