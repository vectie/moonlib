# MoonSuite platform iteration 3 qualification

Date: 2026-07-31

Result: locally qualified in the scopes named below

Production result: not qualified

## Decision

Iteration 3 delivers all eight approved directions as local, typed product
capabilities. The result is not one suite-wide end-to-end or production pass.
Each row below states the narrower boundary that was actually exercised.

`Locally qualified` means the relevant MoonBit contracts compile, focused
deterministic tests pass, and the named local UI behavior was observed where a
browser result is recorded. It does not establish live-provider quality,
licensed data, paid-customer acceptance, signed distribution, multi-host
identity, publication, trading, fabrication, or physical authority.

## Eight delivered outcomes

| # | Approved direction | Delivered result | Qualification boundary |
| ---: | --- | --- | --- |
| 1 | More templates | MoonDesk owns generic `moonsuite.template-envelope.v1`, catalog, and instance schemas. MoonTown publishes six civic templates and MoonFind publishes one cross-product series. Catalog, source, and qualification-evidence bytes are SHA-256 bound; maturity, migration, ceilings, recovery, and owner identity are explicit. MoonDesk renders seven owner-authored templates through one generic gallery. | `LOCALLY QUALIFIED` for verified discovery and pinned owner preview. Selecting a card does not yet create a `moonsuite.template-instance.v1` or start work. MoonTown and MoonFind therefore say review/preview, not start. |
| 2 | Performance benchmark | MoonGate publishes a replayable deterministic workload/report and a separately typed, bounded live-benchmark request/result boundary. Fixture reports say `deterministic-fixture`, `live_provider: false`, and never claim provider performance. | `LOCALLY QUALIFIED` for deterministic gateway-contract evidence. Live execution fails closed until fresh authority verification and a real adapter/provider are installed. |
| 3 | Integrate MoonTown into MoonDesk | MoonTown is launched through MoonDesk's generic installed-pack app surface. MoonTown owns its query/default seed and all civic state. Exercised request, standing-goal, and book-registration paths use `moontown.api.v1`; MoonDesk no longer writes a second Town ledger. | `LOCALLY QUALIFIED` for hosting, context, and ownership boundaries. A complete Town request → Flow execution → receiver receipt → Bookkeeper acceptance browser journey was not rerun for this iteration. |
| 4 | More monitoring in MoonGate | Typed operations telemetry records correlated stages, terminal outcome, latency/first-token/permit-wait percentiles, throughput, tokens, cost, capacity, quota, circuit, failover, storage, and evidence freshness. Unsupported observations remain explicit rather than becoming misleading zeroes. | `LOCALLY QUALIFIED` for recorded local evidence and deterministic percentile behavior. It is not a production observability/soak result and high-cardinality identities remain outside metric labels. |
| 5 | Load balancing in MoonGate | Versioned priority, smooth weighted round-robin, least-inflight, and session-sticky policies first produce shadow decisions. Eligibility checks health, model/protocol support, credentials, quota, budget, circuit, and concurrency. Activation/rollback bind MoonLib principal and authority references and emit receipts. | `LOCALLY QUALIFIED` for deterministic selection, denial, shadow, bounded canary, activation, and rollback policy. No live traffic canary or provider-cost optimization was run. |
| 6 | Typed correctness | MoonLib 0.1.18 is the sole policy-free owner of canonical principal, workspace, correlation, contract, schema, digest, operation, delegation, authority-decision, evidence, bundle, and handover-control references. Unknown or incompatible values and tampered digests fail closed. | `LOCALLY QUALIFIED` in the multi-repository workspace. MoonLib 0.1.18 still needs publication before downstream repositories resolve it independently. |
| 7 | Multi-person system | MoonFlow owns durable workspace membership, assignment, claim/lease, anchored comment and typed mention, independent human review, expected-head conflict, idempotency, replay, writer locking, and atomic replacement. MoonDesk presents a generic read-only People, Assignments, Review inbox, and Comments projection. | `LOCALLY QUALIFIED` for typed local state and owner-validated projection. It is asynchronous v1, not real-time co-editing or a production authenticated multi-host service. Mutations remain in MoonFlow. |
| 8 | Export and agent handover | MoonLib separates immutable portable evidence bundles from responsibility-transfer control. MoonFlow owns `apply`, `inspect`, and `list`, lifecycle replay, expiry, fresh receiver authority, and quarantine. MoonDesk shows owner-validated handover catalog rows and preserves invalid snapshots as quarantined. MoonBook binds a completed handover to the exact deliverable, human review, outcome, and Three-Gap closure; MoonClaw narrows child-agent delegation. | `LOCALLY QUALIFIED` for contracts, lifecycle policy, durable replay, and read-only observability. Cryptographic signature verification is host-owned; no external destination, cross-host import/resume, or real provider was qualified. |

## Consolidated implementation evidence

The following results are deliberately scoped. A package result is not a claim
that every repository or every product journey passed.

| Repository and scope | Result |
| --- | --- |
| MoonLib collaborative wire contracts | 9/9 focused tests passed; capability check completed with 0 errors. |
| MoonFlow collaboration/handover core | 2/2 focused tests passed; collaboration package and CLI checks completed with 0 errors. |
| MoonGate telemetry, benchmark, and routing | 25/25 focused tests passed; native check completed with 0 errors. |
| MoonClaw metered delegation seam | 1/1 focused test passed; job package check completed with 0 errors. The broader unrelated `Manager::spawn` abort remains recorded below. |
| MoonBook Bookkeeper integration | 49/49 focused tests passed; Bookkeeper check completed with 0 errors. |
| MoonTown owner API, catalog, and preview | 1028/1028 tests passed. |
| MoonFind series/catalog integration | 32/32 tests passed; check completed with 0 errors. |
| MoonDesk before the final bounded handover/browser repair | 351/351 tests passed; root check completed with 0 errors. |
| Final MoonDesk handover/browser repair | Backend regressions 2/2 and Rabbita UI regression 1/1 passed; root and nested Rabbita checks completed with 0 errors. A second broad 351-test run was intentionally not repeated after this bounded change. |

Catalog qualification also recomputed, rather than trusting declarations:

- MoonTown catalog digest, all six source digests, and its qualification-report
  digest matched the exact files.
- MoonFind catalog digest, Lunar Habitat source digest, and qualification-report
  digest matched the exact files.
- Changed JSON manifests, catalogs, sources, and schemas parsed successfully.
- `git diff --check` passed in all eight changed repositories: MoonLib,
  MoonFlow, MoonClaw, MoonBook, MoonGate, MoonTown, MoonFind, and MoonDesk.
- No changed or newly added Python file was found in those eight worktrees.

One local MoonFlow collaboration demonstration advanced through the owner CLI
to three members, one assignment, one anchored comment, one requested review,
and six retained events. Its validated head was
`sha256:4f998e4cc68a0d5d8411510375ac8268037d548ad2074381f9bdadc565783158`.
This is durable local contract evidence, not an authenticated multi-user
session. The built MoonDesk UI subsequently projected the same three people,
assignment, anchored comment, and independent review without writing MoonFlow
state itself.

## Browser qualification and two repaired defects

The iteration-specific browser pass exercised the built MoonDesk, MoonTown,
and MoonGate applications. It found two real UI-boundary defects; both were
fixed before this qualification was recorded.

### 1. Literal count interpolation

Observed defect: Rabbita rendered source-like interpolation text instead of
numbers for template and collaboration counts.

Repair: seven affected expressions in `pack_home_views.mbt` and
`collaboration_surface_views.mbt` were converted to actual string
interpolation. The browser then displayed numeric values for seven available
templates, two installed owner packs, and zero collaboration records (`7/2/0`).

### 2. Optional recovery projection decoding

Observed defect: MoonDesk recovery responses emitted `snapshot: null` and
`handover_catalog: null`. Rabbita's optional decoder rejected those present
nulls, so the user saw a decode failure instead of the intended recovery state.

Repair: the server now omits projections that are unavailable. Focused backend
tests passed 2/2 and the UI regression passed 1/1. The browser now shows the
truthful **Collaboration is not initialized** state and the MoonFlow recovery
action; it does not fabricate an empty validated workspace.

No part of this browser pass created a template instance, mutated collaboration
through MoonDesk, executed a live-provider benchmark, activated a live route,
or completed an external handover. Earlier product UI-to-UI records remain
historical evidence and are not silently reclassified as Iteration 3 proof.

### 3. Digest-pinned MoonTown preview through MoonDesk

MoonDesk displayed two installed packs, one ready application, and seven
owner-authored templates. The policy-triage template opened the canonical
Energy Valley UI through MoonDesk's same-origin generic pack route with the
catalog ID, catalog version, catalog digest, template version, and source
digest pinned in context. Reload preserved the valid preview. A deliberately
tampered source digest was visibly rejected. The screen explicitly stated that
the selection was a preview and that instance creation was not implemented.
MoonDesk and MoonTown emitted no browser console errors during this journey.

### 4. Collaboration and quarantine projection

After the five typed MoonFlow mutations, MoonDesk displayed two humans, one
agent, the agent's exact MoonBook assignment, the anchored comment mentioning
the reviewer, and the independent review request. A deliberately malformed
handover file was returned by `moonflow handover list` as `quarantined` and
shown by MoonDesk with unavailable head and digest rather than fabricated
state. This proves owner-validated read-only projection, not authenticated
multi-user mutation from the browser.

### 5. Truthful MoonGate operations

The MoonGate Operations UI initially showed `No samples` for live latency and
`Not implemented` for unavailable inflight instrumentation. Running the
deterministic fixture displayed mode `deterministic-fixture`, claim ceiling
`gateway-contract-fixture`, fixture p95 `60 ms`, fixture throughput
`752.941 fixture tokens/s`, and `No provider request was timed`.

A smooth weighted round-robin policy was saved as shadow revision 1 and one
shadow decision was observed. Live routing remained on the priority default;
because no provider was configured, the shadow choice truthfully remained
`None`. No canary was activated and MoonGate emitted no browser console errors.

## Ownership and safety results

- MoonDesk hosts and projects generic state; it does not own template domain
  semantics, Town civic ledgers, Flow collaboration state, or authority.
- MoonTown remains the only writer of its operator requests, standing goals,
  and book registrations on the exercised paths.
- MoonFlow remains the cross-product scheduler and collaboration/handover
  owner. MoonClaw remains the only agent runtime.
- MoonGate routes provider/model requests; it does not schedule workflows or
  self-activate benchmark-derived weights.
- Selecting a template, discovering a capability, observing a benchmark, or
  receiving a handover never grants authority.
- A quarantined document or handover remains visible as invalid; it is never
  converted into an empty success record.

## Honest limitations and open gates

1. **Template execution is incomplete.** Discovery, byte verification, and
   pinned owner preview are present. Owner confirmation, instance persistence,
   compatibility preflight, reopen, and migration of a real template instance
   are still open.
2. **Live MoonGate evidence is absent.** No authorized live benchmark, traffic
   canary, provider-cost comparison, long-running telemetry soak, or production
   credentials were used.
3. **MoonTown's full round trip was not newly qualified.** Hosting and owner API
   boundaries pass locally, but this iteration did not browser-prove one new
   Town → Flow → receiving product → Bookkeeper closure.
4. **Collaboration UI is read-only.** MoonFlow CLI mutations are typed and
   durable, while MoonDesk currently observes them. Authenticated person-facing
   invite, assignment, comment, review, and conflict controls are a later UI
   layer.
5. **Handover visibility is summarized.** MoonDesk lists ID, state, head,
   envelope digest, and validity after collaboration validation. Detailed
   inspection, mutation, import, authority refresh, resume, and completion stay
   in MoonFlow. A handover-only workspace without initialized collaboration is
   not yet surfaced by MoonDesk.
6. **Cryptographic and distribution gates remain.** Signature metadata is
   typed, but hosts must verify it. No external export destination, notarized
   application, clean-machine lifecycle, or cross-host transfer was exercised.
7. **MoonClaw has an unrelated broad-test defect.** The focused delegation test
   and job check pass, but a broader pre-existing `Manager::spawn` abort remains
   unresolved and is not hidden by this qualification.
8. **Commercial and physical evidence remains independent.** This iteration
   proves no paid repeat order, market edge, licensed A-share feed, real-provider
   MoonCast episode, fabrication readiness, or robot movement authority.

## Promotion decision

Promote these features as **locally qualified alpha capabilities** with their
owner and claim ceilings intact. Do not label the suite production-ready and do
not promote fixture, local CLI, or browser recovery evidence into live-provider,
commercial, financial, publication, fabrication, or physical claims.
