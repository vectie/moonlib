///|
fn fixture_manifest() -> MoonPackManifest {
  {
    id: "fixture",
    version: "1.0.0",
    display_name: "Fixture",
    product_id: "fixture",
    kind: DomainPack,
    required_runtime_extensions: [],
    book_templates: [],
    schemas: [contract_ref("record", "1", "schemas/record.json")],
    tools: [],
    workflows: [],
    skills: [],
    policies: [],
    provider_ports: [],
    schedules: [],
    app_entrypoints: [],
    migrations: [],
    evaluations: [],
    uninstall_contract: Some(contract_ref("uninstall", "1", "UNINSTALL.md")),
  }
}

///|
test "manifest JSON is a stable disk boundary" {
  let manifest = fixture_manifest()
  assert_true(decode_manifest(encode_manifest(manifest)) == manifest)
  assert_true(validate_manifest(manifest).ok)
}

///|
test "external effects require review and evidence" {
  let base = fixture_manifest()
  let manifest = {
    ..base,
    tools: [
      tool_declaration(
        "fixture.publish",
        "fixture",
        "record",
        "record",
        ExternalEffect,
      ),
    ],
  }
  let report = validate_manifest(manifest)
  assert_false(report.ok)
  assert_true(
    report.issues.any(fn(issue) { issue.message == "effects require review" }),
  )
  assert_true(
    report.issues.any(fn(issue) {
      issue.message == "effects require evidence outputs"
    }),
  )
}

///|
test "artifact traversal and duplicate paths are rejected" {
  let base = fixture_manifest()
  let manifest = {
    ..base,
    schemas: [
      contract_ref("one", "1", "../outside.json"),
      contract_ref("two", "1", "../outside.json"),
    ],
  }
  let report = validate_manifest(manifest)
  assert_false(report.ok)
  assert_true(
    report.issues.any(fn(issue) {
      issue.message == "duplicate path: ../outside.json"
    }),
  )
}
