///|
pub fn autonomy_artifact_ref_is_safe(path : String) -> Bool {
  let normalized = path.trim().replace(old="\\", new="/")
  !normalized.is_empty() &&
  !normalized.has_prefix("/") &&
  !normalized.split("/").any(segment => segment == ".." || segment == "")
}

///|
pub fn autonomy_digest_is_valid(digest : String) -> Bool {
  digest.has_prefix("sha256:") && digest.length() == 71
}

///|
pub fn autonomy_timestamp_is_canonical(timestamp : String) -> Bool {
  timestamp.length() >= 20 &&
  timestamp.contains("T") &&
  timestamp.has_suffix("Z")
}

///|
fn autonomy_grant_for_product(
  envelope : AutonomyEnvelope,
  product_id : String,
) -> AutonomyGrant? {
  for grant in envelope.grants {
    if grant.product_id == product_id {
      return Some(grant)
    }
  }
  None
}

///|
fn autonomy_path_matches_prefix(path : String, prefix : String) -> Bool {
  path == prefix || path.has_prefix(prefix + "/")
}

///|
fn autonomy_remaining(
  budget : AutonomyBudget,
  usage : AutonomyBudgetUsage,
  request : AutonomyBudgetUsage,
) -> AutonomyBudgetBalance {
  {
    model_tokens: budget.model_tokens -
    usage.model_tokens -
    request.model_tokens,
    tool_calls: budget.tool_calls - usage.tool_calls - request.tool_calls,
    storage_bytes: budget.storage_bytes -
    usage.storage_bytes -
    request.storage_bytes,
    attempts: budget.attempts - usage.attempts - request.attempts,
    concurrency: budget.concurrency - usage.concurrency - request.concurrency,
  }
}

///|
pub fn authorize_autonomy_event(
  envelope : AutonomyEnvelope,
  event : AutonomyEventRequest,
  usage : AutonomyBudgetUsage,
  decision_id : String,
  checked_at : String,
) -> AutonomyDecision {
  let findings = envelope.quality_issues()
  if decision_id.trim().is_empty() {
    findings.push("decision_id is required")
  }
  if event.contract_id != "moongate.autonomy-event-request.v1" {
    findings.push("unsupported autonomy event request contract")
  }
  for
    pair in [
      ("event_id", event.event_id),
      ("run_id", event.run_id),
      ("product_id", event.product_id),
      ("operation", event.operation),
    ] {
    let (field, value) = pair
    if value.trim().is_empty() {
      findings.push("event \{field} is required")
    }
  }
  if !autonomy_timestamp_is_canonical(event.recorded_at) {
    findings.push("event recorded_at must be canonical UTC")
  }
  if !autonomy_timestamp_is_canonical(checked_at) {
    findings.push("checked_at must be canonical UTC")
  }
  if envelope.revoked {
    findings.push("autonomy envelope is revoked")
  }
  if autonomy_timestamp_is_canonical(envelope.expires_at) &&
    autonomy_timestamp_is_canonical(checked_at) &&
    checked_at >= envelope.expires_at {
    findings.push("autonomy envelope is expired")
  }
  if event.requested_authority.requires_explicit_human() {
    findings.push(
      "unattended execution cannot request external or physical authority",
    )
  }
  if event.claim.allows(PhysicalReadiness) {
    findings.push("unattended execution cannot claim physical readiness")
  }
  if !event.external_destination.trim().is_empty() {
    findings.push("unattended execution cannot declare an external destination")
  }
  match autonomy_grant_for_product(envelope, event.product_id) {
    None => findings.push("product is not granted by the autonomy envelope")
    Some(grant) => {
      if !grant.operations.contains(event.operation) {
        findings.push("operation is outside the autonomy grant")
      }
      if !grant.authority_ceiling.allows(event.requested_authority) {
        findings.push("requested authority exceeds the autonomy grant")
      }
      if !grant.claim_ceiling.allows(event.claim) {
        findings.push("claim exceeds the autonomy grant")
      }
      for path in event.artifact_paths {
        if !autonomy_artifact_ref_is_safe(path) {
          findings.push("artifact path is not workspace-relative: \{path}")
        } else if !grant.artifact_prefixes.any(prefix => {
            autonomy_path_matches_prefix(path, prefix)
          }) {
          findings.push("artifact path is outside the product grant: \{path}")
        }
      }
    }
  }
  for issue in usage.quality_issues() {
    findings.push(issue)
  }
  for issue in event.budget_request.quality_issues() {
    findings.push("budget request: \{issue}")
  }
  let remaining = autonomy_remaining(
    envelope.budget,
    usage,
    event.budget_request,
  )
  for
    pair in [
      ("model_tokens", remaining.model_tokens),
      ("tool_calls", remaining.tool_calls),
      ("storage_bytes", remaining.storage_bytes),
      ("attempts", remaining.attempts),
      ("concurrency", remaining.concurrency),
    ] {
    let (field, value) = pair
    if value < 0 {
      findings.push("autonomy budget exceeded: \{field}")
    }
  }
  {
    contract_id: "moongate.autonomy-decision.v1",
    decision_id,
    envelope_id: envelope.envelope_id,
    event_id: event.event_id,
    accepted: findings.is_empty(),
    findings,
    remaining_budget: remaining,
    checked_at,
  }
}
