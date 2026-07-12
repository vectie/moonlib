///|
fn digest(char : String) -> String {
  "sha256:" + char.repeat(64)
}

///|
test "disclosure changes presentation but has stable portable ids" {
  assert_eq(DisclosureLevel::User.id(), "user")
  assert_true(disclosure_level_from_id("operator") == Operator)
  assert_true(disclosure_level_from_id("developer") == Developer)
}

///|
test "browser operations map to constitutional authority" {
  assert_true(BrowserOperation::RenderLocal.required_authority() == Observe)
  assert_true(
    BrowserOperation::InteractLocal.required_authority() == SandboxExecution,
  )
  assert_true(
    BrowserOperation::SaveWorkspace.required_authority() == WorkspaceMutation,
  )
  assert_true(
    BrowserOperation::SubmitExternal.required_authority() == ExternalEffect,
  )
  assert_true(
    BrowserOperation::ControlPhysicalDevice.required_authority() ==
    PhysicalEffect,
  )
}

///|
test "book-local browser scope rejects ambient network and path escape" {
  let scope : BrowserSessionScope = {
    contract_id: "moonsuite.browser-session.v1",
    session_id: "session-1",
    book_id: "book-1",
    book_revision: "r1",
    code_revision: "sha256:code-r1",
    run_id: "run-1",
    artifact_id: "app-1",
    authority_envelope_id: "envelope-1",
    origin_class: "book-local",
    network_policy: "offline",
    allowed_origins: ["https://example.com"],
    allowed_operations: [RenderLocal],
    upload_artifact_refs: ["../secret"],
    download_root: "/tmp/downloads",
    storage_lifetime: "run",
    capability_digest: digest("a"),
    expires_at: "2026-07-13T12:00:00Z",
  }
  let issues = scope.quality_issues()
  assert_true(
    issues.contains("book-local sessions cannot allow network origins"),
  )
  assert_true(
    issues.contains("upload artifact refs must be workspace-relative"),
  )
  assert_true(issues.contains("download_root must be workspace-relative"))
}

///|
test "external and physical browser actions require authority receipts" {
  let receipt : BrowserActionReceipt = {
    contract_id: "moonsuite.browser-action-receipt.v1",
    receipt_id: "receipt-1",
    session_id: "session-1",
    action_id: "action-1",
    actor_kind: Agent,
    actor_id: "agent-1",
    operation: SubmitExternal,
    semantic_target: "button Submit",
    redacted_arguments: ["text=<redacted>"],
    expected_observation: "success confirmation is visible",
    authority_decision_ref: "",
    before_digest: digest("b"),
    after_digest: digest("c"),
    outcome: "accepted",
    observations: ["confirmation visible"],
    evidence_refs: ["books/book-1/evidence/action-1.json"],
    completed_at: "2026-07-13T12:01:00Z",
  }
  assert_true(
    receipt
    .quality_issues()
    .contains("consequential browser operations require an authority decision"),
  )
}

///|
test "styled representations cannot enter engineering or manufacturing lanes" {
  assert_true(
    representation_transition_issues(VisualStyledModel, EngineeringModel).contains(
      "styled geometry cannot become an engineering input",
    ),
  )
  assert_true(
    representation_transition_issues(VisualStyledModel, ManufacturingCandidate).contains(
      "manufacturing candidates must descend from engineering models",
    ),
  )
  assert_true(
    representation_transition_issues(EngineeringModel, ManufacturingCandidate).is_empty(),
  )
}

///|
test "visual artifact rejects engineering consumers and physical claims" {
  let manifest : SpatialArtifactManifest = {
    contract_id: "moonmold.spatial-artifact.v1",
    artifact_id: "building-visual-r1",
    project_id: "building-1",
    representation: VisualStyledModel,
    parent_artifact_ids: ["building-editable-r1"],
    digest: digest("d"),
    payload_ref: "books/building/models/visual-r1.glb",
    units: "m",
    coordinate_system: "right-handed-z-up",
    up_axis: "z",
    handedness: "right",
    source_refs: ["books/building/references/front.png"],
    backend_id: "blender",
    backend_version: "4",
    procedure_ref: "books/building/procedures/style-v1.json",
    assumptions: [],
    unresolved_gaps: [],
    validation_refs: ["books/building/evidence/visual-r1.json"],
    intended_consumers: ["moontown", "moonrobo"],
    forbidden_consumers: ["moonrobo", "moonmoon", "fabrication"],
    claim_ceiling: PhysicalEffectClaim,
    recorded_at: "2026-07-13T12:02:00Z",
  }
  let issues = manifest.quality_issues()
  assert_true(
    issues.contains(
      "styled geometry cannot be an engineering or simulation input",
    ),
  )
  assert_true(
    issues.contains("digital spatial artifacts cannot claim physical effects"),
  )
}

///|
test "accepted engineering transform has immutable lineage fields" {
  let transform : RepresentationTransform = {
    contract_id: "moonmold.representation-transform.v1",
    transform_id: "transform-engineering-to-manufacturing-r1",
    parent_artifact_id: "building-engineering-r1",
    parent_digest: digest("e"),
    parent_representation: EngineeringModel,
    child_artifact_id: "building-manufacturing-r1",
    child_digest: digest("f"),
    child_representation: ManufacturingCandidate,
    operation: "prepare-manufacturing-candidate",
    parameters_digest: digest("1"),
    tool_id: "moonmold-fixture",
    tool_version: "0.1.0",
    authority_ref: "authority-workspace-r1",
    declared_losses: ["visual materials omitted"],
    validation_refs: ["books/building/evidence/manufacturing-r1.json"],
    recorded_at: "2026-07-13T12:03:00Z",
  }
  assert_true(transform.quality_issues().is_empty())
}
