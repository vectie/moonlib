///|
/// The amount of operational detail requested by a Moon Suite surface.
///
/// Disclosure changes presentation only. It never changes authority, evidence,
/// or the canonical state of a run.
pub(all) enum DisclosureLevel {
  User
  Operator
  Developer
} derive(Debug, Eq, Compare, Hash, ToJson)

///|
pub fn DisclosureLevel::id(self : DisclosureLevel) -> String {
  match self {
    User => "user"
    Operator => "operator"
    Developer => "developer"
  }
}

///|
pub fn disclosure_level_from_id(id : String) -> DisclosureLevel raise {
  match id {
    "user" => User
    "operator" => Operator
    "developer" => Developer
    _ => fail("unsupported disclosure level: \{id}")
  }
}

///|
/// A browser operation is typed before MoonGate evaluates its authority.
pub(all) enum BrowserOperation {
  RenderLocal
  InspectPage
  InteractLocal
  SaveWorkspace
  NavigateExternal
  UploadExternal
  DownloadExternal
  SubmitExternal
  ControlPhysicalDevice
} derive(Debug, Eq, Compare, Hash, ToJson)

///|
pub fn BrowserOperation::id(self : BrowserOperation) -> String {
  match self {
    RenderLocal => "render-local"
    InspectPage => "inspect-page"
    InteractLocal => "interact-local"
    SaveWorkspace => "save-workspace"
    NavigateExternal => "navigate-external"
    UploadExternal => "upload-external"
    DownloadExternal => "download-external"
    SubmitExternal => "submit-external"
    ControlPhysicalDevice => "control-physical-device"
  }
}

///|
pub fn BrowserOperation::required_authority(
  self : BrowserOperation,
) -> AuthorityClass {
  match self {
    RenderLocal | InspectPage => Observe
    InteractLocal => SandboxExecution
    SaveWorkspace => WorkspaceMutation
    NavigateExternal | UploadExternal | DownloadExternal | SubmitExternal =>
      ExternalEffect
    ControlPhysicalDevice => PhysicalEffect
  }
}

///|
pub fn browser_operation_from_id(id : String) -> BrowserOperation raise {
  match id {
    "render-local" => RenderLocal
    "inspect-page" => InspectPage
    "interact-local" => InteractLocal
    "save-workspace" => SaveWorkspace
    "navigate-external" => NavigateExternal
    "upload-external" => UploadExternal
    "download-external" => DownloadExternal
    "submit-external" => SubmitExternal
    "control-physical-device" => ControlPhysicalDevice
    _ => fail("unsupported browser operation: \{id}")
  }
}

///|
pub(all) enum BrowserActor {
  HumanUser
  Agent
  Replay
} derive(Debug, Eq, Compare, Hash, ToJson)

///|
pub fn BrowserActor::id(self : BrowserActor) -> String {
  match self {
    HumanUser => "user"
    Agent => "agent"
    Replay => "replay"
  }
}

///|
pub(all) struct BrowserSessionScope {
  contract_id : String
  session_id : String
  book_id : String
  book_revision : String
  code_revision : String
  run_id : String
  artifact_id : String
  authority_envelope_id : String
  origin_class : String
  network_policy : String
  allowed_origins : Array[String]
  allowed_operations : Array[BrowserOperation]
  upload_artifact_refs : Array[String]
  download_root : String
  storage_lifetime : String
  capability_digest : String
  expires_at : String
} derive(Debug, Eq, ToJson)

///|
fn embodied_relative_path_is_safe(path : String) -> Bool {
  let normalized = path.trim().replace(old="\\", new="/")
  !normalized.is_empty() &&
  !normalized.has_prefix("/") &&
  !normalized.split("/").any(segment => segment == "..")
}

///|
fn embodied_origin_is_loopback(origin : String) -> Bool {
  origin.has_prefix("http://127.0.0.1:") ||
  origin.has_prefix("http://[::1]:") ||
  origin.has_prefix("http://localhost:")
}

///|
pub fn BrowserSessionScope::quality_issues(
  self : BrowserSessionScope,
) -> Array[String] {
  let issues : Array[String] = []
  if self.contract_id != "moonsuite.browser-session.v1" {
    issues.push("contract_id must be moonsuite.browser-session.v1")
  }
  if self.session_id.trim().is_empty() {
    issues.push("session_id is required")
  }
  if self.book_id.trim().is_empty() {
    issues.push("book_id is required")
  }
  if self.book_revision.trim().is_empty() ||
    self.code_revision.trim().is_empty() {
    issues.push("book_revision and code_revision are required")
  }
  if self.artifact_id.trim().is_empty() {
    issues.push("artifact_id is required")
  }
  if self.authority_envelope_id.trim().is_empty() {
    issues.push("authority_envelope_id is required")
  }
  if self.origin_class != "opaque-local" &&
    self.origin_class != "isolated-loopback" &&
    self.origin_class != "external" {
    issues.push(
      "origin_class must be opaque-local, isolated-loopback, or external",
    )
  }
  if self.network_policy != "offline" && self.network_policy != "allowlisted" {
    issues.push("network_policy must be offline or allowlisted")
  }
  if self.storage_lifetime != "ephemeral" &&
    self.storage_lifetime != "run" &&
    self.storage_lifetime != "book" {
    issues.push("storage_lifetime must be ephemeral, run, or book")
  }
  if self.allowed_operations.is_empty() {
    issues.push("at least one browser operation is required")
  }
  if !embodied_relative_path_is_safe(self.download_root) {
    issues.push("download_root must be workspace-relative")
  }
  for artifact_ref in self.upload_artifact_refs {
    if !embodied_relative_path_is_safe(artifact_ref) {
      issues.push("upload artifact refs must be workspace-relative")
    }
  }
  if !autonomy_digest_is_valid(self.capability_digest) {
    issues.push("capability_digest must be a sha256 digest")
  }
  if !autonomy_timestamp_is_canonical(self.expires_at) {
    issues.push("expires_at must be a canonical UTC timestamp")
  }
  if self.origin_class == "opaque-local" && !self.allowed_origins.is_empty() {
    issues.push("opaque-local sessions cannot allow network origins")
  }
  if self.origin_class == "isolated-loopback" &&
    self.allowed_origins.any(origin => !embodied_origin_is_loopback(origin)) {
    issues.push(
      "isolated-loopback sessions allow only explicit loopback origins",
    )
  }
  if self.origin_class != "external" && self.network_policy != "offline" {
    issues.push("local sessions must use the offline network policy")
  }
  issues
}

///|
pub(all) struct BrowserActionReceipt {
  contract_id : String
  receipt_id : String
  session_id : String
  action_id : String
  actor_kind : BrowserActor
  actor_id : String
  operation : BrowserOperation
  semantic_target : String
  redacted_arguments : Array[String]
  expected_observation : String
  authority_decision_ref : String
  before_digest : String
  after_digest : String
  outcome : String
  observations : Array[String]
  evidence_refs : Array[String]
  completed_at : String
} derive(Debug, Eq, ToJson)

///|
pub fn BrowserActionReceipt::quality_issues(
  self : BrowserActionReceipt,
) -> Array[String] {
  let issues : Array[String] = []
  if self.contract_id != "moonsuite.browser-action-receipt.v1" {
    issues.push("contract_id must be moonsuite.browser-action-receipt.v1")
  }
  if self.receipt_id.trim().is_empty() || self.action_id.trim().is_empty() {
    issues.push("receipt_id and action_id are required")
  }
  if self.session_id.trim().is_empty() || self.actor_id.trim().is_empty() {
    issues.push("session_id and actor_id are required")
  }
  if self.semantic_target.trim().is_empty() {
    issues.push("semantic_target is required")
  }
  if self.expected_observation.trim().is_empty() {
    issues.push("expected_observation is required")
  }
  if !autonomy_digest_is_valid(self.before_digest) ||
    !autonomy_digest_is_valid(self.after_digest) {
    issues.push("before_digest and after_digest must be sha256 digests")
  }
  if self.outcome != "accepted" &&
    self.outcome != "rejected" &&
    self.outcome != "failed" &&
    self.outcome != "no-op" {
    issues.push("outcome must be accepted, rejected, failed, or no-op")
  }
  if self.operation.required_authority().requires_explicit_human() &&
    self.authority_decision_ref.trim().is_empty() {
    issues.push(
      "consequential browser operations require an authority decision",
    )
  }
  if !autonomy_timestamp_is_canonical(self.completed_at) {
    issues.push("completed_at must be a canonical UTC timestamp")
  }
  for evidence_ref in self.evidence_refs {
    if !embodied_relative_path_is_safe(evidence_ref) {
      issues.push("browser evidence refs must be workspace-relative")
    }
  }
  issues
}

///|
/// The declared purpose of one spatial artifact representation.
pub(all) enum RepresentationClass {
  ReferenceBundle
  SpatialIntent
  EditableAuthoringModel
  VisualStyledModel
  EngineeringModel
  SimulationModel
  ManufacturingCandidate
  FabricationJob
} derive(Debug, Eq, Compare, Hash, ToJson)

///|
pub fn RepresentationClass::id(self : RepresentationClass) -> String {
  match self {
    ReferenceBundle => "reference-bundle"
    SpatialIntent => "spatial-intent"
    EditableAuthoringModel => "editable-authoring-model"
    VisualStyledModel => "visual-styled-model"
    EngineeringModel => "engineering-model"
    SimulationModel => "simulation-model"
    ManufacturingCandidate => "manufacturing-candidate"
    FabricationJob => "fabrication-job"
  }
}

///|
pub fn representation_class_from_id(id : String) -> RepresentationClass raise {
  match id {
    "reference-bundle" => ReferenceBundle
    "spatial-intent" => SpatialIntent
    "editable-authoring-model" => EditableAuthoringModel
    "visual-styled-model" => VisualStyledModel
    "engineering-model" => EngineeringModel
    "simulation-model" => SimulationModel
    "manufacturing-candidate" => ManufacturingCandidate
    "fabrication-job" => FabricationJob
    _ => fail("unsupported representation class: \{id}")
  }
}

///|
pub fn RepresentationClass::is_engineering_input(
  self : RepresentationClass,
) -> Bool {
  match self {
    EngineeringModel | SimulationModel | ManufacturingCandidate => true
    _ => false
  }
}

///|
pub(all) enum SpatialLineageRelation {
  InterpretedFrom
  ModeledFrom
  DimensionedBy
  StyledFrom
  OptimizedFrom
  CollisionDerivedFrom
  PhysicsDerivedFrom
  ManufacturingDerivedFrom
  ValidatedBy
  RejectedBy
  SupersededBy
  PlacedAs
  SimulatedAs
} derive(Debug, Eq, Compare, Hash, ToJson)

///|
pub fn SpatialLineageRelation::id(self : SpatialLineageRelation) -> String {
  match self {
    InterpretedFrom => "interpreted-from"
    ModeledFrom => "modeled-from"
    DimensionedBy => "dimensioned-by"
    StyledFrom => "styled-from"
    OptimizedFrom => "optimized-from"
    CollisionDerivedFrom => "collision-derived-from"
    PhysicsDerivedFrom => "physics-derived-from"
    ManufacturingDerivedFrom => "manufacturing-derived-from"
    ValidatedBy => "validated-by"
    RejectedBy => "rejected-by"
    SupersededBy => "superseded-by"
    PlacedAs => "placed-as"
    SimulatedAs => "simulated-as"
  }
}

///|
pub fn spatial_lineage_relation_from_id(
  id : String,
) -> SpatialLineageRelation raise {
  match id {
    "interpreted-from" => InterpretedFrom
    "modeled-from" => ModeledFrom
    "dimensioned-by" => DimensionedBy
    "styled-from" => StyledFrom
    "optimized-from" => OptimizedFrom
    "collision-derived-from" => CollisionDerivedFrom
    "physics-derived-from" => PhysicsDerivedFrom
    "manufacturing-derived-from" => ManufacturingDerivedFrom
    "validated-by" => ValidatedBy
    "rejected-by" => RejectedBy
    "superseded-by" => SupersededBy
    "placed-as" => PlacedAs
    "simulated-as" => SimulatedAs
    _ => fail("unsupported spatial lineage relation: \{id}")
  }
}

///|
pub fn representation_transition_issues(
  parent : RepresentationClass,
  child : RepresentationClass,
) -> Array[String] {
  let issues : Array[String] = []
  if parent == VisualStyledModel && child.is_engineering_input() {
    issues.push("styled geometry cannot become an engineering input")
  }
  if child == ManufacturingCandidate && parent != EngineeringModel {
    issues.push("manufacturing candidates must descend from engineering models")
  }
  if child == FabricationJob && parent != ManufacturingCandidate {
    issues.push("fabrication jobs must descend from manufacturing candidates")
  }
  issues
}

///|
pub(all) struct SpatialArtifactManifest {
  contract_id : String
  artifact_id : String
  project_id : String
  representation : RepresentationClass
  parent_artifact_ids : Array[String]
  digest : String
  payload_ref : String
  units : String
  coordinate_system : String
  up_axis : String
  handedness : String
  source_refs : Array[String]
  backend_id : String
  backend_version : String
  procedure_ref : String
  authority_envelope_id : String
  assumptions : Array[String]
  unresolved_gaps : Array[String]
  validation_refs : Array[String]
  intended_consumers : Array[String]
  forbidden_consumers : Array[String]
  claim_ceiling : ClaimClass
  recorded_at : String
} derive(Debug, Eq, ToJson)

///|
pub fn SpatialArtifactManifest::quality_issues(
  self : SpatialArtifactManifest,
) -> Array[String] {
  let issues : Array[String] = []
  if self.contract_id != "moonmold.spatial-artifact.v1" {
    issues.push("contract_id must be moonmold.spatial-artifact.v1")
  }
  if self.artifact_id.trim().is_empty() || self.project_id.trim().is_empty() {
    issues.push("artifact_id and project_id are required")
  }
  if !autonomy_digest_is_valid(self.digest) {
    issues.push("digest must be a sha256 digest")
  }
  if !embodied_relative_path_is_safe(self.payload_ref) {
    issues.push("payload_ref must be workspace-relative")
  }
  if self.units.trim().is_empty() ||
    self.coordinate_system.trim().is_empty() ||
    self.up_axis.trim().is_empty() ||
    self.handedness.trim().is_empty() {
    issues.push("units and coordinate conventions are required")
  }
  if self.backend_id.trim().is_empty() || self.backend_version.trim().is_empty() {
    issues.push("backend identity and version are required")
  }
  if self.procedure_ref.trim().is_empty() {
    issues.push("procedure_ref is required")
  }
  if self.authority_envelope_id.trim().is_empty() {
    issues.push("authority_envelope_id is required")
  }
  if self.intended_consumers.is_empty() {
    issues.push("at least one intended consumer is required")
  }
  if self.representation == VisualStyledModel &&
    (
      self.intended_consumers.contains("moonrobo") ||
      self.intended_consumers.contains("moonmoon")
    ) {
    issues.push("styled geometry cannot be an engineering or simulation input")
  }
  if self.representation == FabricationJob &&
    !self.claim_ceiling.allows(PhysicalEffectClaim) {
    issues.push("fabrication jobs require a physical-effect claim ceiling")
  }
  if self.representation != FabricationJob &&
    self.claim_ceiling.allows(PhysicalEffectClaim) {
    issues.push("digital spatial artifacts cannot claim physical effects")
  }
  if !autonomy_timestamp_is_canonical(self.recorded_at) {
    issues.push("recorded_at must be a canonical UTC timestamp")
  }
  issues
}

///|
pub(all) struct RepresentationTransform {
  contract_id : String
  transform_id : String
  parent_artifact_id : String
  parent_digest : String
  parent_representation : RepresentationClass
  child_artifact_id : String
  child_digest : String
  child_representation : RepresentationClass
  lineage_relation : SpatialLineageRelation
  operation : String
  parameters_digest : String
  tool_id : String
  tool_version : String
  authority_ref : String
  declared_losses : Array[String]
  validation_refs : Array[String]
  recorded_at : String
} derive(Debug, Eq, ToJson)

///|
pub fn RepresentationTransform::quality_issues(
  self : RepresentationTransform,
) -> Array[String] {
  let issues = representation_transition_issues(
    self.parent_representation,
    self.child_representation,
  )
  match self.lineage_relation {
    StyledFrom | OptimizedFrom | PlacedAs =>
      if self.child_representation != VisualStyledModel {
        issues.push("visual lineage relations require a styled child")
      }
    CollisionDerivedFrom | PhysicsDerivedFrom | SimulatedAs =>
      if self.parent_representation != EngineeringModel ||
        self.child_representation != SimulationModel {
        issues.push(
          "simulation lineage must derive a simulation child from engineering geometry",
        )
      }
    ManufacturingDerivedFrom =>
      if self.parent_representation != EngineeringModel ||
        self.child_representation != ManufacturingCandidate {
        issues.push(
          "manufacturing lineage must derive a candidate from engineering geometry",
        )
      }
    _ => ()
  }
  if self.contract_id != "moonmold.representation-transform.v1" {
    issues.push("contract_id must be moonmold.representation-transform.v1")
  }
  if self.transform_id.trim().is_empty() ||
    self.parent_artifact_id.trim().is_empty() ||
    self.child_artifact_id.trim().is_empty() {
    issues.push("transform and artifact identities are required")
  }
  if !autonomy_digest_is_valid(self.parent_digest) ||
    !autonomy_digest_is_valid(self.child_digest) ||
    !autonomy_digest_is_valid(self.parameters_digest) {
    issues.push("parent, child, and parameter digests must be sha256 digests")
  }
  if self.operation.trim().is_empty() ||
    self.tool_id.trim().is_empty() ||
    self.tool_version.trim().is_empty() {
    issues.push("operation, tool identity, and tool version are required")
  }
  if self.authority_ref.trim().is_empty() {
    issues.push("authority_ref is required")
  }
  if !autonomy_timestamp_is_canonical(self.recorded_at) {
    issues.push("recorded_at must be a canonical UTC timestamp")
  }
  issues
}
