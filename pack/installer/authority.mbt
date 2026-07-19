///|
pub fn empty_host_profile() -> HostProfile {
  {
    contract: "moonsuite.pack-host-profile.v1",
    runtime_extensions: [],
    granted_authorities: [],
  }
}

///|
fn authority_name(authority : @pack.AuthorityClass) -> String {
  match authority {
    Observe => "Observe"
    CognitiveMaintenance => "CognitiveMaintenance"
    SandboxExecution => "SandboxExecution"
    WorkspaceMutation => "WorkspaceMutation"
    ExternalEffect => "ExternalEffect"
    PhysicalEffect => "PhysicalEffect"
  }
}

///|
pub fn authorization_issues(
  manifest : @pack.MoonPackManifest,
  profile : HostProfile,
) -> Array[String] {
  let issues : Array[String] = []
  if profile.contract != "moonsuite.pack-host-profile.v1" {
    issues.push("unsupported host profile contract")
  }
  for extension in manifest.required_runtime_extensions {
    if !profile.runtime_extensions.contains(extension) {
      issues.push("required runtime extension is unavailable: " + extension)
    }
  }
  for authority in plan_install(manifest).authorities {
    if !profile.granted_authorities.contains(authority) {
      issues.push("authority was not granted: " + authority_name(authority))
    }
  }
  issues
}

///|
pub async fn load_host_profile(path : String) -> HostProfile {
  @json.from_json(@json.parse(@fs.read_file(path).text()))
}
