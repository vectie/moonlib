///|
fn fixture_tmpdir(prefix : String) -> String raise {
  @fsx.mkdtemp(@os.tmpdir() + "/" + prefix + "XXXXXX")
}

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
    app_runtime_identity: None,
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
    create_mode=CreateOrTruncate,
    permission=0o644,
  )
  @fs.write_file(
    root + "/schemas/record.schema.json",
    @encoding/utf8.encode("{\"type\":\"object\"}\n"),
    create_mode=CreateOrTruncate,
    permission=0o644,
  )
  @fs.write_file(
    root + "/UNINSTALL.md",
    @encoding/utf8.encode("Preserve user data.\n"),
    create_mode=CreateOrTruncate,
    permission=0o644,
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
  assert_eq(
    @installer.authorization_issues(manifest, @installer.empty_host_profile()).length(),
    2,
  )
  let allowed : @installer.HostProfile = {
    contract: "moonsuite.pack-host-profile.v1",
    runtime_extensions: ["runtime-a"],
    granted_authorities: [ExternalEffect],
  }
  assert_eq(@installer.authorization_issues(manifest, allowed).length(), 0)
}

///|
async test "install verify rollback and deactivate preserve immutable versions" {
  let source_v1 = fixture_tmpdir("moonpack-source-v1")
  let source_v2 = fixture_tmpdir("moonpack-source-v2")
  let workspace = fixture_tmpdir("moonpack-workspace")
  write_fixture(source_v1, "1.0.0")
  write_fixture(source_v2, "2.0.0")
  let first = @installer.install(source_v1, workspace)
  let repeated = @installer.install(source_v1, workspace)
  assert_eq(first.manifest_sha256, repeated.manifest_sha256)
  @installer.install(source_v2, workspace) |> ignore
  guard @installer.active_pack(workspace, "fixture") is Some(current) else {
    fail("fixture should be active")
  }
  assert_eq(current.version, "2.0.0")
  assert_true(@installer.verify_installed(workspace, "fixture", "1.0.0").ok)
  @installer.activate_version(workspace, "fixture", "1.0.0") |> ignore
  guard @installer.active_pack(workspace, "fixture") is Some(rolled_back) else {
    fail("fixture should remain active")
  }
  assert_eq(rolled_back.version, "1.0.0")
  assert_true(@installer.deactivate(workspace, "fixture"))
  assert_true(@installer.active_pack(workspace, "fixture") is None)
  assert_true(@fs.exists(first.installed_root + "/receipt.json"))
  @fs.rmdir(source_v1, recursive=true)
  @fs.rmdir(source_v2, recursive=true)
  @fs.rmdir(workspace, recursive=true)
}

///|
async test "install preserves app runtime identity declaration" {
  let source = fixture_tmpdir("moonpack-identity-source")
  let workspace = fixture_tmpdir("moonpack-identity-workspace")
  write_fixture(source, "1.0.0")
  let manifest = {
    ..fixture_manifest("1.0.0"),
    app_entrypoints: [@pack.app_entrypoint("desk", "/apps/fixture", "operator")],
    app_runtime_identity: Some({
      contract: "fixture.runtime-identity.v1",
      path: "/apps/fixture/api/v1/runtime-identity",
    }),
  }
  @fs.write_file(
    source + "/pack.json",
    @encoding/utf8.encode(@pack.encode_manifest(manifest)),
    create_mode=CreateOrTruncate,
    permission=0o644,
  )
  let receipt = @installer.install(source, workspace)
  let installed = @pack.decode_manifest(
    @fs.read_file(receipt.installed_root + "/pack.json").text(),
  )
  assert_eq(installed.app_runtime_identity, manifest.app_runtime_identity)
  assert_true(@installer.verify_installed(workspace, "fixture", "1.0.0").ok)
  @fs.rmdir(source, recursive=true)
  @fs.rmdir(workspace, recursive=true)
}

///|
async test "install keeps executable and ordinary artifact permissions" {
  let source = fixture_tmpdir("moonpack-mode-source")
  let workspace = fixture_tmpdir("moonpack-mode-workspace")
  write_fixture(source, "1.0.0")
  @fs.mkdir(source + "/bin", permission=0o755, recursive=true)
  let executable = source + "/bin/runner"
  let ordinary = source + "/bin/data.txt"
  @fs.write_file(
    executable,
    @encoding/utf8.encode("runner\n"),
    create_mode=OpenOrCreate,
    permission=0o755,
  )
  @fs.write_file(
    ordinary,
    @encoding/utf8.encode("data\n"),
    create_mode=OpenOrCreate,
    permission=0o644,
  )
  @fs.chmod(executable, 0o755)
  @fs.chmod(ordinary, 0o644)
  let manifest = {
    ..fixture_manifest("1.0.0"),
    evaluations: [
      @pack.contract_ref("runner", "1.0.0", "bin/runner"),
      @pack.contract_ref("data", "1.0.0", "bin/data.txt"),
    ],
  }
  @fs.write_file(
    source + "/pack.json",
    @encoding/utf8.encode(@pack.encode_manifest(manifest)),
    create_mode=CreateOrTruncate,
    permission=0o644,
  )
  let receipt = @installer.install(source, workspace)
  assert_eq(@fsx.stat(receipt.installed_root + "/bin/runner").mode(), 0o755)
  assert_eq(@fsx.stat(receipt.installed_root + "/bin/data.txt").mode(), 0o644)
  assert_true(@installer.verify_installed(workspace, "fixture", "1.0.0").ok)
  @fs.rmdir(source, recursive=true)
  @fs.rmdir(workspace, recursive=true)
}

///|
async test "verification detects artifact tampering" {
  let source = fixture_tmpdir("moonpack-source")
  let workspace = fixture_tmpdir("moonpack-workspace")
  write_fixture(source, "1.0.0")
  let receipt = @installer.install(source, workspace)
  @fs.write_file(
    receipt.installed_root + "/schemas/record.schema.json",
    @encoding/utf8.encode("tampered\n"),
    create_mode=CreateOrTruncate,
    permission=0o644,
  )
  let result = @installer.verify_installed(workspace, "fixture", "1.0.0")
  assert_false(result.ok)
  assert_true(
    result.issues.any(fn(issue) { issue.contains("digest mismatch") }),
  )
  @fs.rmdir(source, recursive=true)
  @fs.rmdir(workspace, recursive=true)
}
