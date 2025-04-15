import datastar/ds_act
import gleeunit/should

const url = "ur.l"

pub fn clipboard_test() {
  ds_act.clipboard("Hello")
  |> should.equal("@clipboard('Hello')")
}

pub fn get_test() {
  ds_act.get(url)
  |> ds_act.end
  |> should.equal("@get('ur.l', {})")
}

pub fn del_test() {
  ds_act.delete(url)
  |> ds_act.end
  |> should.equal("@delete('ur.l', {})")
}

pub fn patch_test() {
  ds_act.patch(url)
  |> ds_act.end
  |> should.equal("@patch('ur.l', {})")
}

pub fn post_test() {
  ds_act.post(url)
  |> ds_act.end
  |> should.equal("@post('ur.l', {})")
}

pub fn put_test() {
  ds_act.put(url)
  |> ds_act.end
  |> should.equal("@put('ur.l', {})")
}

pub fn with_content_type_form_test() {
  ds_act.post(url)
  |> ds_act.with_content_type_form
  |> ds_act.end
  |> should.equal("@post('ur.l', {\"contentType\":\"form\"})")
}

pub fn with_headers_test() {
  ds_act.post(url)
  |> ds_act.with_headers([#("token", "123")])
  |> ds_act.end
  |> should.equal("@post('ur.l', {\"headers\":{\"token\":\"123\"}})")
}

pub fn set_all_test() {
  ds_act.set_all("foo", "$bar")
  |> should.equal("@setAll('foo', $bar)")
}

pub fn toggle_all_test() {
  ds_act.toggle_all("foo.**")
  |> should.equal("@toggleAll('foo.**')")
}
