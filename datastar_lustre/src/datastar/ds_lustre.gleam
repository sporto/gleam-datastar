//// This module provides functions to add Datastar data attributes to html elements
//// as shown here <https://data-star.dev/reference/attribute_plugins>

import gleam/dict
import gleam/function
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
/// See <https://data-star.dev/reference/attribute_plugins#data-attr>.
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
  attr.attribute("data-attr-" <> key, expression)
}

/// Similar to `data_attr` but sets multiple attrs at once.
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
/// ```gleam
/// ds_lustre.data_bind("first_name")
/// ```
///
/// ```html
/// <input data-bind="first_name" />
/// ```
///
/// See <https://data-star.dev/reference/attribute_plugins#data-bind>
pub fn data_bind(value) {
  attr.attribute("data-bind", value)
}

/// Adds or removes a class.
///
/// The first value is the class name.
///
/// The second value is an expression.
///   e.g. a signal $selected or a complex expression
///
/// See <https://data-star.dev/reference/attribute_plugins#data-class>
pub fn data_class(key, expression) {
  data_classes([#(key, expression)])
}

/// Control multiple classes at once
///
/// See <https://data-star.dev/reference/attribute_plugins#data-class>
pub fn data_classes(pairs: List(#(String, String))) {
  let expression = serialise_expressions(pairs)

  attr.attribute("data-class", expression)
}

/// Creates a signal that is computed based on an expression.
///
/// See <https://data-star.dev/reference/attribute_plugins#data-computed>
pub fn data_computed(key, value) {
  attr.attribute("data-computed-" <> key, value)
}

/// See <https://data-star.dev/reference/attribute_plugins#data-custom-validity>
pub fn data_custom_validity(expression: String) {
  attr.attribute("data-custom-validity", expression)
}

/// See <https://data-star.dev/reference/attribute_plugins#data-indicator>
pub fn data_indicator(signal: String) {
  attr.attribute("data-indicator", signal)
}

/// See <https://data-star.dev/reference/attribute_plugins#data-star-ignore>
pub fn data_star_ignore() {
  attr.attribute("data-star-ignore", "")
}

/// Attaches an event listener to an element.
///
/// See <https://data-star.dev/reference/attribute_plugins#data-on>
pub fn data_on(event, expression) {
  attr.attribute("data-on-" <> event, expression)
}

/// Shorcut for `data_on("click", _)`.
pub fn data_on_click(expression) {
  data_on("click", expression)
}

/// Runs an expression when the element is loaded into the DOM.
///
/// See <https://data-star.dev/reference/attribute_plugins#data-on-load>
pub fn data_on_load(expression: String) {
  data_on("load", expression)
}

/// Runs an expression on every requestAnimationFrame event.
///
/// See <https://data-star.dev/reference/attribute_plugins#data-on-raf>
pub fn data_on_raf(expression: String) {
  data_on("raf", expression)
}

/// Runs an expression whenever a signal changes.
///
/// See <https://data-star.dev/reference/attribute_plugins#data-on-signal-change>
pub fn data_on_signal_change(expression) {
  data_on("signal-change", expression)
}

/// Runs an expression whenever a signal changes.
///
/// See <https://data-star.dev/reference/attribute_plugins#data-on-signal-change>
pub fn data_on_specific_signal_change(signal, expression) {
  data_on("signal-change-" <> signal, expression)
}

/// Shorcut for `data_on("submit", _)`.
///
/// This prevents the default submission behavior of forms.
pub fn data_on_submit(expression) {
  data_on("submit", expression)
}

/// Persists signals in local storage
///
/// e.g.
/// ```html
/// <div data-persist></div>
/// ```
///
/// See <https://data-star.dev/reference/attribute_plugins#data-persist>
pub fn data_persist(signals) {
  attr.attribute("data-persist", signals)
}

/// See <https://data-star.dev/reference/attribute_plugins#data-replace-url>
pub fn data_replace_url(value) {
  attr.attribute("data-replace-url", value)
}

/// Creates a signal that is a reference to this DOM element.
///
/// See <https://data-star.dev/reference/attribute_plugins#data-ref>
pub fn data_ref(value) {
  attr.attribute("data-ref", value)
}

/// See <https://data-star.dev/reference/attribute_plugins#data-scroll-into-view>
pub fn data_scroll_into_view() {
  attr.attribute("data-scroll-into-view", "")
}

/// Show or hides an element based on an expression.
///
/// See <https://data-star.dev/reference/attribute_plugins#data-show>
pub fn data_show(value) {
  attr.attribute("data-show", value)
}

/// Merges one signals into the existing signals.
///
/// See <https://data-star.dev/reference/attribute_plugins#data-signals>
pub fn data_signal(signal, value) {
  attr.attribute("data-signals-" <> signal, value)
}

/// Merges one or more signals into the existing signals.
///
/// See <https://data-star.dev/reference/attribute_plugins#data-signals>
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
/// e.g.
/// ```html
/// <div data-text="$foo"></div>
/// ```
///
/// See <https://data-star.dev/reference/attribute_plugins#data-text>
pub fn data_text(value: String) {
  attr.attribute("data-text", value)
}

/// See <https://data-star.dev/reference/attribute_plugins#data-view-transition>
pub fn data_view_transition(value) {
  attr.attribute("data-view-transition", value)
}
