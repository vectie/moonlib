///|
test "suite roots and product homes" {
  let root = "/tmp/suite/."
  inspect(@moonsuite.suite_root(root), content="/tmp/suite")
  inspect(@moonsuite.books_root(root), content="/tmp/suite/books")
  inspect(@moonsuite.state_dir(root), content="/tmp/suite/.moonsuite")
  inspect(
    @moonsuite.product_dir(root, "moonclaw"),
    content="/tmp/suite/.moonsuite/products/moonclaw",
  )
  inspect(
    @moonsuite.product_tmp_dir(root, "mooncode"),
    content="/tmp/suite/.tmp/products/mooncode",
  )
}

///|
test "book and product artifact constructors" {
  let root = "/tmp/suite"
  inspect(
    @moonsuite.book_artifact(root, "research-demo", "wiki/index.md"),
    content="/tmp/suite/books/research-demo/wiki/index.md",
  )
  inspect(
    @moonsuite.product_artifact(root, "moontown", "requests/r1.json"),
    content="/tmp/suite/.moonsuite/products/moontown/requests/r1.json",
  )
  inspect(
    @moonsuite.product_external_tool_home(root, "moontown", "moonclaw"),
    content="/tmp/suite/.moonsuite/products/moontown/external/moonclaw",
  )
}

///|
test "suite root can be recovered from book root" {
  inspect(
    @moonsuite.suite_root_for_book_root("books/research-demo"),
    content="",
  )
  inspect(
    @moonsuite.suite_root_for_book_root("/tmp/suite/books/research-demo"),
    content="/tmp/suite",
  )
  inspect(
    @moonsuite.suite_root_for_book_root("/tmp/legacy-book"),
    content="/tmp",
  )
  inspect(
    @moonsuite.product_artifact_for_book_root(
      "/tmp/suite/books/research-demo", "moonclaw", "jobs/index/runs.json",
    ),
    content="/tmp/suite/.moonsuite/products/moonclaw/jobs/index/runs.json",
  )
}

///|
test "default products include full suite" {
  let ids = @moonsuite.default_product_ids()
  assert_true(ids.contains("moondesk"))
  assert_true(ids.contains("moonclaw"))
  assert_true(ids.contains("moontown"))
  assert_true(ids.contains("moonstat"))
  assert_true(ids.contains("moonfish"))
  assert_true(ids.contains("moonmoon"))
  assert_true(ids.contains("moonrobo"))
  assert_true(ids.contains("lepusa"))
  assert_true(ids.contains("rabbita"))
}

///|
test "artifact classes expose stable keys" {
  let classes = @moonsuite.artifact_classes()
  inspect(classes[0].key(), content="product-state")
  inspect(classes[1].key(), content="product-temp")
  inspect(classes[2].key(), content="book-root")
  inspect(classes[3].key(), content="book-evidence")
  inspect(classes[4].key(), content="run-ledger")
  inspect(classes[5].key(), content="external-tool-home")
}

///|
test "suite manifest and product registry json" {
  let root = "/tmp/suite"
  json_inspect(@moonsuite.suite_manifest(root), content={
    "kind": "moonsuite-root.v1",
    "root_path": "/tmp/suite",
    "books_path": "/tmp/suite/books",
    "tmp_path": "/tmp/suite/.tmp",
  })
  let registry = @moonsuite.product_registry(root).stringify()
  assert_true(registry.contains("\"kind\":\"moonsuite-product-registry.v1\""))
  assert_true(registry.contains("\"id\":\"moonstat\""))
  assert_true(
    registry.contains(
      "\"state_path\":\"/tmp/suite/.moonsuite/products/moonstat\"",
    ),
  )
  assert_true(
    registry.contains(
      "\"service_path\":\"/tmp/suite/.moonsuite/products/moonstat/service.json\"",
    ),
  )
}
