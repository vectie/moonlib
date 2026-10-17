///|
async test "temporary directory helper accepts a portable prefix" {
  let observed = Ref("")
  @fsx.with_temporary_directory("moonlib-prefix-test-", path => {
    observed.val = path
    assert_true(path.contains("moonlib-prefix-test-"))
    assert_true(@fs.exists(path))
  })
  assert_false(observed.val.is_empty())
  assert_false(@fs.exists(observed.val))
}

///|
async test "temporary directory helper preserves an explicit template" {
  @fsx.with_temporary_directory("moonlib-template-test-XXXXXX", path => {
    assert_true(path.contains("moonlib-template-test-"))
    assert_false(path.has_suffix("XXXXXX"))
    assert_true(@fs.exists(path))
  })
}

///|
suberror TemporaryCallbackProbe {
  TemporaryCallbackProbe
}

///|
async test "temporary directory cleanup preserves callback error identity" {
  let observed = Ref("")
  try {
    let _ : Unit = @fsx.with_temporary_directory("moonlib-error-cleanup-", path => {
      observed.val = path
      raise TemporaryCallbackProbe
    })
  } catch {
    TemporaryCallbackProbe => ()
    error => raise error
  } noraise {
    _ => fail("expected the original callback error")
  }
  assert_false(observed.val.is_empty())
  assert_false(@fs.exists(observed.val))
}

///|
async test "temporary directory cleanup failure preserves callback result" {
  let value = @fsx.with_temporary_directory("moonlib-missing-cleanup-", path => {
    @fs.rmdir(path, recursive=true)
    17
  })
  assert_eq(value, 17)
}
