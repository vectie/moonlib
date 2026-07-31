///|
fn handover_test_digest(fill : String) -> String {
  "sha256:" + fill.repeat(64)
}

///|
test "shared collaboration references round-trip canonically" {
  let principal = @capability.principal_ref_v1(
    "agent-one",
    @capability.Agent,
    "local",
    "agent-one",
  )
  assert_eq(
    @capability.decode_principal_ref_v1(
      @capability.encode_principal_ref_v1(principal),
    ),
    principal,
  )
  let workspace = @capability.workspace_ref_v1(
    "workspace-one",
    "revision-one",
    handover_test_digest("a"),
  )
  assert_eq(
    @capability.decode_workspace_ref_v1(
      @capability.encode_workspace_ref_v1(workspace),
    ),
    workspace,
  )
}

///|
test "handover bundles are deterministic and exclude secret artifacts" {
  let principal = @capability.principal_ref_v1(
    "agent-source",
    @capability.Agent,
    "local",
    "agent-source",
  )
  let workspace = @capability.workspace_ref_v1(
    "workspace-two",
    "revision-two",
    handover_test_digest("b"),
  )
  let contract = @capability.contract_ref_v1("moonsuite.test-artifact", "1.0.0")
  let entry = @capability.handover_bundle_entry_v1(
    "artifacts/result.json",
    handover_test_digest("c"),
    contract,
    "application/json",
    @capability.Internal,
    handover_test_digest("d"),
  )
  let first = @capability.handover_bundle_v1(
    "bundle-one",
    workspace,
    principal,
    [entry],
    created_at="2026-07-31T01:00:00Z",
  )
  let second = @capability.decode_handover_bundle_v1(
    @capability.encode_handover_bundle_v1(first),
  )
  assert_eq(first.content_digest(), second.content_digest())
  let secret_rejected = try {
    ignore(
      @capability.handover_bundle_entry_v1(
        "artifacts/secret.json",
        handover_test_digest("e"),
        contract,
        "application/json",
        @capability.Secret,
        handover_test_digest("f"),
      ),
    )
    false
  } catch {
    _ => true
  }
  assert_true(secret_rejected)
}
