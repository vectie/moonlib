///|
async fn activate_receipt(
  workspace : String,
  receipt : InstallationReceipt,
) -> ActivePackPointer {
  let pointer : ActivePackPointer = {
    contract: "moonsuite.active-pack.v1",
    pack_id: receipt.pack_id,
    version: receipt.version,
    manifest_sha256: receipt.manifest_sha256,
    installed_root: receipt.installed_root,
  }
  write_json_atomic(active_path(workspace, receipt.pack_id), pointer)
  pointer
}

///|
pub async fn install_authorized(
  source_root : String,
  workspace : String,
  profile : HostProfile,
) -> InstallationReceipt {
  let source = @fs.realpath(source_root)
  let manifest = load_source_manifest(source)
  let source_issues = validate_source_tree(source, manifest)
  if !source_issues.is_empty() {
    fail("pack source validation failed:\n" + source_issues.join("\n"))
  }
  let plan = plan_install(manifest)
  if plan.state != ReadyToStage {
    fail("pack is not ready to stage")
  }
  let denied = authorization_issues(manifest, profile)
  if !denied.is_empty() {
    fail("pack authority/dependency check failed:\n" + denied.join("\n"))
  }
  let lock = acquire_pack_lock(workspace, manifest.id)
  defer {
    lock.unlock()
    lock.close()
  }
  let destination = installed_root(workspace, manifest.id, manifest.version)
  let manifest_text = @pack.encode_manifest(manifest)
  let manifest_sha256 = text_sha256(manifest_text)
  if @fs.exists(destination) {
    let existing = read_receipt(destination + "/receipt.json")
    let verification = verify_installed(
      workspace,
      manifest.id,
      manifest.version,
    )
    if existing.manifest_sha256 != manifest_sha256 || !verification.ok {
      fail("installed pack version conflicts with source or is corrupt")
    }
    activate_receipt(workspace, existing) |> ignore
    return existing
  }
  let staging = staging_root(workspace, manifest.id, manifest.version)
  if @fs.exists(staging) {
    @fs.rmdir(staging, recursive=true)
  }
  ensure_directory(staging)
  @fs.write_file(
    staging + "/pack.json",
    @encoding/utf8.encode(manifest_text),
    create=0o644,
    truncate=true,
  )
  let artifacts : Array[ArtifactReceipt] = []
  for contract in @pack.artifact_contracts(manifest) {
    let copied = copy_file(
      source + "/" + contract.path,
      staging + "/" + contract.path,
    )
    artifacts.push({ ..copied, path: contract.path })
  }
  let receipt : InstallationReceipt = {
    contract: "moonsuite.pack-installation.v1",
    pack_id: manifest.id,
    product_id: manifest.product_id,
    version: manifest.version,
    manifest_sha256,
    installed_root: destination,
    artifacts,
    authorities: plan.authorities,
  }
  write_json_atomic(staging + "/receipt.json", receipt)
  ensure_directory(parent_dir(destination))
  @fsx.atomic_rename(staging, destination)
  activate_receipt(workspace, receipt) |> ignore
  receipt
}

///|
/// Installs only capability-free packs. Any dependency or authority requires
/// an explicit host profile via `install_authorized`.
pub async fn install(
  source_root : String,
  workspace : String,
) -> InstallationReceipt {
  install_authorized(source_root, workspace, empty_host_profile())
}

///|
pub async fn verify_installed(
  workspace : String,
  pack_id : String,
  version : String,
) -> InstalledVerification {
  let issues : Array[String] = []
  let root = installed_root(workspace, pack_id, version)
  if !@fs.exists(root) {
    return { ok: false, pack_id, version, issues: ["version is not installed"] }
  }
  let receipt = read_receipt(root + "/receipt.json") catch {
    _ =>
      return {
        ok: false,
        pack_id,
        version,
        issues: ["receipt is missing or invalid"],
      }
  }
  let manifest = @pack.decode_manifest(
    @fs.read_file(root + "/pack.json").text(),
  ) catch {
    _ => {
      issues.push("installed manifest is missing or invalid")
      return { ok: false, pack_id, version, issues }
    }
  }
  if text_sha256(@pack.encode_manifest(manifest)) != receipt.manifest_sha256 {
    issues.push("manifest digest mismatch")
  }
  if receipt.pack_id != pack_id || receipt.version != version {
    issues.push("receipt identity mismatch")
  }
  for artifact in receipt.artifacts {
    let path = root + "/" + artifact.path
    if !@fs.exists(path) {
      issues.push(artifact.path + ": installed artifact is missing")
      continue
    }
    let bytes = @fs.read_file(path).binary()
    if bytes.length() != artifact.size {
      issues.push(artifact.path + ": size mismatch")
    }
    if sha256_hex(bytes) != artifact.sha256 {
      issues.push(artifact.path + ": digest mismatch")
    }
  }
  { ok: issues.is_empty(), pack_id, version, issues }
}

///|
pub async fn activate_version(
  workspace : String,
  pack_id : String,
  version : String,
) -> ActivePackPointer {
  let lock = acquire_pack_lock(workspace, pack_id)
  defer {
    lock.unlock()
    lock.close()
  }
  let verification = verify_installed(workspace, pack_id, version)
  if !verification.ok {
    fail("cannot activate unverified pack: " + verification.issues.join("; "))
  }
  activate_receipt(
    workspace,
    read_receipt(installed_root(workspace, pack_id, version) + "/receipt.json"),
  )
}

///|
pub async fn active_pack(
  workspace : String,
  pack_id : String,
) -> ActivePackPointer? {
  let path = active_path(workspace, pack_id)
  if !@fs.exists(path) {
    return None
  }
  Some(read_pointer(path))
}

///|
pub async fn active_manifest(
  workspace : String,
  pack_id : String,
) -> @pack.MoonPackManifest? {
  guard active_pack(workspace, pack_id) is Some(pointer) else { return None }
  Some(
    @pack.decode_manifest(
      @fs.read_file(pointer.installed_root + "/pack.json").text(),
    ),
  )
}

///|
pub async fn list_active(workspace : String) -> Array[ActivePackPointer] {
  let result : Array[ActivePackPointer] = []
  let directory = store_root(workspace) + "/active"
  if !@fs.exists(directory) {
    return result
  }
  for name in @fs.readdir(directory, sort=true) {
    if name.has_suffix(".json") {
      result.push(read_pointer(directory + "/" + name))
    }
  }
  result
}

///|
/// Removes only the active pointer. Installed versions and user evidence remain
/// available for audit and rollback.
pub async fn deactivate(workspace : String, pack_id : String) -> Bool {
  let lock = acquire_pack_lock(workspace, pack_id)
  defer {
    lock.unlock()
    lock.close()
  }
  let path = active_path(workspace, pack_id)
  if !@fs.exists(path) {
    return false
  }
  @fs.remove(path)
  true
}
