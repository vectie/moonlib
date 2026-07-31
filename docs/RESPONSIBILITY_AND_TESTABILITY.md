# MoonLib responsibility and testability

MoonLib is shared library functionality. It owns small policy-free utilities
and versioned cross-product vocabulary. It has no daemon, pack application,
operator UI, provider routing, orchestration loop, or domain workflow.

## Package ownership

| Package family | Responsibility | Exclusion |
| --- | --- | --- |
| `pathx`, `fsx`, `os`, `spawn`, `clock`, `rand`, `uuid`, `c`, `errno` | explicit low-level runtime primitives | no product policy or autonomous effects |
| `moonsuite` | deterministic suite, book, product, temporary, and accepted-output paths | no live service discovery |
| `conversation` | journal, control, watch, approval, cancellation, and settlement DTOs | no chat UI or agent loop |
| `capability` | capability identity, declaration, evidence, conformance, and execution vocabulary | no capability grant or health inference |
| `pipeline` | generic authority, work, evidence, intervention, and embodied handoff contracts | no domain decision or workflow execution |
| `pack` | manifest validation and policy-free install/registry/host planning | no product-specific pack behavior |
| `i18n` | locale and catalog primitives | no product copy ownership |

Public concrete types live in the package consumers import. A contract should
move into MoonLib only after at least two independent consumers need the same
semantics; otherwise it remains product-local.

## Test seams

| Responsibility | Focused evidence |
| --- | --- |
| pure utilities | deterministic black-box tests across supported targets |
| paths and filesystem | containment, symlink, missing-path, mutation, and temporary-root cases |
| serialized contracts | required-field rejection, unknown-field tolerance, stable identity, and canonical round trips |
| pack planning | manifest/authority validation and non-mutating plan assertions before host effects |
| cross-product compatibility | one runtime producer and one UI consumer for any promoted DTO revision |

Generated `pkg.generated.mbti` files are the public API review surface. A
passing MoonLib suite does not prove a consuming product's authority, provider,
UI, or lifecycle behavior.
