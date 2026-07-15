///|
test "host projection carries generic contracts only" {
  let manifest : @pack.MoonPackManifest = {
    id: "fixture",
    version: "1.0.0",
    display_name: "Fixture",
    product_id: "fixture-product",
    kind: DomainPack,
    required_runtime_extensions: ["runtime"],
    book_templates: [],
    schemas: [@pack.contract_ref("record", "1", "schemas/record.json")],
    tools: [
      @pack.tool_declaration(
        "fixture.observe",
        "fixture-product",
        "record",
        "record",
        Observe,
      ),
    ],
    workflows: [],
    skills: [],
    policies: [],
    provider_ports: [],
    schedules: [],
    app_entrypoints: [@pack.app_entrypoint("desk", "/fixture", "operator")],
    migrations: [],
    evaluations: [],
    uninstall_contract: Some(
      @pack.contract_ref("uninstall", "1", "UNINSTALL.md"),
    ),
  }
  let pointer : @installer.ActivePackPointer = {
    contract: "moonsuite.active-pack.v1",
    pack_id: "fixture",
    version: "1.0.0",
    manifest_sha256: "digest",
    installed_root: "/packs/fixture/1.0.0",
  }
  assert_eq(activation_projection(manifest, pointer).tools.length(), 1)
  assert_true(
    deactivation_projection(manifest).preserve_namespaces.contains(
      "records/fixture-product",
    ),
  )
}
