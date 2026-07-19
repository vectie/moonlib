///|
fn ensure_safe_id(value : String, label : String) -> Unit raise {
  if !@pack.safe_identifier(value) {
    fail("\{label} must be a safe identifier")
  }
}

///|
fn store_root(workspace : String) -> String {
  workspace + "/.moonsuite/packs"
}

///|
fn installed_root(
  workspace : String,
  pack_id : String,
  version : String,
) -> String raise {
  ensure_safe_id(pack_id, "pack_id")
  ensure_safe_id(version, "version")
  store_root(workspace) + "/versions/" + pack_id + "/" + version
}

///|
fn staging_root(
  workspace : String,
  pack_id : String,
  version : String,
) -> String raise {
  ensure_safe_id(pack_id, "pack_id")
  ensure_safe_id(version, "version")
  store_root(workspace) + "/staging/" + pack_id + "-" + version
}

///|
fn active_path(workspace : String, pack_id : String) -> String raise {
  ensure_safe_id(pack_id, "pack_id")
  store_root(workspace) + "/active/" + pack_id + ".json"
}

///|
fn parent_dir(path : String) -> String {
  @path.Path::dirname(path).to_string()
}
