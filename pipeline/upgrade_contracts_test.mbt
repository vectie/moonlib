///|
test "constitutional contract ids are unique and versioned" {
  let ids : Array[String] = []
  for kind in @pipeline.contract_kinds() {
    let id = kind.id()
    assert_false(ids.contains(id))
    assert_true(id.has_suffix(".v1"))
    ids.push(id)
  }
  assert_eq(ids.length(), 19)
}

///|
test "authority ordering is explicit and physical effects require a human" {
  assert_true(AuthorityClass::WorkspaceMutation.allows(SandboxExecution))
  assert_false(AuthorityClass::SandboxExecution.allows(WorkspaceMutation))
  assert_true(AuthorityClass::ExternalEffect.requires_explicit_human())
  assert_true(AuthorityClass::PhysicalEffect.requires_explicit_human())
  assert_false(AuthorityClass::CognitiveMaintenance.requires_explicit_human())
}

///|
test "declarations compile deterministically into dependency linked work" {
  let research = ExecutableDeclaration::{
    declaration_id: "research-terrain",
    book_id: "selene-crater-service-rover",
    revision: "r1",
    kind: Research,
    title: "Research terrain",
    statement: "Collect traceable terrain evidence.",
    executor_product: "moonwiki",
    requires: [],
    acceptance_criteria: ["source digest is present"],
    requested_authority: Observe,
  }
  let experiment = ExecutableDeclaration::{
    declaration_id: "qualify-route",
    book_id: "selene-crater-service-rover",
    revision: "r1",
    kind: Experiment,
    title: "Qualify route",
    statement: "Compute every path edge independently.",
    executor_product: "moonmoon",
    requires: ["research-terrain"],
    acceptance_criteria: ["every edge is within the declared slope limit"],
    requested_authority: SandboxExecution,
  }
  let graph = @pipeline.compile_work_graph(
    "flow-selene-r1",
    "selene-crater-service-rover",
    "r1",
    [research, experiment],
    "2026-07-11T00:00:00Z",
  )
  assert_true(graph.quality_issues().is_empty())
  assert_eq(graph.items[1].depends_on[0], "work-research-terrain")
  json_inspect(graph.runnable_item_ids(), content=["work-research-terrain"])
}

///|
test "work graph rejects missing dependencies and cycles" {
  let base = WorkItem::{
    work_item_id: "work-a",
    declaration_id: "a",
    product_id: "moonwiki",
    status: Waiting,
    depends_on: ["work-b"],
    input_artifacts: [],
    output_artifacts: [],
    requested_authority: Observe,
    attempt_count: 0,
    blocker: "",
  }
  let cycle = WorkItem::{
    ..base,
    work_item_id: "work-b",
    declaration_id: "b",
    depends_on: ["work-a"],
  }
  let graph = WorkGraph::{
    graph_id: "cycle",
    book_id: "book",
    declaration_revision: "r1",
    items: [base, cycle],
    recorded_at: "2026-07-11T00:00:00Z",
  }
  assert_true(
    graph.quality_issues().contains("work graph contains a dependency cycle"),
  )
}

///|
test "Bookkeeper reflection requires action for an execution gap" {
  let gap = KnowledgeGap::{
    gap_id: "gap-route-action",
    book_id: "selene-crater-service-rover",
    kind: ExecutionGap,
    question: "What should happen after the route exceeds the slope gate?",
    required_by: ["route-acceptance"],
    current_evidence: ["terrain-edge-17"],
    missing: "A connected safe-path candidate and independent revalidation.",
    urgency: "blocking",
    resolution_criteria: [
      "candidate path is connected", "all edges are recomputed",
    ],
    status: "open",
    recorded_at: "2026-07-11T00:00:00Z",
  }
  let reflection = BookkeeperReflection::{
    reflection_id: "reflection-route-1",
    book_id: "selene-crater-service-rover",
    trigger: "experiment-failed",
    observations: ["one terrain edge exceeds the declared slope gate"],
    gaps: [gap],
    belief_updates: [],
    proposed_actions: [],
    learned_procedures: [],
    confidence: 0.98,
    uncertainty: [],
    requested_authority: CognitiveMaintenance,
    recorded_at: "2026-07-11T00:00:00Z",
  }
  assert_true(
    reflection
    .quality_issues()
    .contains("execution gaps require at least one proposed action"),
  )
}

///|
test "learned procedures reject overfit memories without applicability" {
  let procedure = LearnedProcedure::{
    procedure_id: "qualify-route",
    book_id: "selene-crater-service-rover",
    title: "Qualify a mission-specific route",
    applicability: [],
    steps: [
      "preserve the failed global claim", "recompute every candidate edge",
    ],
    verification_criteria: ["all declared gates are evaluated"],
    failure_modes: ["copying a previous route without recomputation"],
    counterexamples: [],
    evidence_refs: ["episode-selene-1"],
    status: "candidate",
    recorded_at: "2026-07-11T00:00:00Z",
  }
  assert_true(
    procedure.quality_issues().contains("procedure applicability is required"),
  )
}
