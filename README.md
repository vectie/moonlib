# MoonLib - Shared utilities for the Moon suite

Shared utility library used by moongate, moonclaw, moondesk, moontown, and moonbook.

MoonLib is the low-level contract layer for code that more than one MoonSuite
product needs. It should stay deterministic, dependency-light, and free of
product policy so every product can depend on it without pulling in a runtime,
daemon, dashboard, or analytics system.

## Scope And Boundary

MoonLib owns:

- filesystem and path primitives used across products
- process, OS, random, clock, UUID, errno, and C FFI utilities
- shared MoonSuite layout contracts under `@moonsuite`
- small portable DTO contracts such as conversation records

MoonLib does not own status reporting, product health, usage analytics,
daemon supervision, UI behavior, domain workflows, or migration policy.
MoonGate may validate MoonLib contracts in live workspaces, but MoonGate should
not be required just to construct a suite path.

## Packages

| Package | Description | Origin |
|---------|-------------|--------|
| `fsx` | Filesystem operations | extracted from moongate, moonclaw, moondesk, moonbook |
| `pathx` | Path manipulation | extracted from moongate, moonclaw, moondesk, moonbook |
| `spawn` | Process spawning | extracted from moongate, moonclaw |
| `uuid` | UUID generation | extracted from moongate, moonclaw |
| `errno` | Errno constants | extracted from moongate, moonclaw |
| `os` | OS utilities | extracted from moongate, moonclaw |
| `rand` | Random bytes | extracted from moongate, moonclaw |
| `clock` | Time/clock utilities | extracted from moongate, moonclaw |
| `c` | C FFI helpers | extracted from moongate, moonclaw |
| `moonsuite` | Shared MoonSuite filesystem contracts | extracted from moondesk migration plan |
| `conversation` | Shared conversation record contracts | extracted from MoonDesk/MoonCode cleanup |
| `pipeline` | Versioned cross-product run, evidence, messaging, and robot design contracts | Moon Suite pipeline |

## Implementation Guidance

Keep packages small and boring. A MoonLib package should expose typed helpers
or data contracts, not background behavior. If a helper needs product-specific
configuration, pass it in explicitly rather than reading a product config file
from inside MoonLib.

The `@moonsuite` package is the canonical place for:

- suite-root discovery rules
- `books/<book-id>` path construction
- `.moonsuite/products/<product-id>` product-home paths
- `.tmp/products/<product-id>` temp paths
- accepted-output paths under the owning book
- product registry record shapes when shared by multiple products

When more than one product needs a filesystem path or registry shape, add it
here first and make product-local helpers thin adapters.

The `@pipeline` package similarly owns versioned JSON contract identifiers,
required fields, quality dimensions, and compatibility rules exchanged between
products. Consumers must ignore unknown fields and reject missing required
fields so contracts can evolve without silently accepting incomplete data.
It also provides a deterministic constitutional-conformance contract and
validator. Products supply their own boundary registry; MoonLib validates the
shape, authority, operation ownership, contract ownership, criterion owner,
negative-path evidence, acceptance review, claim ceiling, and workspace-local
artifact references without becoming the owner of product policy.

### Embodied workspace contracts

The `@pipeline` package defines policy-free portable shapes for the fourth
Moon Suite update:

- `DisclosureLevel` selects user, operator, or developer presentation without
  changing canonical state or authority.
- `BrowserSessionScope` binds a visible browser session to book and code
  revisions, a run, an authority envelope, an origin/network policy, scoped
  uploads/downloads, a storage lifetime, and an expiring capability digest.
- `BrowserActionReceipt` attributes an observed action to a human, agent, or
  replay and preserves its effect class, redacted arguments, expected and
  observed result, authority decision, state digests, and evidence.
- `SpatialArtifactManifest` identifies the purpose, lineage, coordinate
  conventions, backend, procedure, assumptions, validation, consumers, and
  claim ceiling of a digital spatial representation.
- `RepresentationTransform` records immutable parent/child hashes, tool and
  parameters, declared losses, authority, and validation.

These types encode no product policy. MoonGate decides which products may
perform an operation. MoonDesk decides how to present it. MoonClaw executes
authorized browser/modeling tools. MoonMold owns spatial authoring semantics.
MoonRobo and MoonMoon decide whether a declared engineering or simulation
representation meets their own input requirements.

The portable rules deliberately reject a styled representation as an
engineering input and reject a manufacturing candidate that does not descend
from an engineering representation. A manufacturing candidate remains a
digital artifact; it is not permission to operate a printer or other physical
device.

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
let product_home = @moonsuite.product_dir(home, "moonclaw")
```

## Testing Guidance

Run the full MoonLib suite before publishing because many products consume
these contracts directly:

```sh
moon check
moon test
moon info
moon fmt
```

For `@moonsuite` changes, add focused tests for suite roots, selected
`books/<book-id>` roots, product homes, temp lanes, accepted output paths, and
placeholder book ids. After publishing, run at least one consumer smoke in
MoonDesk or MoonGate if the public path contract changed.

## Worth Noticing

- Do not add dependencies from MoonLib back into MoonDesk, MoonGate, MoonClaw,
  MoonTown, or MoonBook.
- Prefer explicit string/record helpers over implicit filesystem probing unless
  the contract is specifically a discovery function.
- `.mbti` diffs are the public API signal. Review them carefully after
  `moon info`.
- Changing `@moonsuite` is a cross-product change even when only MoonLib files
  move.

## Future Plan

- Keep moving duplicated MoonSuite path helpers from products into
  `@moonsuite`.
- Add typed product-registry helpers once all consumers agree on the stable
  schema.
- Keep conversation contracts small enough for MoonCode, MoonChat, and
  MoonDesk to share without a UI dependency.
- Publish only after consumer-facing `.mbti` changes are intentional.

## Publishing

```sh
moon publish
```
