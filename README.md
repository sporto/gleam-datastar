# Gleam DataStar

Gleam bindings for 🚀 https://data-star.dev/

Datastar helps build reactive web applications with the simplicity of server-side rendering.

This repository contains three packages:

- <https://hexdocs.pm/datastar> - To generate Datastar **[Actions](https://data-star.dev/reference/action_plugins)** on the frontend and **[server sent events](https://data-star.dev/reference/sse_events)** on the backend.
- <https://hexdocs.pm/datastar_wisp> - To use the above package with Wisp.
- <https://hexdocs.pm/datastar_lustre> - To use the main package with Lustre.



## Datastar compatibility

The packages are compatible with datastar release v1.0.0-RC.8. 

Datastar has an optional PRO license with extra features. 
The versions of datastar after beta 11 are not available through npm. (only cdn and github).

You can either include datastar or the open fork dataSPA which comes with some additional plugins and the dataSPA inspector. 

#### dataSPA

https://github.com/dataSPA

```html
<script type="module" src="https://cdn.jsdelivr.net/gh/dataSPA/dataSPA@main/bundles/datastar.js"></script>
<script type="module" src="https://cdn.jsdelivr.net/gh/dataSPA/dataSPA-inspector@main/dataspa-inspector.bundled.js"></script>
  ```
OR 
#### datastar

https://github.com/starfederation/datastar

```html
<script type="module" src="https://cdn.jsdelivr.net/gh/starfederation/datastar@v1.0.0-RC.8/bundles/datastar.js"></script>
```
