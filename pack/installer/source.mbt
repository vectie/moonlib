///|
pub async fn load_source_manifest(
  source_root : String,
) -> @pack.MoonPackManifest {
  let root = @fs.realpath(source_root)
  let manifest_path = root + "/pack.json"
  if !@fs.exists(manifest_path) {
    fail("pack.json does not exist: \{manifest_path}")
  }
  @pack.decode_manifest(@fs.read_file(manifest_path).text())
}

///|
fn path_is_within(root : String, candidate : String) -> Bool {
  candidate == root || candidate.has_prefix(root + "/")
}

///|
pub async fn validate_source_tree(
  source_root : String,
  manifest : @pack.MoonPackManifest,
) -> Array[String] {
  let issues : Array[String] = []
  for issue in @pack.validate_manifest(manifest).issues {
    issues.push(issue.path + ": " + issue.message)
  }
  let root = @fs.realpath(source_root)
  for contract in @pack.artifact_contracts(manifest) {
    if !@pack.safe_artifact_path(contract.path) {
      issues.push(contract.path + ": unsafe artifact path")
      continue
    }
    let path = root + "/" + contract.path
    if !@fs.exists(path) {
      issues.push(contract.path + ": artifact does not exist")
      continue
    }
    match @fs.kind(path, follow_symlink=false) {
      Regular => {
        let canonical = @fs.realpath(path)
        if !path_is_within(root, canonical) {
          issues.push(contract.path + ": artifact escapes pack root")
        }
      }
      _ => issues.push(contract.path + ": artifact must be a regular file")
    }
  }
  issues
}

///|
pub async fn inspect_source(source_root : String) -> SourceInspection {
  let manifest = load_source_manifest(source_root)
  {
    manifest,
    plan: plan_install(manifest),
    issues: validate_source_tree(source_root, manifest),
  }
}
