///|
async test "atomic rename replaces destination content" {
  let root = @fs.tmpdir(prefix="moonlib-atomic-rename")
  let source = root + "/source"
  let destination = root + "/destination"
  @fs.write_file(
    source,
    @encoding/utf8.encode("new"),
    create=0o644,
    truncate=true,
  )
  @fs.write_file(
    destination,
    @encoding/utf8.encode("old"),
    create=0o644,
    truncate=true,
  )
  atomic_rename(source, destination)
  assert_false(@fs.exists(source))
  assert_eq(@fs.read_file(destination).text(), "new")
  @fs.rmdir(root, recursive=true)
}
