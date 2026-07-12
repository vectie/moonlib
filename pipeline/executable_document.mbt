///|
pub(all) enum DeclarationKind {
  Goal
  Research
  Build
  Decision
  Experiment
  Validation
  Acceptance
} derive(Debug, Eq, Compare, Hash, ToJson)

///|
pub fn DeclarationKind::id(self : DeclarationKind) -> String {
  match self {
    Goal => "goal"
    Research => "research"
    Build => "build"
    Decision => "decision"
    Experiment => "experiment"
    Validation => "validation"
    Acceptance => "acceptance"
  }
}

///|
pub(all) struct ExecutableDeclaration {
  declaration_id : String
  book_id : String
  revision : String
  kind : DeclarationKind
  title : String
  statement : String
  executor_product : String
  requires : Array[String]
  acceptance_criteria : Array[String]
  requested_authority : AuthorityClass
} derive(Debug, Eq, ToJson)

///|
pub fn ExecutableDeclaration::quality_issues(
  self : ExecutableDeclaration,
) -> Array[String] {
  let issues : Array[String] = []
  if self.declaration_id.trim().is_empty() {
    issues.push("declaration_id is required")
  }
  if self.book_id.trim().is_empty() {
    issues.push("book_id is required")
  }
  if self.revision.trim().is_empty() {
    issues.push("revision is required")
  }
  if self.title.trim().is_empty() {
    issues.push("title is required")
  }
  if self.statement.trim().is_empty() {
    issues.push("statement is required")
  }
  if self.executor_product.trim().is_empty() {
    issues.push("executor_product is required")
  }
  if self.acceptance_criteria.is_empty() {
    issues.push("acceptance criteria are required")
  }
  issues
}

///|
pub fn compile_work_graph(
  graph_id : String,
  book_id : String,
  declaration_revision : String,
  declarations : Array[ExecutableDeclaration],
  recorded_at : String,
) -> WorkGraph {
  let items = declarations.map(declaration => {
    let dependencies = declaration.requires.map(required => "work-\{required}")
    WorkItem::{
      work_item_id: "work-\{declaration.declaration_id}",
      declaration_id: declaration.declaration_id,
      product_id: declaration.executor_product,
      status: if dependencies.is_empty() {
        Ready
      } else {
        Waiting
      },
      depends_on: dependencies,
      input_artifacts: [],
      output_artifacts: [],
      requested_authority: declaration.requested_authority,
      attempt_count: 0,
      blocker: "",
    }
  })
  { graph_id, book_id, declaration_revision, items, recorded_at }
}
