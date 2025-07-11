import datastar/ds_lustre
import gleam/json
import lustre/attribute

pub fn data_attr_test() {
  assert ds_lustre.data_attr("title", "$foo")
    == attribute.attribute("data-attr-title", "$foo")
}

pub fn data_attrs_test() {
  assert ds_lustre.data_attrs([#("title", "$foo")])
    == attribute.attribute("data-attr", "{'title':$foo}")
}

pub fn data_bind_test() {
  assert ds_lustre.data_bind("foo") == attribute.attribute("data-bind", "foo")
}

pub fn data_class_test() {
  assert ds_lustre.data_class("hidden", "$foo")
    == attribute.attribute("data-class", "{'hidden':$foo}")
}

pub fn data_classes_test() {
  assert ds_lustre.data_classes([#("hidden", "$foo"), #("error", "$bar")])
    == attribute.attribute("data-class", "{'hidden':$foo,'error':$bar}")
}

pub fn data_computed_test() {
  assert ds_lustre.data_computed("foo", "$bar + $baz")
    == attribute.attribute("data-computed-foo", "$bar + $baz")
}

pub fn data_on_test() {
  assert ds_lustre.data_on("click", "$foo = ''")
    == attribute.attribute("data-on-click", "$foo = ''")
}

pub fn data_signal_test() {
  assert ds_lustre.data_signal("foo", "1")
    == attribute.attribute("data-signals-foo", "1")
}

pub fn data_signals_test() {
  assert ds_lustre.data_signals([#("foo", json.int(1))])
    == attribute.attribute("data-signals", "{\"foo\":1}")
}
