///|
fn autonomy_wire_object(
  value : Json,
  label : String,
) -> Map[String, Json] raise {
  match value {
    Object(fields) => fields
    _ => fail("\{label} must be an object")
  }
}

///|
fn autonomy_wire_string(
  fields : Map[String, Json],
  key : String,
) -> String raise {
  match fields.get(key) {
    Some(String(value)) if !value.trim().is_empty() => value
    _ => fail("autonomy contract requires string field: \{key}")
  }
}

///|
fn autonomy_wire_optional_string(
  fields : Map[String, Json],
  key : String,
) -> String raise {
  match fields.get(key) {
    Some(String(value)) => value
    None => ""
    _ => fail("autonomy contract field must be a string: \{key}")
  }
}

///|
fn autonomy_wire_int(fields : Map[String, Json], key : String) -> Int raise {
  match fields.get(key) {
    Some(Number(value, ..)) => value.to_int()
    _ => fail("autonomy contract requires integer field: \{key}")
  }
}

///|
fn autonomy_wire_bool(fields : Map[String, Json], key : String) -> Bool raise {
  match fields.get(key) {
    Some(True) => true
    Some(False) => false
    _ => fail("autonomy contract requires boolean field: \{key}")
  }
}

///|
fn autonomy_wire_strings(
  fields : Map[String, Json],
  key : String,
) -> Array[String] raise {
  guard fields.get(key) is Some(Array(values)) else {
    fail("autonomy contract requires array field: \{key}")
  }
  values.map(value => {
    match value {
      String(text) if !text.trim().is_empty() => text
      _ => fail("autonomy contract array \{key} requires non-empty strings")
    }
  })
}

///|
fn autonomy_wire_string_array(values : Array[String]) -> Json {
  values.to_json()
}

///|
pub fn decode_autonomy_budget(value : Json) -> AutonomyBudget raise {
  let fields = autonomy_wire_object(value, "autonomy budget")
  {
    model_tokens: autonomy_wire_int(fields, "model_tokens"),
    tool_calls: autonomy_wire_int(fields, "tool_calls"),
    storage_bytes: autonomy_wire_int(fields, "storage_bytes"),
    attempts: autonomy_wire_int(fields, "attempts"),
    concurrency: autonomy_wire_int(fields, "concurrency"),
  }
}

///|
pub fn decode_autonomy_budget_usage(value : Json) -> AutonomyBudgetUsage raise {
  let fields = autonomy_wire_object(value, "autonomy budget usage")
  {
    model_tokens: autonomy_wire_int(fields, "model_tokens"),
    tool_calls: autonomy_wire_int(fields, "tool_calls"),
    storage_bytes: autonomy_wire_int(fields, "storage_bytes"),
    attempts: autonomy_wire_int(fields, "attempts"),
    concurrency: autonomy_wire_int(fields, "concurrency"),
  }
}

///|
fn decode_autonomy_grant(value : Json) -> AutonomyGrant raise {
  let fields = autonomy_wire_object(value, "autonomy grant")
  {
    product_id: autonomy_wire_string(fields, "product_id"),
    operations: autonomy_wire_strings(fields, "operations"),
    authority_ceiling: authority_class_from_id(
      autonomy_wire_string(fields, "authority_ceiling"),
    ),
    claim_ceiling: claim_class_from_id(
      autonomy_wire_string(fields, "claim_ceiling"),
    ),
    artifact_prefixes: autonomy_wire_strings(fields, "artifact_prefixes"),
  }
}

///|
pub fn decode_autonomy_envelope(value : Json) -> AutonomyEnvelope raise {
  let fields = autonomy_wire_object(value, "autonomy envelope")
  guard fields.get("grants") is Some(Array(grants)) else {
    fail("autonomy envelope requires grants")
  }
  guard fields.get("budget") is Some(budget) else {
    fail("autonomy envelope requires budget")
  }
  {
    contract_id: autonomy_wire_string(fields, "contract_id"),
    envelope_id: autonomy_wire_string(fields, "envelope_id"),
    mode: autonomy_wire_string(fields, "mode"),
    goal_ref: autonomy_wire_string(fields, "goal_ref"),
    workspace_root: autonomy_wire_string(fields, "workspace_root"),
    grants: grants.map(decode_autonomy_grant),
    budget: decode_autonomy_budget(budget),
    external_effects_allowed: autonomy_wire_bool(
      fields, "external_effects_allowed",
    ),
    physical_effects_allowed: autonomy_wire_bool(
      fields, "physical_effects_allowed",
    ),
    granted_by: autonomy_wire_string(fields, "granted_by"),
    source_digest: autonomy_wire_string(fields, "source_digest"),
    recorded_at: autonomy_wire_string(fields, "recorded_at"),
    expires_at: autonomy_wire_string(fields, "expires_at"),
    revoked: autonomy_wire_bool(fields, "revoked"),
  }
}

///|
pub fn decode_autonomy_event_request(
  value : Json,
) -> AutonomyEventRequest raise {
  let fields = autonomy_wire_object(value, "autonomy event request")
  guard fields.get("budget_request") is Some(budget_request) else {
    fail("autonomy event request requires budget_request")
  }
  {
    contract_id: autonomy_wire_string(fields, "contract_id"),
    event_id: autonomy_wire_string(fields, "event_id"),
    run_id: autonomy_wire_string(fields, "run_id"),
    product_id: autonomy_wire_string(fields, "product_id"),
    operation: autonomy_wire_string(fields, "operation"),
    requested_authority: authority_class_from_id(
      autonomy_wire_string(fields, "requested_authority"),
    ),
    claim: claim_class_from_id(autonomy_wire_string(fields, "claim")),
    artifact_paths: autonomy_wire_strings(fields, "artifact_paths"),
    external_destination: autonomy_wire_optional_string(
      fields, "external_destination",
    ),
    budget_request: decode_autonomy_budget_usage(budget_request),
    recorded_at: autonomy_wire_string(fields, "recorded_at"),
  }
}

///|
fn autonomy_budget_json(budget : AutonomyBudget) -> Json {
  {
    "model_tokens": budget.model_tokens,
    "tool_calls": budget.tool_calls,
    "storage_bytes": budget.storage_bytes,
    "attempts": budget.attempts,
    "concurrency": budget.concurrency,
  }
}

///|
pub fn autonomy_budget_usage_json(usage : AutonomyBudgetUsage) -> Json {
  {
    "model_tokens": usage.model_tokens,
    "tool_calls": usage.tool_calls,
    "storage_bytes": usage.storage_bytes,
    "attempts": usage.attempts,
    "concurrency": usage.concurrency,
  }
}

///|
pub fn autonomy_envelope_json(envelope : AutonomyEnvelope) -> Json {
  {
    "contract_id": envelope.contract_id,
    "envelope_id": envelope.envelope_id,
    "mode": envelope.mode,
    "goal_ref": envelope.goal_ref,
    "workspace_root": envelope.workspace_root,
    "grants": envelope.grants.map(grant => {
      let value : Json = {
        "product_id": grant.product_id,
        "operations": autonomy_wire_string_array(grant.operations),
        "authority_ceiling": grant.authority_ceiling.id(),
        "claim_ceiling": grant.claim_ceiling.id(),
        "artifact_prefixes": autonomy_wire_string_array(grant.artifact_prefixes),
      }
      value
    }),
    "budget": autonomy_budget_json(envelope.budget),
    "external_effects_allowed": envelope.external_effects_allowed,
    "physical_effects_allowed": envelope.physical_effects_allowed,
    "granted_by": envelope.granted_by,
    "source_digest": envelope.source_digest,
    "recorded_at": envelope.recorded_at,
    "expires_at": envelope.expires_at,
    "revoked": envelope.revoked,
  }
}

///|
pub fn autonomy_event_request_json(event : AutonomyEventRequest) -> Json {
  {
    "contract_id": event.contract_id,
    "event_id": event.event_id,
    "run_id": event.run_id,
    "product_id": event.product_id,
    "operation": event.operation,
    "requested_authority": event.requested_authority.id(),
    "claim": event.claim.id(),
    "artifact_paths": autonomy_wire_string_array(event.artifact_paths),
    "external_destination": event.external_destination,
    "budget_request": autonomy_budget_usage_json(event.budget_request),
    "recorded_at": event.recorded_at,
  }
}
