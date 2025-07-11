import datastar/ds_lustre
import gleam/json
import gleeunit/should
import lustre/attribute

pub fn data_attr_test() {
  ds_lustre.data_attr("title", "$foo")
  |> should.equal(attribute.attribute("data-attr-title", "$foo"))
}

pub fn data_attrs_test() {
  ds_lustre.data_attrs([#("title", "$foo")])
  |> should.equal(attribute.attribute("data-attr", "{'title':$foo}"))
}

pub fn data_bind_test() {
  ds_lustre.data_bind("foo")
  |> should.equal(attribute.attribute("data-bind", "foo"))
}

pub fn data_class_test() {
  ds_lustre.data_class("hidden", "$foo")
  |> should.equal(attribute.attribute("data-class", "{'hidden':$foo}"))
}

pub fn data_classes_test() {
  ds_lustre.data_classes([#("hidden", "$foo"), #("error", "$bar")])
  |> should.equal(attribute.attribute(
    "data-class",
    "{'hidden':$foo,'error':$bar}",
  ))
}

pub fn data_computed_test() {
  ds_lustre.data_computed("foo", "$bar + $baz")
  |> should.equal(attribute.attribute("data-computed-foo", "$bar + $baz"))
}

pub fn data_on_test() {
  ds_lustre.data_on("click", "$foo = ''")
  |> should.equal(attribute.attribute("data-on-click", "$foo = ''"))
}

pub fn data_signal_test() {
  ds_lustre.data_signal("foo", "1")
  |> should.equal(attribute.attribute("data-signals-foo", "1"))
}

pub fn data_signals_test() {
  ds_lustre.data_signals([#("foo", json.int(1))])
  |> should.equal(attribute.attribute("data-signals", "{\"foo\":1}"))
}
