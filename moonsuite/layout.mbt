///|
pub enum ArtifactClass {
  ProductState
  ProductTemp
  BookRoot
  BookEvidence
  RunLedger
  ExternalToolHome
} derive(Debug, Eq, Compare, Hash, ToJson)

///|
pub fn ArtifactClass::key(self : ArtifactClass) -> String {
  match self {
    ProductState => "product-state"
    ProductTemp => "product-temp"
    BookRoot => "book-root"
    BookEvidence => "book-evidence"
    RunLedger => "run-ledger"
    ExternalToolHome => "external-tool-home"
  }
}

///|
pub fn artifact_classes() -> Array[ArtifactClass] {
  [
    ProductState,
    ProductTemp,
    BookRoot,
    BookEvidence,
    RunLedger,
    ExternalToolHome,
  ]
}

///|
pub fn suite_root(root : String) -> String {
  @pathx.normalize(root)
}

///|
pub fn books_root(root : String) -> String {
  @pathx.join(suite_root(root), "books")
}

///|
pub fn inbox_root(root : String) -> String {
  @pathx.join(suite_root(root), "inbox")
}

///|
pub fn exports_root(root : String) -> String {
  @pathx.join(suite_root(root), "exports")
}

///|
pub fn tmp_root(root : String) -> String {
  @pathx.join(suite_root(root), ".tmp")
}

///|
pub fn tmp_products_root(root : String) -> String {
  @pathx.join(tmp_root(root), "products")
}

///|
pub fn product_tmp_dir(root : String, product_id : String) -> String {
  @pathx.join(tmp_products_root(root), product_id)
}

///|
pub(all) struct ProductHome {
  product_id : String
  state_path : String
  service_path : String
  cache_path : String
  tmp_path : String
  accepted_output_path : String
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn state_dir(root : String) -> String {
  @pathx.join(suite_root(root), ".moonsuite")
}

///|
pub fn products_root(root : String) -> String {
  @pathx.join(state_dir(root), "products")
}

///|
pub fn product_dir(root : String, product_id : String) -> String {
  @pathx.join(products_root(root), product_id)
}

///|
pub fn product_artifact(
  root : String,
  product_id : String,
  relative : String,
) -> String {
  @pathx.join(product_dir(root, product_id), relative)
}

///|
pub fn product_cache_path(root : String, product_id : String) -> String {
  product_artifact(root, product_id, "cache")
}

///|
pub fn product_service_path(root : String, product_id : String) -> String {
  product_artifact(root, product_id, "service.json")
}

///|
pub fn product_external_tool_home(
  root : String,
  product_id : String,
  tool_id : String,
) -> String {
  product_artifact(root, product_id, @pathx.join("external", tool_id))
}

///|
pub fn services_root(root : String) -> String {
  @pathx.join(state_dir(root), "services")
}

///|
pub fn cache_root(root : String) -> String {
  @pathx.join(state_dir(root), "cache")
}

///|
pub fn suite_manifest_path(root : String) -> String {
  @pathx.join(state_dir(root), "suite.json")
}

///|
pub fn product_registry_path(root : String) -> String {
  @pathx.join(state_dir(root), "product-registry.json")
}

///|
pub fn book_root(root : String, book_id : String) -> String {
  @pathx.join(books_root(root), book_id)
}

///|
pub fn book_artifact(
  root : String,
  book_id : String,
  relative : String,
) -> String {
  @pathx.join(book_root(root, book_id), relative)
}

///|
pub fn product_accepted_output_path(
  root : String,
  product_id : String,
  book_id : String,
) -> String {
  book_artifact(root, book_id, @pathx.join("outputs", product_id))
}

///|
pub fn suite_root_for_book_root(book_root : String) -> String {
  let normalized = @pathx.normalize(book_root)
  let segments : Array[String] = []
  for part in @pathx.split(normalized) {
    if part == "books" {
      return join_suite_root_segments(segments)
    }
    segments.push(part.to_owned())
  }
  @pathx.dirname(normalized).to_owned()
}

///|
pub fn suite_root_for_workspace_root(workspace_root : String) -> String {
  let normalized = @pathx.normalize(workspace_root)
  let parent = @pathx.dirname(normalized).to_owned()
  if @pathx.basename(parent).to_owned() == "books" {
    @pathx.dirname(parent).to_owned()
  } else {
    normalized
  }
}

///|
fn book_id_for_workspace_root(
  workspace_root : String,
  fallback : String,
) -> String {
  let normalized = @pathx.normalize(workspace_root)
  let parent = @pathx.dirname(normalized).to_owned()
  if fallback == "<book-id>" && @pathx.basename(parent).to_owned() == "books" {
    @pathx.basename(normalized).to_owned()
  } else {
    fallback
  }
}

///|
fn join_suite_root_segments(segments : Array[String]) -> String {
  let mut root = ""
  for part in segments {
    if part == "/" {
      root = "/"
    } else if root.is_empty() {
      root = part
    } else {
      root = @pathx.join(root, part)
    }
  }
  root
}

///|
pub fn product_artifact_for_book_root(
  book_root : String,
  product_id : String,
  relative : String,
) -> String {
  product_artifact(suite_root_for_book_root(book_root), product_id, relative)
}

///|
pub fn product_artifact_for_workspace_root(
  workspace_root : String,
  product_id : String,
  relative : String,
) -> String {
  product_artifact(
    suite_root_for_workspace_root(workspace_root),
    product_id,
    relative,
  )
}

///|
pub fn product_cache_path_for_workspace_root(
  workspace_root : String,
  product_id : String,
) -> String {
  product_artifact_for_workspace_root(workspace_root, product_id, "cache")
}

///|
pub fn product_accepted_output_path_for_workspace_root(
  workspace_root : String,
  product_id : String,
  book_id? : String = "<book-id>",
) -> String {
  product_accepted_output_path(
    suite_root_for_workspace_root(workspace_root),
    product_id,
    book_id_for_workspace_root(workspace_root, book_id),
  )
}

///|
pub fn product_home(
  root : String,
  product_id : String,
  book_id? : String = "<book-id>",
) -> ProductHome {
  {
    product_id,
    state_path: product_dir(root, product_id),
    service_path: product_service_path(root, product_id),
    cache_path: product_cache_path(root, product_id),
    tmp_path: product_tmp_dir(root, product_id),
    accepted_output_path: product_accepted_output_path(
      root, product_id, book_id,
    ),
  }
}

///|
pub fn product_home_for_workspace_root(
  workspace_root : String,
  product_id : String,
  book_id? : String = "<book-id>",
) -> ProductHome {
  product_home(
    suite_root_for_workspace_root(workspace_root),
    product_id,
    book_id=book_id_for_workspace_root(workspace_root, book_id),
  )
}

///|
pub fn default_product_ids() -> Array[String] {
  [
    "moondesk", "moonbook", "moonwiki", "mooncode", "moonclaw", "moontown", "moonstat",
    "moonfish", "moonmoon", "moonrobo", "bookkeeper", "lepusa", "rabbita",
  ]
}

///|
pub fn product_display_name(product_id : String) -> String {
  match product_id {
    "moondesk" => "Moondesk"
    "moonbook" => "MoonBook"
    "moonwiki" => "MoonWiki"
    "mooncode" => "MoonCode"
    "moonclaw" => "MoonClaw"
    "moontown" => "Moontown"
    "moonstat" => "MoonStat"
    "moonfish" => "MoonFish"
    "moonmoon" => "MoonMoon"
    "moonrobo" => "MoonRobo"
    "bookkeeper" => "Bookkeeper"
    "lepusa" => "Lepusa"
    "rabbita" => "Rabbita"
    _ => product_id
  }
}

///|
pub fn suite_manifest(root : String) -> Json {
  {
    "kind": "moonsuite-root.v1",
    "root_path": suite_root(root),
    "books_path": books_root(root),
    "tmp_path": tmp_root(root),
  }
}

///|
pub fn product_registry(root : String) -> Json {
  let entries : Array[Json] = []
  for product_id in default_product_ids() {
    entries.push({
      "id": product_id,
      "name": product_display_name(product_id),
      "kind": "moon-suite-product",
      "state_path": product_dir(root, product_id),
      "service_path": product_service_path(root, product_id),
      "repo_path": "",
      "status": "installed",
      "capabilities": Json::array([]),
    })
  }
  { "kind": "moonsuite-product-registry.v1", "products": Json::array(entries) }
}
