///|
pub(all) struct PackRegistry {
  manifests : Array[@pack.MoonPackManifest]
} derive(Debug, Eq)

///|
pub fn empty() -> PackRegistry {
  { manifests: [] }
}

///|
pub fn find(
  registry : PackRegistry,
  pack_id : String,
  version : String,
) -> @pack.MoonPackManifest? {
  for manifest in registry.manifests {
    if manifest.id == pack_id && manifest.version == version {
      return Some(manifest)
    }
  }
  None
}

///|
pub fn register(
  registry : PackRegistry,
  manifest : @pack.MoonPackManifest,
) -> Result[PackRegistry, String] {
  if !@pack.validate_manifest(manifest).ok {
    return Err("manifest failed validation")
  }
  if find(registry, manifest.id, manifest.version) is Some(_) {
    return Err("pack version is already registered")
  }
  let manifests = registry.manifests.copy()
  manifests.push(manifest)
  Ok({ manifests, })
}

///|
pub fn remove(
  registry : PackRegistry,
  pack_id : String,
  version : String,
) -> PackRegistry {
  {
    manifests: registry.manifests.filter(fn(manifest) {
      manifest.id != pack_id || manifest.version != version
    }),
  }
}
