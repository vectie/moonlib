///|
fn fixture_manifest(id : String, version : String) -> @pack.MoonPackManifest {
  {
    id,
    version,
    display_name: "Fixture",
    product_id: id,
    kind: DomainPack,
    required_runtime_extensions: [],
    book_templates: [],
    schemas: [],
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
      @pack.contract_ref("uninstall", "1", "UNINSTALL.md"),
    ),
  }
}

///|
test "registry accepts caller-supplied packs without domain imports" {
  let registry = register(empty(), fixture_manifest("alpha", "1.0.0")).unwrap()
  assert_true(find(registry, "alpha", "1.0.0") is Some(_))
  assert_true(register(registry, fixture_manifest("alpha", "1.0.0")) is Err(_))
  assert_eq(remove(registry, "alpha", "1.0.0").manifests.length(), 0)
}
