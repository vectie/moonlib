# MoonSuite second-iteration product conformance

Date: 2026-07-31

Governing standard: `PRODUCT_IMPLEMENTATION_STANDARD_V2.md`

This record evaluates product shape and user-facing behavior separately from
production maturity. A clean journey or a valid desired graph is not evidence
that live providers, external effects, or paid-customer outcomes exist.

## Product classification

| Product | Primary class | User-facing surface | Runtime boundary |
| --- | --- | --- | --- |
| MoonBook | Domain pack | Book and Bookkeeper Rabbita UI | Uses MoonClaw; owns accepted book truth and Three-Gap closure. |
| MoonCast | Domain pack | Production studio and cut editor | Uses MoonClaw/MoonFlow; owns AIGC production state, gates, assets, cuts, and delivery evidence. |
| MoonChat | Library/functionality | Embedded review projection only | Creates no application or runtime. |
| MoonClaw | Platform service | Agent-work operator UI | Sole agent runtime. |
| MoonDesk | Application | Suite workspace and canvas | Hosts products; creates no second runtime or domain policy. |
| MoonEdit | Library/functionality | Host-owned editor surface | Owns deterministic editor state, not persistence or UI. |
| MoonFind | Domain pack | Research studio | Owns cited research and portable handoffs; uses MoonClaw for agent work. |
| MoonFish | Domain pack | Daily research and paper-portfolio UI | Owns securities policy and evidence; never becomes autonomous trading authority. |
| MoonFlow | Platform service | Projected by MoonDesk and CLIs | Owns orchestration state, never agent reasoning or domain policy. |
| MoonGate | Platform service and operator application | Provider/authority operations | Owns provider and authority truth. |
| MoonLeaf | Library/functionality | Host-owned document preview/edit surface | Owns bounded OOXML parsing/editing, not an Office clone. |
| MoonLib | Library/functionality | None | Owns shared typed contracts and standards only. |
| MoonMold | Domain pack | Spatial/modeling Rabbita UI | Owns governed digital geometry, not simulation or physical execution. |
| MoonMoon | Domain pack | Simulation cockpit | Owns simulation and calibrated digital-twin evidence. |
| MoonProj | Domain pack | Project/program Rabbita UI | Owns program plans, milestones, risk, and review artifacts. |
| MoonRobo | Domain pack | Robot cockpit | Owns the governed digital-to-device boundary; physical effects remain separately authorized. |
| MoonStat | Retired migration alias | None | MoonGate is the sole canonical successor. |
| MoonTown | Domain pack | Civic/spatial town UI | Owns civic participant and synthesis experiences, not generic execution. |
| MoonVis | Domain pack | Asset Rabbita UI | Owns versioned visual assets, lineage, and bounded resolution. |

Development worktrees and format-specific branches such as
`moondesk-moonedit`, `moonedit-browser`, and `moonleaf-docx` are not separate
products and are not scored independently.

## Structure result

The shared rule is consistent ownership, not identical folders. Installable
domain packs use manifests, schemas, adapters, workflows, product packages,
and Rabbita applications where applicable. Platform services keep generic
runtime packages and thin composition roots. Libraries intentionally omit
pack, adapter, workflow, and standalone-UI directories when those would create
a false capability surface.

The second iteration adds or aligns product contracts,
`RESPONSIBILITY_AND_TESTABILITY.md`, visible UI-to-UI qualification records,
and cohesive package-local journey modules. Remaining large historical files
are migration debt, not a reason to create new cross-product ownership. Future
splits must follow responsibility boundaries and preserve public package APIs.

## UX result

Visible products now use the same interaction grammar while retaining their
identity:

1. the first viewport names the user outcome;
2. a short icon-led rail shows progress;
3. one safe next action dominates;
4. evidence and advanced controls use progressive disclosure;
5. blockers name the missing fact and a recovery action;
6. consequential controls preserve short text labels, keyboard focus,
   accessible names, 44-pixel targets, and reduced-motion behavior.

MoonTown is the quality reference for clarity and feedback, not a stylesheet
or brand copied into every product.

## New series case

`Lunar Habitat Decision Series` is the second workflow family after the
humanoid-research composition. It begins with an owner commission and moves
through cited research, governed planning, a MoonMold habitat model, MoonMoon
simulation, MoonRobo digital-readiness observation, MoonVis assets, a bounded
MoonCast internal animatic, named review, and MoonBook Bookkeeper closure.

The six visible phases are **Understand**, **Research**, **Plan**, **Model**,
**Explain**, and **Decide & learn**. The 38-stage record is a versioned desired
capability graph. It deliberately excludes securities research, physical robot
command, publication, and commercial-master authority. MoonFlow may start an
executable run only after every exact operation, schema, adapter-health,
authority, claim, and acceptance binding projects successfully.

The second design replaced an invalid shortcut through MoonCast. The series
now models approved intake, separate brief/rights/bible/script/claims/storyboard
reviews, three reusable-asset paths, sandbox-authorized animatic rendering, and
a MoonChat owner decision. It does not invoke a client portal because no
delivery master exists.

The graph deliberately requests one unpublished MoonCast intake-and-seed
operation so that the first real capability projection fails at the honest
missing seam. MoonFlow also does not yet preserve the per-stage binding metadata
or auxiliary authority/QC artifacts required by MoonCast. Therefore this
iteration qualifies the catalog, UX, and expected blocker—not cross-product
execution.

## Conformance interpretation

| Level | Current interpretation |
| --- | --- |
| L0 documented | All canonical active products have a declared class and ownership boundary; MoonStat is explicitly retired. |
| L1 structured | Second-iteration products have aligned docs and cohesive journey modules; historical large-file cleanup remains incremental. |
| L2 usable | Claimed only per visible workflow after focused rendered qualification. Library-only products satisfy consumer-contract tests instead. |
| L3 integrated | Claimed only for an exact correlated receiver receipt that survives restart; a catalog card, route link, or expected denial is insufficient. |
| L4 production | Not established suite-wide. Licensed/live providers, signed distribution, operational installation, and commercial acceptance remain product-specific gates. |

## Scorecard interpretation

The second feature iteration changes the scorecard as follows. Scores reflect
working product surfaces and retained evidence, not the amount of code or the
number of modeled stages.

| Area | Before | After | Assessment after iteration two |
| --- | ---: | ---: | --- |
| Agent runtime, evidence, authority | 8/10 | 8/10 | Still the strongest part. MoonClaw remains the sole agent runtime and evidence/authority contracts remain strong; no new multi-user, clean-machine, or soak proof justifies a higher score. |
| Domain modeling | 7/10 | 8/10 | MoonCast's production graph, MoonFish's target/upside/sale-window model, Bookkeeper Three-Gap closure, and the 38-stage lunar series materially deepen typed domain behavior. |
| Pack architecture | 6/10 | 7/10 | Canonical products now declare one of four exact classes and have clearer ownership, structure, and testability maps. Adapter layout and historical-module cleanup remain uneven. |
| User-facing applications | 5/10 | 6/10 | Major applications now share outcome-first rails, one safe next action, semantic icons, explicit recovery, focus behavior, and reduced motion. Only the new MoonFind series received a retained rendered pass, so suite-wide visual maturity is not yet 7/10. |
| Cross-product execution | 3/10 | 5/10 | Genuine typed slices exist and 20 of the lunar graph's 21 unique desired operations are published exactly. The full graph still cannot execute because MoonFlow lacks generic binding, auxiliary-input, health, driver, and receipt projection. |
| Live providers and real-world data | 3/10 | 3/10 | Live ports exist, but production acceptance remains dominated by fixtures or unqualified data. No licensed MoonFish history, accepted real-provider MoonCast episode, or qualified robot path was added. |
| Installation and operations | 2/10 | 3/10 | Atomic pack activation/rollback and local packaging evidence are real gains. Release remains no-go without notarization, clean-machine lifecycle proof, hosted updates, and soak operation. |
| Commercial validation | 2/10 | 2/10 | Economics are modeled, but there is still no retained paid repeat order, accepted real-provider episode, or proven after-cost investment edge. |

The honest summary is **better products and clearer composition, but not yet a
production or commercial breakthrough**. The largest real gains are domain
modeling, consistent pack boundaries, ordinary UI journeys, and exact
cross-product capability visibility. Live acceptance and paid repeatability
remain the controlling gaps.

## Qualification record

The consolidated pass records:

- changed-package MoonBit checks and focused assertions;
- one structure/whitespace audit across touched repositories;
- one rendered MoonFind UI-to-UI journey for the lunar-habitat series;
- scenario visibility, next-action behavior, explicit limits, refresh
  recovery, console errors, failed requests, and correlated IDs;
- an independent operation/schema/claim audit for all 38 desired stages,
  including the deliberate missing intake-and-seed capability.

The retained rendered record is
`moonfind/docs/qualification/LUNAR_HABITAT_DECISION_SERIES_RUN_2026-07-31.md`.
It passes catalog visibility, goal clarity, phase navigation and reload,
explicit limits, the read-only first action, and the MoonDesk context handoff
with no console warnings or errors. Full execution is **EXPECTED BLOCKED** at
the deliberately unpublished MoonCast intake-and-seed operation and the
generic MoonFlow binding gaps listed in that record.
