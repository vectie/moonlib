///|
fn manifest_fixture() -> @capability.PackManifestProjectionV1 {
  {
    id: "moonmold",
    product_id: "moonmold",
    version: "0.2.0",
    schemas: [
      {
        id: "spatial-operation-request",
        version: "1.0.0",
        path: "schemas/spatial-operation-request.schema.json",
      },
      {
        id: "spatial-operation-receipt",
        version: "1.0.0",
        path: "schemas/spatial-operation-receipt.schema.json",
      },
    ],
    tools: [
      {
        id: "spatial.operation.execute",
        owner_product: "moonmold",
        input_schema_id: "spatial-operation-request",
        output_schema_id: "spatial-operation-receipt",
        authority: "workspace-mutation",
        idempotent: true,
        evidence_outputs: ["records/operations", "artifacts/models"],
        review_required: true,
      },
    ],
  }
}

///|
fn declaration_fixture() -> @capability.AdapterDeclarationV1 {
  {
    contract_id: @capability.adapter_declaration_contract_v1(),
    adapter_id: "moonmold-pack-local-v1",
    product_id: "moonmold",
    pack_id: "moonmold",
    pack_version: "0.2.0",
    protocol: "moonflow.adapter.v2",
    operations: [
      {
        operation_id: "spatial.operation.execute",
        claim_ceiling: "consumer-defined-claim",
        supports_cancel: false,
        supports_reconcile: true,
      },
    ],
  }
}

///|
fn health_fixture() -> @capability.AdapterHealthV1 {
  {
    contract_id: @capability.adapter_health_contract_v1(),
    adapter_id: "moonmold-pack-local-v1",
    product_id: "moonmold",
    pack_id: "moonmold",
    pack_version: "0.2.0",
    protocol: "moonflow.adapter.v2",
    status: "healthy",
    checked_at: "2026-07-31T00:00:00Z",
    valid_until: "2026-07-31T00:15:00Z",
    operation_refs: ["moonmold/spatial.operation.execute@0.2.0"],
    evidence_ref: ".moonsuite/products/moonmold/adapter-health/health.json",
    evidence_digest: "sha256:" + "b".repeat(64),
  }
}

///|
fn operation_fixture() -> @capability.CatalogOperationProjectionV1 {
  {
    operation_ref: "moonmold/spatial.operation.execute@0.2.0",
    product_id: "moonmold",
    pack_id: "moonmold",
    pack_version: "0.2.0",
    tool_id: "spatial.operation.execute",
    adapter_id: "moonmold-pack-local-v1",
    protocol: "moonflow.adapter.v2",
    authority: "consumer-defined-authority",
    input_schema_ref: "moonmold/spatial-operation-request@1.0.0",
    output_schema_ref: "moonmold/spatial-operation-receipt@1.0.0",
    claim_ceiling: "consumer-defined-claim",
    idempotent: true,
    review_required: true,
    supports_cancel: false,
    supports_reconcile: true,
    health_checked_at: "2026-07-31T00:00:00Z",
    health_valid_until: "2026-07-31T00:15:00Z",
    health_evidence_ref: ".moonsuite/products/moonmold/adapter-health/health.json",
    health_evidence_digest: "sha256:" + "b".repeat(64),
  }
}

///|
test "manifest and discovery DTOs serialize without deciding policy" {
  let manifest = manifest_fixture()
  let full_manifest = manifest.to_json()
  guard full_manifest is Object(full_manifest_fields) else {
    fail("manifest projection must encode as an object")
  }
  full_manifest_fields["display_name"] = Json::string("MoonMold")
  full_manifest_fields["kind"] = Json::string("DomainPack")
  full_manifest_fields["workflows"] = Json::array([])
  // Projection decoding intentionally ignores fields owned by the Pack SDK.
  assert_eq(
    @capability.decode_pack_manifest_projection_v1(full_manifest),
    manifest,
  )
  assert_eq(
    @capability.decode_pack_manifest_projection_v1(
      @capability.encode_pack_manifest_projection_v1(manifest),
    ),
    manifest,
  )
  let declaration = declaration_fixture()
  assert_eq(
    @capability.decode_adapter_declaration_v1(
      @capability.encode_adapter_declaration_v1(declaration),
    ),
    declaration,
  )
  let health = health_fixture()
  assert_eq(
    @capability.decode_adapter_health_v1(
      @capability.encode_adapter_health_v1(health),
    ),
    health,
  )
  let catalog : @capability.CapabilityCatalogProjectionV1 = {
    contract_id: @capability.capability_catalog_contract_v1(),
    catalog_id: "catalog-fixture-1",
    compiled_at: "2026-07-31T00:00:01Z",
    conformant: true,
    products: [
      { product_id: "moonmold", pack_id: "moonmold", pack_version: "0.2.0" },
    ],
    operations: [operation_fixture()],
    issues: [],
  }
  assert_eq(
    @capability.decode_capability_catalog_projection_v1(
      @capability.encode_capability_catalog_projection_v1(catalog),
    ),
    catalog,
  )
  // Unknown authority and claim strings remain wire data. Consumers own their
  // hierarchy and authorization decisions.
  assert_true(operation_fixture().conformance_issues().is_empty())
}

///|
test "health conformance records expiry but does not evaluate current time" {
  let unavailable = {
    ..health_fixture(),
    status: "unavailable",
    checked_at: "2026-07-31T00:00:00Z",
    valid_until: "2026-07-31T00:00:00Z",
    operation_refs: [],
  }
  assert_true(unavailable.conformance_issues().is_empty())
  let mismatched = {
    ..health_fixture(),
    operation_refs: ["moonrobo/robot.readiness.inspect@0.2.0"],
  }
  assert_true(
    mismatched
    .conformance_issues()
    .any(fn(issue) { issue.field == "operation_refs[0]" }),
  )
}

///|
fn request_fixture() -> @capability.AdapterRequestWireV1 {
  {
    request_id: "request-spatial-1",
    run_id: "run-spatial-1",
    book_id: "book-spatial-1",
    work_item_id: "work-spatial-1",
    declaration_id: "declaration-spatial-1",
    attempt_id: "attempt-spatial-1",
    idempotency_key: "run-spatial-1/work-spatial-1/1",
    product_id: "moonmold",
    operation: "moonmold/spatial.operation.execute@0.2.0",
    requested_authority: "workspace-mutation",
    acceptance_criteria: ["reviewed spatial result exists"],
    input_contracts: ["moonmold/spatial-operation-request@1.0.0"],
    output_contracts: ["moonmold/spatial-operation-receipt@1.0.0"],
    required_claim: "consumer-defined-claim",
    input_digest: "sha256:" + "c".repeat(64),
    input_artifacts: ["inputs/spatial-operation.json"],
    timeout_ms: 120000,
    created_at: "2026-07-31T00:01:00Z",
  }
}

///|
fn result_fixture() -> @capability.AdapterResultV1 {
  {
    result_id: "result-spatial-1",
    request_id: "request-spatial-1",
    attempt_id: "attempt-spatial-1",
    idempotency_key: "run-spatial-1/work-spatial-1/1",
    product_id: "moonmold",
    external_job_id: "",
    status: "succeeded",
    output_digest: "sha256:" + "d".repeat(64),
    output_artifacts: ["records/operations/result-spatial-1.json"],
    error_kind: "",
    compensable: false,
    recorded_at: "2026-07-31T00:01:02Z",
  }
}

///|
test "request result and reconcile receipt preserve durable identities" {
  assert_eq(
    @capability.adapter_result_contract_v1(),
    "moonflow.adapter-result.v1",
  )
  let request = request_fixture()
  assert_eq(
    @capability.decode_adapter_request_wire_v1(
      @capability.encode_adapter_request_wire_v1(request),
    ),
    request,
  )
  let result = result_fixture()
  assert_eq(
    @capability.decode_adapter_result_v1(
      @capability.encode_adapter_result_v1(result),
    ),
    result,
  )
  let receipt : @capability.AdapterReconcileReceiptV1 = {
    contract_id: "moonmold.adapter-reconciliation.v1",
    adapter_id: "moonmold-pack-local-v1",
    request_id: request.request_id,
    attempt_id: request.attempt_id,
    decision: "recovered-succeeded",
    retry_allowed: false,
    evidence_refs: result.output_artifacts,
    result,
    message: "recovered from durable result",
    recorded_at: "2026-07-31T00:01:03Z",
  }
  assert_eq(
    @capability.decode_adapter_reconcile_receipt_v1(
      @capability.encode_adapter_reconcile_receipt_v1(receipt),
    ),
    receipt,
  )
  let mismatched = { ..receipt, request_id: "different-request" }
  assert_true(
    mismatched
    .conformance_issues()
    .any(fn(issue) { issue.field == "result.request_id" }),
  )
}
