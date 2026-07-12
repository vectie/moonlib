///|
pub(all) struct AutonomyBudget {
  model_tokens : Int
  tool_calls : Int
  storage_bytes : Int
  attempts : Int
  concurrency : Int
} derive(Debug, Eq, ToJson)

///|
pub fn AutonomyBudget::quality_issues(self : AutonomyBudget) -> Array[String] {
  let issues : Array[String] = []
  for
    pair in [
      ("model_tokens", self.model_tokens),
      ("tool_calls", self.tool_calls),
      ("storage_bytes", self.storage_bytes),
      ("attempts", self.attempts),
      ("concurrency", self.concurrency),
    ] {
    let (field, value) = pair
    if value < 1 {
      issues.push("budget \{field} must be positive")
    }
  }
  issues
}

///|
pub(all) struct AutonomyBudgetUsage {
  model_tokens : Int
  tool_calls : Int
  storage_bytes : Int
  attempts : Int
  concurrency : Int
} derive(Debug, Eq, ToJson)

///|
pub fn AutonomyBudgetUsage::quality_issues(
  self : AutonomyBudgetUsage,
) -> Array[String] {
  let issues : Array[String] = []
  for
    pair in [
      ("model_tokens", self.model_tokens),
      ("tool_calls", self.tool_calls),
      ("storage_bytes", self.storage_bytes),
      ("attempts", self.attempts),
      ("concurrency", self.concurrency),
    ] {
    let (field, value) = pair
    if value < 0 {
      issues.push("usage \{field} cannot be negative")
    }
  }
  issues
}

///|
pub(all) struct AutonomyGrant {
  product_id : String
  operations : Array[String]
  authority_ceiling : AuthorityClass
  claim_ceiling : ClaimClass
  artifact_prefixes : Array[String]
} derive(Debug, Eq, ToJson)

///|
pub fn AutonomyGrant::quality_issues(self : AutonomyGrant) -> Array[String] {
  let issues : Array[String] = []
  if self.product_id.trim().is_empty() {
    issues.push("grant product_id is required")
  }
  if self.operations.is_empty() {
    issues.push("grant operations are required")
  }
  if self.artifact_prefixes.is_empty() {
    issues.push("grant artifact prefixes are required")
  }
  if self.authority_ceiling.requires_explicit_human() {
    issues.push("unattended grants cannot include external or physical effects")
  }
  if self.claim_ceiling.allows(PhysicalReadiness) {
    issues.push("unattended grants cannot reach physical readiness")
  }
  for prefix in self.artifact_prefixes {
    if !autonomy_artifact_ref_is_safe(prefix) {
      issues.push("grant artifact prefix is invalid: \{prefix}")
    }
  }
  issues
}

///|
pub(all) struct AutonomyEnvelope {
  contract_id : String
  envelope_id : String
  mode : String
  goal_ref : String
  workspace_root : String
  grants : Array[AutonomyGrant]
  budget : AutonomyBudget
  external_effects_allowed : Bool
  physical_effects_allowed : Bool
  granted_by : String
  source_digest : String
  recorded_at : String
  expires_at : String
  revoked : Bool
} derive(Debug, Eq, ToJson)

///|
pub fn AutonomyEnvelope::quality_issues(
  self : AutonomyEnvelope,
) -> Array[String] {
  let issues : Array[String] = []
  if self.contract_id != "moongate.autonomy-envelope.v1" {
    issues.push("unsupported autonomy envelope contract")
  }
  for
    pair in [
      ("envelope_id", self.envelope_id),
      ("goal_ref", self.goal_ref),
      ("workspace_root", self.workspace_root),
      ("granted_by", self.granted_by),
    ] {
    let (field, value) = pair
    if value.trim().is_empty() {
      issues.push("\{field} is required")
    }
  }
  if self.mode != "unattended-digital" {
    issues.push("only unattended-digital mode is supported")
  }
  if !autonomy_artifact_ref_is_safe(self.goal_ref) {
    issues.push("goal_ref must be workspace-relative")
  }
  if self.workspace_root.trim().is_empty() ||
    !(self.workspace_root.has_prefix("/") ||
    (self.workspace_root.length() > 2 && self.workspace_root[1] == ':')) {
    issues.push("workspace_root must be explicit and absolute")
  }
  if self.grants.is_empty() {
    issues.push("at least one autonomy grant is required")
  }
  let products : Array[String] = []
  for grant in self.grants {
    if products.contains(grant.product_id) {
      issues.push("duplicate autonomy grant: \{grant.product_id}")
    } else {
      products.push(grant.product_id)
    }
    for issue in grant.quality_issues() {
      issues.push("grant \{grant.product_id}: \{issue}")
    }
  }
  for issue in self.budget.quality_issues() {
    issues.push(issue)
  }
  if self.external_effects_allowed {
    issues.push("unattended-digital mode cannot allow external effects")
  }
  if self.physical_effects_allowed {
    issues.push("unattended-digital mode cannot allow physical effects")
  }
  if !autonomy_digest_is_valid(self.source_digest) {
    issues.push("source_digest must be a full sha256 digest")
  }
  if !autonomy_timestamp_is_canonical(self.recorded_at) {
    issues.push("recorded_at must be canonical UTC")
  }
  if !autonomy_timestamp_is_canonical(self.expires_at) {
    issues.push("expires_at must be canonical UTC")
  }
  if self.expires_at <= self.recorded_at {
    issues.push("expires_at must be after recorded_at")
  }
  issues
}

///|
pub(all) struct AutonomyEventRequest {
  contract_id : String
  event_id : String
  run_id : String
  product_id : String
  operation : String
  requested_authority : AuthorityClass
  claim : ClaimClass
  artifact_paths : Array[String]
  external_destination : String
  budget_request : AutonomyBudgetUsage
  recorded_at : String
} derive(Debug, Eq, ToJson)

///|
pub(all) struct AutonomyBudgetBalance {
  model_tokens : Int
  tool_calls : Int
  storage_bytes : Int
  attempts : Int
  concurrency : Int
} derive(Debug, Eq, ToJson)

///|
pub(all) struct AutonomyDecision {
  contract_id : String
  decision_id : String
  envelope_id : String
  event_id : String
  accepted : Bool
  findings : Array[String]
  remaining_budget : AutonomyBudgetBalance
  checked_at : String
} derive(Debug, Eq, ToJson)
