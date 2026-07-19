///|
fn declared_authorities(
  manifest : @pack.MoonPackManifest,
) -> Array[@pack.AuthorityClass] {
  let result : Array[@pack.AuthorityClass] = []
  for tool in manifest.tools {
    if !result.contains(tool.authority) {
      result.push(tool.authority)
    }
  }
  result
}

///|
pub fn plan_install(manifest : @pack.MoonPackManifest) -> InstallPlan {
  let validation = @pack.validate_manifest(manifest)
  {
    pack_id: manifest.id,
    version: manifest.version,
    state: if validation.ok {
      ReadyToStage
    } else {
      Rejected
    },
    validation,
    authorities: declared_authorities(manifest),
    owned_namespaces: [
      "packs/" + manifest.id,
      "records/" + manifest.product_id,
      "apps/" + manifest.product_id,
    ],
  }
}
