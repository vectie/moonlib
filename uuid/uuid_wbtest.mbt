///|
test "UUID version nibble conversion covers full four-bit range" {
  json_inspect(Version::from_nibble(0UL), content="V0")
  json_inspect(Version::from_nibble(4UL), content="V4")
  json_inspect(Version::from_nibble(15UL), content="V15")
}
