///|
test "canonical operation and schema identities round-trip exactly" {
  let operation = @capability.parse_operation_ref(
    "moonmold/spatial.operation.execute@0.2.0",
  )
  assert_eq(operation.product_id(), "moonmold")
  assert_eq(operation.tool_id(), "spatial.operation.execute")
  assert_eq(operation.pack_version(), "0.2.0")
  assert_eq(operation.format(), "moonmold/spatial.operation.execute@0.2.0")
  let schema = @capability.schema_ref(
    "moonmold", "spatial-operation-receipt", "1.0.0",
  )
  assert_eq(schema.format(), "moonmold/spatial-operation-receipt@1.0.0")
  assert_true(
    @capability.operation_ref_is_canonical(
      "moonbook/bookkeeper.outcome.close@0.1.0",
    ),
  )
  assert_true(
    @capability.schema_ref_is_canonical(
      "moonbook/bookkeeper-product-outcome-closure@1.0.0",
    ),
  )
}

///|
test "canonical identities reject ambiguous separators and versions" {
  for
    value in [
      "moonmold/spatial.operation.execute", "moonmold/spatial.operation.execute@00.2.0",
      "moonmold//spatial.operation.execute@0.2.0", "moonmold/spatial.operation.execute@0.2.0/extra",
      "moonmold/../operation@0.2.0", "/operation@0.2.0",
    ] {
    assert_false(@capability.operation_ref_is_canonical(value))
  }
  assert_false(
    @capability.schema_ref_is_canonical(
      "moonmold/spatial-operation-receipt@1.0",
    ),
  )
}

///|
test "content-addressed evidence binds a relative artifact to exact bytes" {
  let digest = "sha256:" + "a".repeat(64)
  let evidence = @capability.content_addressed_evidence_ref(
    ".moonsuite/products/moonmold/adapter-health/health.json", digest,
  )
  assert_eq(evidence.evidence_digest(), digest)
  assert_true(evidence.conformance_issues().is_empty())
  assert_true(
    @capability.evidence_artifact_ref_is_canonical(
      "books/*/records/evidence.json",
    ),
  )
  assert_false(
    @capability.evidence_artifact_ref_is_canonical("../outside.json"),
  )
  assert_false(
    @capability.sha256_digest_is_canonical("sha256:" + "A".repeat(64)),
  )
}
