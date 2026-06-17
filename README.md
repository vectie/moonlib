# MoonLib — Shared utilities for the Moon suite

Shared utility library used by moonstat, moonclaw, moondesk, moontown, and moonbook.

## Packages

| Package | Description | Origin |
|---------|-------------|--------|
| `fsx` | Filesystem operations | extracted from moonstat, moonclaw, moondesk, moonbook |
| `pathx` | Path manipulation | extracted from moonstat, moonclaw, moondesk, moonbook |
| `spawn` | Process spawning | extracted from moonstat, moonclaw |
| `uuid` | UUID generation | extracted from moonstat, moonclaw |
| `errno` | Errno constants | extracted from moonstat, moonclaw |
| `os` | OS utilities | extracted from moonstat, moonclaw |
| `rand` | Random bytes | extracted from moonstat, moonclaw |
| `clock` | Time/clock utilities | extracted from moonstat, moonclaw |
| `c` | C FFI helpers | extracted from moonstat, moonclaw |

## Usage

Add to your `moon.mod`:

```toml
import {
  "vectie/moonlib@0.1.0",
}
```

Then import in your code:

```moonbit
let path = @pathx.join(home, ".moonsuite")
let exists = @fsx.exists(path)
```

## Publishing

```sh
moon publish
```
