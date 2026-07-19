///|
pub fn encode_manifest(manifest : MoonPackManifest) -> String {
  manifest.to_json().stringify(indent=2) + "\n"
}

///|
pub fn decode_manifest(text : String) -> MoonPackManifest raise {
  @json.from_json(@json.parse(text))
}

///|
pub fn artifact_contracts(manifest : MoonPackManifest) -> Array[ContractRef] {
  let result : Array[ContractRef] = []
  for
    contracts in [
      manifest.book_templates,
      manifest.schemas,
      manifest.workflows,
      manifest.skills,
      manifest.policies,
      manifest.provider_ports,
      manifest.migrations,
      manifest.evaluations,
    ] {
    for contract in contracts {
      result.push(contract)
    }
  }
  match manifest.uninstall_contract {
    Some(contract) => result.push(contract)
    None => ()
  }
  result
}

///|
pub fn safe_identifier(value : String) -> Bool {
  !value.trim().is_empty() &&
  !value.contains("/") &&
  !value.contains("\\") &&
  !value.contains("..")
}

///|
pub fn safe_artifact_path(value : String) -> Bool {
  !value.trim().is_empty() &&
  !value.has_prefix("/") &&
  !value.contains("\\") &&
  !value.contains("..")
}
