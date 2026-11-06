///|
async test "atomic rename replaces destination content" {
  let root = @fsx.mkdtemp(
    @pathx.join(@os.tmpdir(), "moonlib-atomic-renameXXXXXX"),
  )
  let source = root + "/source"
  let destination = root + "/destination"
  @fs.write_file(
    source,
    @encoding/utf8.encode("new"),
    create_mode=CreateOrTruncate,
    permission=0o644,
  )
  @fs.write_file(
    destination,
    @encoding/utf8.encode("old"),
    create_mode=CreateOrTruncate,
    permission=0o644,
  )
  @fsx.atomic_rename(source, destination)
  assert_false(@fs.exists(source))
  assert_eq(@fs.read_file(destination).text(), "new")
  @fs.rmdir(root, recursive=true)
}
