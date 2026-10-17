///|
test "pointer canonical methods and indexing share load and store" {
  let ptr : @c.Pointer[Byte] = @c.malloc(2UL)
  assert_false(ptr.is_null())
  ptr.set_at(0, b'A')
  assert_eq(ptr.at(0), b'A')
  ptr[1] = b'B'
  assert_eq(ptr[1], b'B')
  assert_eq(ptr.at(0), b'A')
  ptr.set_at(1, b'C')
  assert_eq(ptr[1], b'C')
  @c.free(ptr)
}
