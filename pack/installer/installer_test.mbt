///|
fn fixture_manifest(version : String) -> @pack.MoonPackManifest {
  {
    id: "fixture",
    version,
    display_name: "Fixture Pack",
    product_id: "fixture",
    kind: DomainPack,
    required_runtime_extensions: [],
    book_templates: [],
    schemas: [
      @pack.contract_ref("record", "1.0.0", "schemas/record.schema.json"),
    ],
    tools: [],
    workflows: [],
    skills: [],
    policies: [],
    provider_ports: [],
    schedules: [],
    app_entrypoints: [],
    migrations: [],
    evaluations: [],
    uninstall_contract: Some(
      @pack.contract_ref("uninstall", "1.0.0", "UNINSTALL.md"),
    ),
  }
}

///|
async fn write_fixture(root : String, version : String) -> Unit {
  @fs.mkdir(root + "/schemas", permission=0o755, recursive=true)
  @fs.write_file(
    root + "/pack.json",
    @encoding/utf8.encode(@pack.encode_manifest(fixture_manifest(version))),
    create=0o644,
    truncate=true,
  )
  @fs.write_file(
    root + "/schemas/record.schema.json",
    @encoding/utf8.encode("{\"type\":\"object\"}\n"),
    create=0o644,
    truncate=true,
  )
  @fs.write_file(
    root + "/UNINSTALL.md",
    @encoding/utf8.encode("Preserve user data.\n"),
    create=0o644,
    truncate=true,
  )
}

///|
test "authority and runtime dependency grants are explicit" {
  let base = fixture_manifest("1.0.0")
  let manifest = {
    ..base,
    required_runtime_extensions: ["runtime-a"],
    tools: [
      @pack.tool_declaration(
        "fixture.publish",
        "fixture",
        "record",
        "record",
        ExternalEffect,
        evidence_outputs=["records/publication.json"],
        review_required=true,
      ),
    ],
  }
  assert_eq(authorization_issues(manifest, empty_host_profile()).length(), 2)
  let allowed : HostProfile = {
    contract: "moonsuite.pack-host-profile.v1",
    runtime_extensions: ["runtime-a"],
    granted_authorities: [ExternalEffect],
  }
  assert_eq(authorization_issues(manifest, allowed).length(), 0)
}

///|
async test "install verify rollback and deactivate preserve immutable versions" {
  let source_v1 = @fs.tmpdir(prefix="moonpack-source-v1")
  let source_v2 = @fs.tmpdir(prefix="moonpack-source-v2")
  let workspace = @fs.tmpdir(prefix="moonpack-workspace")
  write_fixture(source_v1, "1.0.0")
  write_fixture(source_v2, "2.0.0")
  let first = install(source_v1, workspace)
  let repeated = install(source_v1, workspace)
  assert_eq(first.manifest_sha256, repeated.manifest_sha256)
  install(source_v2, workspace) |> ignore
  guard active_pack(workspace, "fixture") is Some(current) else {
    fail("fixture should be active")
  }
  assert_eq(current.version, "2.0.0")
  assert_true(verify_installed(workspace, "fixture", "1.0.0").ok)
  activate_version(workspace, "fixture", "1.0.0") |> ignore
  guard active_pack(workspace, "fixture") is Some(rolled_back) else {
    fail("fixture should remain active")
  }
  assert_eq(rolled_back.version, "1.0.0")
  assert_true(deactivate(workspace, "fixture"))
  assert_true(active_pack(workspace, "fixture") is None)
  assert_true(@fs.exists(first.installed_root + "/receipt.json"))
  @fs.rmdir(source_v1, recursive=true)
  @fs.rmdir(source_v2, recursive=true)
  @fs.rmdir(workspace, recursive=true)
}

///|
async test "verification detects artifact tampering" {
  let source = @fs.tmpdir(prefix="moonpack-source")
  let workspace = @fs.tmpdir(prefix="moonpack-workspace")
  write_fixture(source, "1.0.0")
  let receipt = install(source, workspace)
  @fs.write_file(
    receipt.installed_root + "/schemas/record.schema.json",
    @encoding/utf8.encode("tampered\n"),
    create=0o644,
    truncate=true,
  )
  let result = verify_installed(workspace, "fixture", "1.0.0")
  assert_false(result.ok)
  assert_true(
    result.issues.any(fn(issue) { issue.contains("digest mismatch") }),
  )
  @fs.rmdir(source, recursive=true)
  @fs.rmdir(workspace, recursive=true)
}
