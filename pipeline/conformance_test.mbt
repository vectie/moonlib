///|
fn moonrobo_boundary() -> ProductBoundary {
  {
    product_id: "moonrobo",
    owner: "robot identity, digital build, and safety validation",
    operations: ["build-design", "validate-design"],
    allowed_authorities: [Observe, SandboxExecution],
    input_contracts: ["moonsuite.robot-design.v1"],
    output_contracts: ["moonsuite.run-receipt.v1"],
    claim_ceiling: DigitalArtifact,
    prohibited_claims: [PhysicalReadiness, PhysicalEffectClaim],
  }
}

///|
fn qualified_subject() -> ConformanceSubject {
  {
    subject_id: "work-build-rover",
    product_id: "moonrobo",
    operation: "build-design",
    requested_authority: SandboxExecution,
    input_contracts: ["moonsuite.robot-design.v1"],
    output_contracts: ["moonsuite.run-receipt.v1"],
    claim: DigitalArtifact,
    criteria: [
      {
        criterion_id: "design-is-typed",
        owner_product_id: "moonrobo",
        required_claim: DigitalArtifact,
        negative_path_required: true,
        evidence_refs: ["books/robot/evidence/build.json"],
      },
    ],
    negative_path_count: 2,
    execution_succeeded: true,
    accepted: true,
    acceptance_review_ref: "books/robot/reviews/build.json",
    workspace_root: "/Users/example/moonsuite",
    artifact_paths: ["books/robot/evidence/build.json"],
  }
}

///|
test "qualified product-owned digital work passes constitutional conformance" {
  let report = validate_constitutional_conformance(
    [moonrobo_boundary()],
    qualified_subject(),
    "report-build-rover",
    "2026-07-12T09:00:00Z",
  )
  assert_true(report.accepted)
  assert_true(report.findings.is_empty())
}

///|
test "conformance rejects downstream criteria physical overclaim and hidden acceptance" {
  let subject = {
    ..qualified_subject(),
    claim: PhysicalReadiness,
    criteria: [
      {
        criterion_id: "lunar-performance-proven",
        owner_product_id: "moonmoon",
        required_claim: ScenarioQualified,
        negative_path_required: true,
        evidence_refs: [],
      },
    ],
    negative_path_count: 0,
    acceptance_review_ref: "",
    artifact_paths: ["../outside/result.json"],
  }
  let report = validate_constitutional_conformance(
    [moonrobo_boundary()],
    subject,
    "report-overclaim",
    "2026-07-12T09:01:00Z",
  )
  assert_false(report.accepted)
  let codes = report.findings.map(finding => finding.code)
  assert_true(codes.contains("claim-ceiling-exceeded"))
  assert_true(codes.contains("prohibited-claim"))
  assert_true(codes.contains("criterion-owned-by-another-product"))
  assert_true(codes.contains("criterion-requires-downstream-claim"))
  assert_true(codes.contains("missing-negative-path"))
  assert_true(codes.contains("accepted-criterion-without-evidence"))
  assert_true(codes.contains("acceptance-without-review"))
  assert_true(codes.contains("workspace-artifact-escape"))
}

///|
test "simulation evidence cannot grant physical-effect authority" {
  let subject = {
    ..qualified_subject(),
    requested_authority: PhysicalEffect,
    claim: SimulationEvidence,
    accepted: false,
    acceptance_review_ref: "",
  }
  let report = validate_constitutional_conformance(
    [moonrobo_boundary()],
    subject,
    "report-physical-authority",
    "2026-07-12T09:02:00Z",
  )
  let codes = report.findings.map(finding => finding.code)
  assert_true(codes.contains("authority-not-allowed"))
  assert_true(codes.contains("claim-ceiling-exceeded"))
  assert_true(codes.contains("simulation-cannot-authorize-physical-effect"))
}
