# MoonSuite platform iteration 3

Date: 2026-07-31

Status: locally qualified in scoped tracks; production and full all-up gates remain open

## Outcome

This iteration turns the current collection of locally capable MoonSuite
products into one typed, observable, portable, and collaboration-ready system.
It delivers the eight approved product directions as three dependent programs:

```text
typed correctness
  -> truthful monitoring -> benchmark evidence -> controlled provider balancing
  -> MoonTown in MoonDesk -> qualified template portfolio
  -> portable handover -> asynchronous multi-person collaboration
```

The iteration does not claim live-provider quality, paid-customer acceptance,
physical authority, publication authority, or investment performance from a
fixture or rendered canvas.

The implementation and evidence decision is recorded in
[`MOONSUITE_PLATFORM_ITERATION_3_QUALIFICATION.md`](MOONSUITE_PLATFORM_ITERATION_3_QUALIFICATION.md).
The phase bodies below preserve the approved target architecture. This status
table states how far the current implementation actually reached; a partial
row must not be read as satisfying the phase's complete target exit.

| Track | Current status | Remaining boundary |
| --- | --- | --- |
| Phase 0 — truthful boundaries | `LOCALLY QUALIFIED` | Production reachability, clean-machine, and external-service evidence remain separate. |
| Phase 1 — typed correctness spine | `LOCALLY QUALIFIED` | Publish MoonLib 0.1.18 so downstream repositories resolve it without the local multi-repository workspace. |
| Phase 2 — MoonGate operations | `LOCALLY QUALIFIED` for deterministic telemetry, benchmark, routing, shadow, and fail-closed control | Authorized live benchmark, live canary/rollback, provider economics, and soak remain open. |
| Phase 3 — Town host and templates | `LOCALLY QUALIFIED` for generic hosting, owner API, verified catalog discovery, and pinned preview | Template instance creation/reopen/migration and one complete Town → Flow → receiver → Bookkeeper journey remain open. |
| Phase 4 — export and handover | `LOCALLY QUALIFIED` for typed bundle/control contracts, lifecycle replay, quarantine, and owner-validated listing | Host signature verification, external export, cross-host import/authority/resume, and complete UI journey remain open. |
| Phase 5 — asynchronous collaboration | `LOCALLY QUALIFIED` for durable typed local mutation and read-only MoonDesk projection | Authenticated multi-host people UI and a complete person A → reviewer B → receiver C → Bookkeeper browser journey remain open. |
| Consolidated iteration | `SCOPED LOCAL PASS` | It is not a suite-wide L3/L4 or production result. |

## Ownership boundaries

| Concern | Owner |
| --- | --- |
| Policy-free cross-product references, codecs, and compatibility vocabulary | MoonLib |
| Exact capability, provider, principal, delegation, and authority decisions | MoonGate |
| Durable graph state, assignment, leases, handover lifecycle, receipts, reconciliation, and restart | MoonFlow |
| Agent and child-agent execution inside one bounded work item | MoonClaw |
| Accepted knowledge, named review history, and Three-Gap closure | MoonBook Bookkeeper |
| Civic scenarios, participants, town state, and cross-book synthesis | MoonTown |
| Desktop presentation, pack hosting, template discovery, review, export, and import UX | MoonDesk |
| Template semantics and domain acceptance | The owning domain pack, MoonTown, MoonFind, or MoonBook |

MoonGate balances compatible provider/model requests only. MoonFlow schedules
workflow capacity. MoonTown schedules civic participants. MoonClaw must not
become a second cross-product scheduler, and MoonDesk must not write another
product's durable state directly.

## Phase 0 — remove false truth

1. Replace or explicitly downgrade MoonGate's synthetic endpoint-latency
   response. A syntactically valid URL must not be reported as a successful
   zero-millisecond network observation.
2. Make the MoonTown pack entrypoint query-free and let MoonTown own its default
   seed and view state.
3. Replace the exercised MoonDesk direct-write path into MoonTown ledgers with
   MoonTown's versioned API and correlated receipts.
4. Inventory duplicate reference, envelope, actor, and handover DTOs before
   introducing any new public contract family.

Exit: every visible health, timing, entrypoint, and ownership claim is true.

## Phase 1 — typed collaborative correctness spine

Add opaque, validated cross-product primitives only where at least two products
consume them:

- principal, workspace, contract, schema, version, digest, record, artifact,
  evidence, correlation, delegation, and authority-decision references;
- canonical encoding and digest golden vectors;
- explicit unknown-field and compatible-version rules;
- typed event-specific payloads instead of new public string bags.

The execution type-state is:

```text
Template definition
  -> pinned template instance
  -> resolved graph
  -> authorized run
  -> executed result
  -> named review
  -> accepted outcome
```

No transition may infer a capability, schema, artifact, authority, or review
from a friendly product name or UI route.

Exit: producer/consumer conformance fixtures reject incompatible versions,
tampered digests, stale authority, and self-review where independence is
required.

## Phase 2 — MoonGate observability, benchmarks, and routing

### Truthful telemetry

Record one correlated attempt timeline containing ingress, selection,
upstream-connect, first byte, first token, completion, retry/failover, terminal
status, tokens, estimated cost, selected policy version, and rejection reasons.

Expose bounded monitoring for:

- p50/p95/p99 total latency and time to first token;
- success, timeout, rate-limit, cancellation, and protocol-error rates;
- request/token throughput, inflight work, queue depth, and provider permits;
- quota headroom, cost burn, budget forecast, circuit transitions, failover
  chains, storage health, and evidence freshness.

High-cardinality request, session, prompt, and evidence identities remain in
redacted retained records, never metric labels.

### Benchmarks

Support two separately labelled modes:

1. deterministic mock-upstream benchmarks for MoonGate overhead and faults;
2. explicitly authorized live-provider benchmarks with a hard cost ceiling.

Workloads cover non-streaming, streaming, tool-call, and large-context shapes,
cold and warm paths, and bounded concurrency. Reports pin the build,
environment, workload, policy, provider/model, result distribution, errors,
throughput, and cost per accepted response.

### Controlled routing

Add versioned policies for priority failover, smooth weighted round-robin,
least-inflight, and session-sticky weighted routing. Eligibility precedes
scoring and requires protocol/model compatibility, credential reference,
fresh health, closed or permitted circuit state, quota, budget, and concurrency
capacity.

New routing runs in shadow mode first. Canary activation requires a named
operator receipt, a bounded traffic fraction, an evidence window, and immediate
rollback. Benchmark results never self-activate weights.

Exit: fault injection proves correct attribution, no duplicate accounting, no
leaked permits, and no retry after externally visible output.

## Phase 3 — MoonTown in MoonDesk and qualified templates

MoonDesk hosts MoonTown through the generic installed-pack application surface.
MoonTown keeps the full map, building behavior, requests, standing goals,
participants, and civic history. MoonDesk contributes only its compact host
bar, current workspace, service state, review notifications, and typed context.

Required round trip:

```text
MoonDesk opens current MoonTown map
  -> user selects a building or scenario
  -> MoonTown submits its own versioned request
  -> MoonFlow returns correlated progress/receipts
  -> MoonDesk links to evidence/review
  -> refresh and process restart recover both contexts
```

Template definitions use one common envelope but retain four semantic classes:

| Class | Semantic owner |
| --- | --- |
| Book template | MoonBook or the domain pack |
| Civic scenario | MoonTown |
| Cross-product series | MoonFind |
| Domain project | The owning pack |

Every definition pins owner, version, digest, user outcome, completion rule,
inputs/outputs, phases, exact operation/schema requirements, authority, effect,
cost, licensing and review ceilings, migration policy, preview, qualification
evidence, and maturity: `fixture`, `local-qualified`, `live-qualified`, or
`production`.

The initial portfolio is deliberately small:

1. recurring evidence watch;
2. cross-paper research and reviewed synthesis;
3. product/customer discovery;
4. MoonFish morning research and paper portfolio;
5. MoonCast branded 3–8 minute episode;
6. MoonMold → MoonMoon → MoonRobo readiness package;
7. lunar habitat decision;
8. governed incident/review council.

MoonDesk's ordinary flow is:

```text
New from template
  -> choose an outcome
  -> inspect what you provide / what it creates / approvals needed
  -> compatibility preflight
  -> enter missing information
  -> review immutable plan
  -> create pinned instance
  -> open the owning product
```

Exit: no template card is presented as executable or live when its exact
capabilities, providers, authority, or acceptance evidence are missing.

## Phase 4 — portable export and handover

Export and handover are distinct:

- export creates a read-only, content-addressed portable evidence bundle;
- handover offers responsibility for bounded continuation and requires a
  receiver decision and fresh authority.

A handover contains:

1. a sealed evidence bundle with canonical bytes, digests, provenance,
   lineage, data class, redaction, and no secrets;
2. an immutable control envelope with source/recipient principals, purpose,
   run/work/stage/attempt references, source/target operations and schemas,
   resumable checkpoint, open items, blockers, acceptance criteria, requested
   authority, review requirements, budgets, compatibility requirements, return
   destination, expiry, previous handover reference, and signature metadata.

Lifecycle:

```text
Draft -> Sealed -> Offered -> Accepted | Rejected | Expired
      -> Imported -> Resumed -> Completed
```

Import verifies digest/signature, schema and capability versions; quarantines
untrusted documents; resolves principal and membership; requests fresh
MoonGate authority; materializes contained paths; emits an idempotent receipt;
and lets MoonFlow resume. Handover transfers evidence and context, never
credentials or authority.

Exit: tamper, secret-bearing bundle, stale membership, unsupported schema,
expired offer, and duplicate import all fail safely and visibly.

## Phase 5 — asynchronous multi-person v1

The first collaboration release is intentionally asynchronous:

- authenticated principals and workspace membership;
- assignments and review inboxes;
- comments and mentions anchored to an exact record or artifact digest;
- claim/lease and optimistic `expected_head_digest`;
- explicit conflict receipts and immutable activity history;
- executor/reviewer separation where policy requires it;
- narrowed human-to-agent and parent-to-child-agent delegation.

Presence and soft locks may follow. Real-time CRDT document editing is deferred
until a concrete domain workflow proves it necessary. A display name or
reviewer string is not an authenticated principal, and a comment is not an
acceptance receipt.

Exit: person A commissions, a delegated agent executes, person B independently
reviews, person C imports/resumes on another workspace, and MoonBook closes the
accepted Three-Gap outcome. Restart, stale membership, self-review, conflict,
tamper, and denied authority paths are retained.

## Consolidated qualification

Testing happens after each complete track, followed by one all-up pass:

1. warning-clean checks and focused package tests for changed packages;
2. canonical wire/digest and producer-consumer compatibility fixtures;
3. MoonGate deterministic benchmark and routing shadow/canary/rollback case;
4. MoonDesk → MoonTown request → MoonFlow receipt → MoonBook review journey;
5. template create/reopen/upgrade-isolation journey;
6. export → quarantine/import → fresh authority → resume → independent review;
7. one bounded multi-person case and its principal negative paths;
8. restart recovery over the same durable roots;
9. screenshots, console/failed-request observations, exact build identities,
   receipts, and explicit external blockers.

The iteration is complete only when the ordinary journeys succeed through real
product boundaries. Expected denial proves safety but does not replace a
successful L2/L3 journey. Live-provider, licensing, physical-effect, financial,
and commercial promotion remain independent gates.
