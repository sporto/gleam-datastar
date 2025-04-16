# datastar_lustre

[![Package Version](https://img.shields.io/hexpm/v/datastar_lustre)](https://hex.pm/packages/datastar_lustre)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/datastar_lustre/)

Lustre binding for <https://data-star.dev/>

```sh
gleam add datastar_lustre
```

```gleam
import lustre/element
import datastar/ds_lustre

fn view() {
  element.div([ds_lustre.data_attr("title", "$foo")], [])
}
```

Will produce:

```html
<div data-attr-title="$foo"></div>
```

Further documentation can be found at <https://hexdocs.pm/datastar_lustre>.
