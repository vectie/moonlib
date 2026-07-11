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
test "product display artifact constructors are root independent" {
  inspect(
    @moonsuite.product_display_dir("moonclaw"),
    content=".moonsuite/products/moonclaw",
  )
  inspect(
    @moonsuite.product_display_artifact("moontown", "watchers/goal.jsonl"),
    content=".moonsuite/products/moontown/watchers/goal.jsonl",
  )
  inspect(
    @moonsuite.product_display_artifact("moondesk", ""),
    content=".moonsuite/products/moondesk",
  )
  inspect(
    @moonsuite.product_display_absolute_artifact(
      "moonrobo", "runtime-health/latest.json",
    ),
    content="/.moonsuite/products/moonrobo/runtime-health/latest.json",
  )
}

///|
test "shared product home contract preserves product-owned paths" {
  let home = @moonsuite.product_home(
    "/tmp/suite",
    "moonfish",
    book_id="trading-lab",
  )
  assert_eq(home.product_id, "moonfish")
  assert_eq(home.state_path, "/tmp/suite/.moonsuite/products/moonfish")
  assert_eq(
    home.service_path,
    "/tmp/suite/.moonsuite/products/moonfish/service.json",
  )
  assert_eq(home.cache_path, "/tmp/suite/.moonsuite/products/moonfish/cache")
  assert_eq(home.tmp_path, "/tmp/suite/.tmp/products/moonfish")
  assert_eq(
    home.accepted_output_path,
    "/tmp/suite/books/trading-lab/outputs/moonfish",
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
test "workspace roots preserve standalone roots and suite book roots" {
  inspect(
    @moonsuite.suite_root_for_workspace_root("/tmp/wiki"),
    content="/tmp/wiki",
  )
  inspect(
    @moonsuite.suite_root_for_workspace_root("/tmp/suite/books/research-wiki"),
    content="/tmp/suite",
  )
  inspect(
    @moonsuite.product_artifact_for_workspace_root(
      "/tmp/wiki", "moonclaw", "providers.json",
    ),
    content="/tmp/wiki/.moonsuite/products/moonclaw/providers.json",
  )
  inspect(
    @moonsuite.product_artifact_for_workspace_root(
      "/tmp/suite/books/research-wiki", "moonclaw", "providers.json",
    ),
    content="/tmp/suite/.moonsuite/products/moonclaw/providers.json",
  )
  let home = @moonsuite.product_home_for_workspace_root(
    "/tmp/suite/books/research-wiki",
    "moonmoon",
    book_id="research-wiki",
  )
  assert_eq(home.state_path, "/tmp/suite/.moonsuite/products/moonmoon")
  assert_eq(home.tmp_path, "/tmp/suite/.tmp/products/moonmoon")
  assert_eq(
    home.accepted_output_path,
    "/tmp/suite/books/research-wiki/outputs/moonmoon",
  )
  assert_false(home.state_path.contains("books/research-wiki/.moonsuite"))
  let inferred_home = @moonsuite.product_home_for_workspace_root(
    "/tmp/suite/books/research-wiki", "moonfish",
  )
  assert_eq(inferred_home.state_path, "/tmp/suite/.moonsuite/products/moonfish")
  assert_eq(inferred_home.tmp_path, "/tmp/suite/.tmp/products/moonfish")
  assert_eq(
    inferred_home.accepted_output_path,
    "/tmp/suite/books/research-wiki/outputs/moonfish",
  )
  inspect(
    @moonsuite.product_accepted_output_path_for_workspace_root(
      "/tmp/suite/books/research-wiki", "mooncode",
    ),
    content="/tmp/suite/books/research-wiki/outputs/mooncode",
  )
}

///|
test "default products include full suite" {
  let ids = @moonsuite.default_product_ids()
  assert_true(ids.contains("moondesk"))
  assert_true(ids.contains("moonclaw"))
  assert_true(ids.contains("moonflow"))
  assert_true(ids.contains("moontown"))
  assert_true(ids.contains("moongate"))
  assert_true(ids.contains("moonfish"))
  assert_true(ids.contains("moonmoon"))
  assert_true(ids.contains("moonchat"))
  assert_true(ids.contains("moonvis"))
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
  assert_true(registry.contains("\"id\":\"moongate\""))
  assert_true(registry.contains("\"id\":\"moonflow\""))
  assert_true(
    registry.contains(
      "\"state_path\":\"/tmp/suite/.moonsuite/products/moongate\"",
    ),
  )
  assert_true(
    registry.contains(
      "\"service_path\":\"/tmp/suite/.moonsuite/products/moongate/service.json\"",
    ),
  )
}
