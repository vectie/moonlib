# MoonSuite product implementation standard v2

Status: active for second-iteration product work

This standard aligns MoonSuite products without turning them into one large
application or forcing unrelated domains into identical source trees. A
product conforms when an operator can identify its job, complete its primary
workflow, recover from a blocked state, and exchange typed evidence through
the shared runtime contracts while the domain implementation stays local.

## 1. Product classes

Every repository declares one primary class in `docs/PRODUCT_CONTRACT.md`:

- **domain pack** — owns domain schemas, policy, workflow tools, evidence, and
  one or more pack applications;
- **platform service** — owns a generic runtime capability such as execution,
  authority, orchestration, or hosting, but no domain policy;
- **application** — owns a user-facing workspace over existing product
  contracts and does not invent a second runtime;
- **library/functionality** — owns reusable code and typed vocabulary and does
  not require a standalone application merely to appear as a product.

A retired alias is a lifecycle exception, not a fifth product class. Its
contract names the canonical successor, remains non-callable, and is excluded
from current manifests, capability catalogs, suite discovery, and UI
navigation. Likewise, a checkout directory, symlink, worktree, fixture, or
example does not create a product identity; module metadata and the product
contract are authoritative.

Aliases and roles are not separate runtimes. In particular, MoonClaw remains
the sole agent runtime, MoonFlow remains orchestration, MoonBook owns
Bookkeeper and MoonWiki behavior, and MoonCode remains a MoonClaw role.

## 2. Common repository contract

The following shape is required when it applies to the product class:

| Path | Requirement |
| --- | --- |
| `moon.mod` | Required for MoonBit repositories; pins the module identity and preferred target. |
| `README.mbt.md` or `README.md` | States the product outcome, quick start, and honest maturity boundary. |
| `docs/PRODUCT_CONTRACT.md` | Required; declares class, users, ownership, capabilities, exclusions, and release gates. |
| `docs/RESPONSIBILITY_AND_TESTABILITY.md` | Required for products with runtime behavior; maps responsibilities to evidence and tests. |
| `docs/qualification/UI_TO_UI_USE_CASES.md` | Required for a visible application; covers ordinary success, denial, recovery, and cross-product receipt return. |
| `cmd/<host-or-tool>/` | Thin composition roots only. Business rules belong in cohesive packages. |
| `<domain>/<feature>/` | Product-owned domain packages grouped by responsibility rather than giant `core`, `impl`, or `util` files. |
| `internal/<feature>/` | Optional private helpers. Public concrete types must not be owned here. |
| `pack.json` | Required for an installable pack; versioned tools, schemas, authority, evidence, review, and entrypoints only. |
| `schemas/` | Required when records cross a process or product boundary. Schemas are versioned and product-owned. |
| `adapters/moonflow/` | Required only for executable pack operations; adapter declaration and unavailable-by-default health template. |
| `workflows/` | Product-owned workflow templates. MoonFlow must not absorb their domain semantics. |
| `ui/rabbita-<product>/` | Preferred visible-app location; one Rabbita release may expose multiple routes for the same product. |
| `fixtures/` | Deterministic development and qualification inputs, visibly marked non-production. |
| `_build/` | Generated evidence and artifacts only; ignored by source control unless an explicit release contract says otherwise. |

Libraries omit `pack.json`, UI, adapters, and workflow folders when those
would create a false product surface. Products may retain established folder
names such as `frontend/` during a reviewed migration, but the ownership and
entrypoint mapping must be documented.

## 3. MoonBit module rules

- A directory with `moon.pkg` is a package boundary; filenames are only
  organizational.
- Keep public concrete types in the package users name or in an intentional
  public package re-exported by that facade.
- Split unrelated declarations into cohesive files inside the same package
  before creating another package.
- Keep executable `cmd/` packages thin. They may wire configuration, storage,
  HTTP, and product packages but must not duplicate product rules.
- Generated `pkg.generated.mbti` files are regenerated with `moon info` and
  never edited by hand.
- Runtime implementations use MoonBit. Rabbita owns visible application code.
  Python may exist only as frozen migration evidence or an explicitly
  non-production external tool and may not be the active product path.

## 4. MoonTown-equivalent interaction quality

MoonTown is the quality reference for clarity, spatial confidence, and fluent
feedback, not a brand template. Each visible product keeps its own tone while
meeting the following interaction contract:

1. The first viewport answers one question: **what outcome am I creating or
   reviewing?**
2. Exactly one dominant next action is visible. Secondary setup, evidence,
   raw records, and diagnostics use progressive disclosure.
3. A short step rail or progress map shows completed, current, blocked, and
   next states with icons and text; color is never the only signal.
4. Navigation uses a compact, stable set of semantic icons. Unfamiliar or
   consequential icons include short labels; every icon-only control has an
   accessible name and tooltip. Emoji are not structural icons.
5. Blockers explain the missing fact or authority and expose a concrete safe
   recovery action. A denial without a next step is incomplete UX.
6. Evidence, authority, cost, and claim ceilings remain inspectable but do not
   dominate the ordinary workflow.
7. Controls have at least a 44px target, visible keyboard focus, logical tab
   order, announced async errors, and usable empty/loading/stale/success states.
8. Motion communicates continuity, never changes layout bounds, and respects
   `prefers-reduced-motion`.
9. The product preserves the selected object and workflow position across
   refresh; restart recovery is claimed only after the process restarts over
   the same durable root.

## 5. Cross-product contract

A visible handoff is executable only when it binds all of:

- product and versioned operation identity;
- input and output schema identities;
- exact artifact references, byte digests, and lineage;
- least requested authority and any separately granted authority receipt;
- attempt, idempotency, and reconciliation identity;
- acceptance criteria and named review authority;
- return destination and durable receipt status.

Product names, canvas nodes, friendly verbs, and route links are discovery
affordances, not executable capability truth. MoonFlow advances the graph,
MoonClaw performs bounded agent work, MoonGate resolves authority/provider
access, and the receiving product owns the domain result.

## 6. Conformance levels

| Level | Meaning |
| --- | --- |
| `L0 documented` | Product class, ownership, primary goal, and honest exclusions are recorded. |
| `L1 structured` | MoonBit packages, schemas, pack/adapter boundaries, and UI source follow this standard. |
| `L2 usable` | The ordinary user can finish one primary workflow and recover from its common blocked state. |
| `L3 integrated` | A typed handoff and correlated receiver receipt complete through another product and survive restart. |
| `L4 production` | Licensed providers/data, customer or operational acceptance, signed distribution, and lifecycle evidence are current. |

An expected denial may prove safety but cannot by itself satisfy `L2` or `L3`.
A rendered multi-stage canvas does not prove its stages executed.

## 7. Proportional verification

For a second-iteration product change, validate once after the complete slice:

```sh
moon check --target native
moon test <changed-package> --target native
moon info
moon fmt
```

For a visible workflow, retain one UI-to-UI record containing the product
heads, launch commands, isolated data root, start/action/result screenshots,
console and failed-request observations, and correlated receipts. Exercise the
ordinary success path when its prerequisites exist, one meaningful denial,
and one recovery path. Do not convert missing providers, customer acceptance,
physical authority, or commercial evidence into fixture success.
