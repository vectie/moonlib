///|
async test "temporary directory helper accepts a portable prefix" {
  let observed = Ref("")
  with_temporary_directory("moonlib-prefix-test-", path => {
    observed.val = path
    assert_true(path.contains("moonlib-prefix-test-"))
    assert_true(@fs.exists(path))
  })
  assert_false(observed.val.is_empty())
  assert_false(@fs.exists(observed.val))
}

///|
async test "temporary directory helper preserves an explicit template" {
  with_temporary_directory("moonlib-template-test-XXXXXX", path => {
    assert_true(path.contains("moonlib-template-test-"))
    assert_false(path.has_suffix("XXXXXX"))
    assert_true(@fs.exists(path))
  })
}
