import datastar/ds_act

const url = "ur.l"

pub fn get_test() {
  assert ds_act.get(url)
    |> ds_act.end
    == "@get('ur.l', {})"
}

pub fn del_test() {
  assert ds_act.delete(url)
    |> ds_act.end
    == "@delete('ur.l', {})"
}

pub fn patch_test() {
  assert ds_act.patch(url)
    |> ds_act.end
    == "@patch('ur.l', {})"
}

pub fn post_test() {
  assert ds_act.post(url)
    |> ds_act.end
    == "@post('ur.l', {})"
}

pub fn put_test() {
  assert ds_act.put(url)
    |> ds_act.end
    == "@put('ur.l', {})"
}

pub fn with_content_type_form_test() {
  assert ds_act.post(url)
    |> ds_act.with_content_type_form
    |> ds_act.end
    == "@post('ur.l', {\"contentType\":\"form\"})"
}

pub fn with_headers_test() {
  assert ds_act.post(url)
    |> ds_act.with_headers([#("token", "123")])
    |> ds_act.end
    == "@post('ur.l', {\"headers\":{\"token\":\"123\"}})"
}

pub fn set_all_test() {
  assert ds_act.set_all("foo", "$bar") == "@setAll('foo', $bar)"
}

pub fn toggle_all_test() {
  assert ds_act.toggle_all("foo.**") == "@toggleAll('foo.**')"
}
