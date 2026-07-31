# MoonLib product contract

Class: library/functionality
Maturity: available shared library; release process maturing
Last reviewed: 2026-07-31

## Outcome

MoonLib gives MoonSuite components one deterministic, dependency-light place
for portable paths, identifiers, data-transfer contracts and low-level runtime
helpers.

## Users and jobs

- Product authors use the same suite-root, book and product-home rules.
- Platform components exchange versioned conversation and pipeline records.
- Libraries reuse filesystem, process, clock, random, UUID and operating-system
  primitives without importing a daemon or domain policy.

## Ownership

MoonLib owns shared deterministic utilities and policy-free serialized
contracts. It does not own background services, provider selection, workflow
execution, health decisions, user interfaces, migrations or domain semantics.
Those decisions stay with the consuming product.

## Capability status

| Capability | Status | Evidence |
| --- | --- | --- |
| Filesystem, path, process and OS helpers | available | package tests and generated interfaces |
| MoonSuite layout contracts | available | `moonsuite/` tests |
| Conversation journal/control DTOs | available | `conversation/` tests |
| Cross-product pipeline contracts and conformance shapes | available | `pipeline/` tests |
| Pack-support contracts | experimental | `pack/` package and executable README |
| Independent production service | excluded | MoonLib is not a daemon |

## Integration contract

Consumers import published MoonBit packages. They must not require MoonLib to
discover live services or decide policy. Unknown serialized fields are ignored
where the versioned contract permits evolution; missing required fields fail
validation.

Public concrete types belong to the package users name. Generated
`pkg.generated.mbti` files are the API source of truth and are never edited by
hand.

## Operations and security

MoonLib stores no credentials and performs no autonomous network access.
Filesystem helpers must preserve containment and make mutating behavior
explicit. Consumers own authorization for every effect performed with a
MoonLib primitive.

## Verification

```sh
moon check --target all
moon test --target all
moon info
moon fmt
```

Review generated interface diffs whenever a public contract changes.

## Release gates and next milestones

- Add CI for every supported target.
- Publish versioned compatibility notes for shared DTO changes.
- Keep product policy and daemon behavior out of the module.
- Require at least two consumers before promoting a product-local DTO into
  MoonLib.
