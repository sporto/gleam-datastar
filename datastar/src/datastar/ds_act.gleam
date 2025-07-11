// https://data-star.dev/reference/actions

import gleam/dict
import gleam/function
import gleam/json.{type Json}
import gleam/list
import gleam/option.{type Option, None, Some}

pub opaque type Method {
  Delete
  Get
  Patch
  Post
  Put
}

fn method_to_code(method: Method) -> String {
  case method {
    Delete -> "delete"
    Get -> "get"
    Patch -> "patch"
    Post -> "post"
    Put -> "put"
  }
}

pub opaque type ContentType {
  Form
  Json
}

pub opaque type ActionRestConfig {
  ActionRestConfig(
    method: Method,
    url: String,
    content_type: ContentType,
    include_local: Bool,
    // selector only relevant when content_type is Form
    selector: Option(String),
    headers: List(#(String, String)),
    open_when_hidden: Bool,
    retry_interval: Int,
    retry_scaler: Int,
    retry_max_wait_ms: Int,
    retry_max_count: Int,
  )
}

fn rest_config(method, url) {
  ActionRestConfig(
    method:,
    url:,
    content_type: Json,
    include_local: False,
    selector: None,
    headers: [],
    open_when_hidden: False,
    retry_interval: 1000,
    retry_scaler: 2,
    retry_max_wait_ms: 30_000,
    retry_max_count: 10,
  )
}

fn add_content_type(options: ActionRestConfig) {
  case options.content_type {
    Json -> []
    Form -> [#("contentType", json.string("form"))]
  }
}

fn add_include_local(options: ActionRestConfig) {
  case options.include_local {
    True -> [#("includeLocal", json.string("true"))]
    False -> []
  }
}

fn add_selector(options: ActionRestConfig) {
  case options.selector {
    Some(selector) -> [#("selector", json.string(selector))]
    None -> []
  }
}

fn add_headers(options: ActionRestConfig) {
  case list.is_empty(options.headers) {
    True -> []
    False -> {
      [
        #(
          "headers",
          options.headers
            |> dict.from_list
            |> json.dict(function.identity, json.string),
        ),
      ]
    }
  }
}

fn add_open_when_hidden(options: ActionRestConfig) {
  case options.open_when_hidden {
    True -> [#("openWhenHidden", json.string("true"))]
    False -> []
  }
}

fn add_retry_interval(options: ActionRestConfig) {
  case options.retry_interval {
    1000 -> []
    _ -> [#("retryInterval", json.int(options.retry_interval))]
  }
}

fn add_retry_scaler(options: ActionRestConfig) {
  case options.retry_scaler {
    2 -> []
    _ -> [#("retryScaler", json.int(options.retry_scaler))]
  }
}

fn add_retry_max_wait_ms(options: ActionRestConfig) {
  case options.retry_max_wait_ms {
    30_000 -> []
    _ -> [#("retryMaxWaitMs", json.int(options.retry_max_wait_ms))]
  }
}

fn add_retry_max_count(options: ActionRestConfig) {
  case options.retry_max_count {
    10 -> []
    _ -> [#("retryMaxCount", json.int(options.retry_max_count))]
  }
}

@internal
pub fn rest_config_to_string(options: ActionRestConfig) {
  [
    add_content_type(options),
    add_include_local(options),
    add_selector(options),
    add_open_when_hidden(options),
    add_headers(options),
    add_retry_interval(options),
    add_retry_scaler(options),
    add_retry_max_wait_ms(options),
    add_retry_max_count(options),
  ]
  |> list.flatten
  |> json.object
  |> json.to_string
}

pub fn delete(url) {
  rest_config(Delete, url)
}

pub fn get(url) {
  rest_config(Get, url)
}

pub fn post(url) {
  rest_config(Post, url)
}

pub fn patch(url) {
  rest_config(Patch, url)
}

pub fn put(url) {
  rest_config(Put, url)
}

pub fn set_all(signals: String, expression: String) {
  "@setAll('" <> signals <> "', " <> expression <> ")"
}

pub fn toggle_all(signals: String) {
  "@toggleAll('" <> signals <> "')"
}

pub fn with_content_type_form(config: ActionRestConfig) {
  ActionRestConfig(..config, content_type: Form)
}

pub fn with_headers(config, headers) {
  ActionRestConfig(..config, headers:)
}

pub fn end(config: ActionRestConfig) {
  let method_code = method_to_code(config.method)
  let options = rest_config_to_string(config)
  "@" <> method_code <> "('" <> config.url <> "', " <> options <> ")"
}
