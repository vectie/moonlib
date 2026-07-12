///|
pub(all) enum AuthorityClass {
  Observe
  CognitiveMaintenance
  SandboxExecution
  WorkspaceMutation
  ExternalEffect
  PhysicalEffect
} derive(Debug, Eq, Compare, Hash, ToJson)

///|
pub fn AuthorityClass::id(self : AuthorityClass) -> String {
  match self {
    Observe => "observe"
    CognitiveMaintenance => "cognitive-maintenance"
    SandboxExecution => "sandbox-execution"
    WorkspaceMutation => "workspace-mutation"
    ExternalEffect => "external-effect"
    PhysicalEffect => "physical-effect"
  }
}

///|
pub fn authority_class_from_id(id : String) -> AuthorityClass raise {
  match id {
    "observe" => Observe
    "cognitive-maintenance" => CognitiveMaintenance
    "sandbox-execution" => SandboxExecution
    "workspace-mutation" => WorkspaceMutation
    "external-effect" => ExternalEffect
    "physical-effect" => PhysicalEffect
    _ => fail("unsupported authority class: \{id}")
  }
}

///|
fn AuthorityClass::rank(self : AuthorityClass) -> Int {
  match self {
    Observe => 0
    CognitiveMaintenance => 1
    SandboxExecution => 2
    WorkspaceMutation => 3
    ExternalEffect => 4
    PhysicalEffect => 5
  }
}

///|
pub fn AuthorityClass::allows(
  self : AuthorityClass,
  requested : AuthorityClass,
) -> Bool {
  self.rank() >= requested.rank()
}

///|
pub fn AuthorityClass::requires_explicit_human(self : AuthorityClass) -> Bool {
  match self {
    ExternalEffect | PhysicalEffect => true
    _ => false
  }
}

///|
pub(all) struct AuthorityGrant {
  authority_id : String
  actor_id : String
  class : AuthorityClass
  scope : Array[String]
  granted_by : String
  recorded_at : String
} derive(Debug, Eq, ToJson)

///|
pub fn AuthorityGrant::quality_issues(self : AuthorityGrant) -> Array[String] {
  let issues : Array[String] = []
  if self.authority_id.trim().is_empty() {
    issues.push("authority_id is required")
  }
  if self.actor_id.trim().is_empty() {
    issues.push("actor_id is required")
  }
  if self.scope.is_empty() {
    issues.push("authority scope must be explicit")
  }
  if self.granted_by.trim().is_empty() {
    issues.push("granted_by is required")
  }
  if self.recorded_at.trim().is_empty() {
    issues.push("recorded_at is required")
  }
  issues
}
