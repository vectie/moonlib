///|
pub(all) struct HostActivationProjection {
  contract : String
  pack_id : String
  product_id : String
  version : String
  required_runtime_extensions : Array[String]
  book_templates : Array[@pack.ContractRef]
  tools : Array[@pack.ToolDeclaration]
  schedules : Array[@pack.ScheduleDeclaration]
  app_entrypoints : Array[@pack.AppEntrypoint]
  provider_ports : Array[@pack.ContractRef]
  policies : Array[@pack.ContractRef]
} derive(Debug, Eq, ToJson, FromJson)

///|
pub(all) struct HostDeactivationProjection {
  contract : String
  pack_id : String
  tool_ids : Array[String]
  schedule_ids : Array[String]
  app_entrypoint_ids : Array[String]
  preserve_namespaces : Array[String]
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn activation_projection(
  manifest : @pack.MoonPackManifest,
  pointer : @installer.ActivePackPointer,
) -> HostActivationProjection raise {
  if manifest.id != pointer.pack_id || manifest.version != pointer.version {
    fail("active pointer and manifest identity do not match")
  }
  {
    contract: "moonsuite.pack-host-activation.v1",
    pack_id: manifest.id,
    product_id: manifest.product_id,
    version: manifest.version,
    required_runtime_extensions: manifest.required_runtime_extensions,
    book_templates: manifest.book_templates,
    tools: manifest.tools,
    schedules: manifest.schedules,
    app_entrypoints: manifest.app_entrypoints,
    provider_ports: manifest.provider_ports,
    policies: manifest.policies,
  }
}

///|
pub fn deactivation_projection(
  manifest : @pack.MoonPackManifest,
) -> HostDeactivationProjection {
  {
    contract: "moonsuite.pack-host-deactivation.v1",
    pack_id: manifest.id,
    tool_ids: manifest.tools.map(fn(tool) { tool.id }),
    schedule_ids: manifest.schedules.map(fn(schedule) { schedule.id }),
    app_entrypoint_ids: manifest.app_entrypoints.map(fn(entrypoint) {
      entrypoint.id
    }),
    preserve_namespaces: [
      "records/" + manifest.product_id,
      "evidence/" + manifest.product_id,
      "deliveries/" + manifest.product_id,
    ],
  }
}
