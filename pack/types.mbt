///|
pub(all) enum PackKind {
  DomainPack
  RuntimeExtension
  AppToolBundle
} derive(Debug, Eq, ToJson, FromJson)

///|
pub(all) enum AuthorityClass {
  Observe
  CognitiveMaintenance
  SandboxExecution
  WorkspaceMutation
  ExternalEffect
  PhysicalEffect
} derive(Debug, Eq, ToJson, FromJson)

///|
pub(all) struct ContractRef {
  id : String
  version : String
  path : String
} derive(Debug, Eq, ToJson, FromJson)

///|
pub(all) struct ToolDeclaration {
  id : String
  owner_product : String
  input_schema_id : String
  output_schema_id : String
  authority : AuthorityClass
  idempotent : Bool
  evidence_outputs : Array[String]
  review_required : Bool
} derive(Debug, Eq, ToJson, FromJson)

///|
pub(all) struct ScheduleDeclaration {
  id : String
  cadence : String
  timezone : String
  workflow_id : String
} derive(Debug, Eq, ToJson, FromJson)

///|
pub(all) struct AppEntrypoint {
  id : String
  path : String
  audience : String
} derive(Debug, Eq, ToJson, FromJson)

///|
pub(all) struct MoonPackManifest {
  id : String
  version : String
  display_name : String
  product_id : String
  kind : PackKind
  required_runtime_extensions : Array[String]
  book_templates : Array[ContractRef]
  schemas : Array[ContractRef]
  tools : Array[ToolDeclaration]
  workflows : Array[ContractRef]
  skills : Array[ContractRef]
  policies : Array[ContractRef]
  provider_ports : Array[ContractRef]
  schedules : Array[ScheduleDeclaration]
  app_entrypoints : Array[AppEntrypoint]
  migrations : Array[ContractRef]
  evaluations : Array[ContractRef]
  uninstall_contract : ContractRef?
} derive(Debug, Eq, ToJson, FromJson)

///|
pub(all) struct ValidationIssue {
  path : String
  message : String
} derive(Debug, Eq, ToJson, FromJson)

///|
pub(all) struct ValidationReport {
  ok : Bool
  issues : Array[ValidationIssue]
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn contract_ref(
  id : String,
  version : String,
  path : String,
) -> ContractRef {
  { id, version, path }
}

///|
pub fn tool_declaration(
  id : String,
  owner_product : String,
  input_schema_id : String,
  output_schema_id : String,
  authority : AuthorityClass,
  idempotent? : Bool = true,
  evidence_outputs? : Array[String] = [],
  review_required? : Bool = false,
) -> ToolDeclaration {
  {
    id,
    owner_product,
    input_schema_id,
    output_schema_id,
    authority,
    idempotent,
    evidence_outputs,
    review_required,
  }
}

///|
pub fn schedule_declaration(
  id : String,
  cadence : String,
  timezone : String,
  workflow_id : String,
) -> ScheduleDeclaration {
  { id, cadence, timezone, workflow_id }
}

///|
pub fn app_entrypoint(
  id : String,
  path : String,
  audience : String,
) -> AppEntrypoint {
  { id, path, audience }
}
