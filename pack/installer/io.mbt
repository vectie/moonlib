///|
async fn ensure_directory(path : String) -> Unit {
  if !@fs.exists(path) {
    @fs.mkdir(path, permission=0o755, recursive=true)
  }
}

///|
async fn[T : ToJson] write_json_atomic(path : String, value : T) -> Unit {
  ensure_directory(parent_dir(path))
  let temporary = path + ".tmp"
  @fs.write_file(
    temporary,
    @encoding/utf8.encode(value.to_json().stringify(indent=2) + "\n"),
    create=0o644,
    truncate=true,
  )
  @fsx.atomic_rename(temporary, path)
}

///|
async fn read_receipt(path : String) -> InstallationReceipt {
  @json.from_json(@json.parse(@fs.read_file(path).text()))
}

///|
async fn read_pointer(path : String) -> ActivePackPointer {
  @json.from_json(@json.parse(@fs.read_file(path).text()))
}

///|
async fn copy_file(source : String, destination : String) -> ArtifactReceipt {
  ensure_directory(parent_dir(destination))
  let bytes = @fs.read_file(source).binary()
  @fs.write_file(destination, bytes, create=0o644, truncate=true)
  { path: "", sha256: sha256_hex(bytes), size: bytes.length() }
}

///|
async fn acquire_pack_lock(workspace : String, pack_id : String) -> @fs.File {
  ensure_safe_id(pack_id, "pack_id")
  let directory = store_root(workspace) + "/locks"
  ensure_directory(directory)
  let file = @fs.open(
    directory + "/" + pack_id + ".lock",
    mode=ReadWrite,
    create=0o644,
  )
  file.lock(Exclusive)
  file
}
