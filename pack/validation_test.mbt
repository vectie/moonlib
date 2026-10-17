///|
fn fixture_manifest() -> @pack.MoonPackManifest {
  {
    id: "fixture",
    version: "1.0.0",
    display_name: "Fixture",
    product_id: "fixture",
    kind: DomainPack,
    required_runtime_extensions: [],
    book_templates: [],
    schemas: [@pack.contract_ref("record", "1", "schemas/record.json")],
    tools: [],
    workflows: [],
    skills: [],
    policies: [],
    provider_ports: [],
    schedules: [],
    app_entrypoints: [],
    app_runtime_identity: None,
    migrations: [],
    evaluations: [],
    uninstall_contract: Some(
      @pack.contract_ref("uninstall", "1", "UNINSTALL.md"),
    ),
  }
}

///|
test "manifest JSON is a stable disk boundary" {
  let manifest = fixture_manifest()
  assert_true(
    @pack.decode_manifest(@pack.encode_manifest(manifest)) == manifest,
  )
  assert_true(@pack.validate_manifest(manifest).ok)
}

///|
test "optional app runtime identity survives JSON and older manifests" {
  let manifest = {
    ..fixture_manifest(),
    app_entrypoints: [@pack.app_entrypoint("desk", "/apps/fixture", "operator")],
    app_runtime_identity: Some({
      contract: "fixture.runtime-identity.v1",
      path: "/apps/fixture/api/v1/runtime-identity",
    }),
  }
  assert_true(@pack.validate_manifest(manifest).ok)
  assert_true(
    @pack.decode_manifest(@pack.encode_manifest(manifest)) == manifest,
  )
  let legacy = @json.parse(@pack.encode_manifest(fixture_manifest()))
  match legacy {
    Object(fields) => fields.remove("app_runtime_identity") |> ignore
    _ => fail("encoded manifest should be an object")
  }
  assert_true(
    @pack.decode_manifest(legacy.stringify()).app_runtime_identity is None,
  )
}

///|
test "app runtime identity must be within an app route" {
  let manifest = {
    ..fixture_manifest(),
    app_entrypoints: [@pack.app_entrypoint("desk", "/apps/fixture", "operator")],
    app_runtime_identity: Some({
      contract: "fixture.runtime-identity.v1",
      path: "/apps/other/api/v1/runtime-identity",
    }),
  }
  assert_false(@pack.validate_manifest(manifest).ok)
  let traversal = {
    ..manifest,
    app_runtime_identity: Some({
      contract: "fixture.runtime-identity.v1",
      path: "/apps/fixture/../other",
    }),
  }
  assert_false(@pack.validate_manifest(traversal).ok)
}

///|
test "external effects require review and evidence" {
  let base = fixture_manifest()
  let manifest = {
    ..base,
    tools: [
      @pack.tool_declaration(
        "fixture.publish",
        "fixture",
        "record",
        "record",
        ExternalEffect,
      ),
    ],
  }
  let report = @pack.validate_manifest(manifest)
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
      @pack.contract_ref("one", "1", "../outside.json"),
      @pack.contract_ref("two", "1", "../outside.json"),
    ],
  }
  let report = @pack.validate_manifest(manifest)
  assert_false(report.ok)
  assert_true(
    report.issues.any(fn(issue) {
      issue.message == "duplicate path: ../outside.json"
    }),
  )
}
