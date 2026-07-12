///|
fn unattended_envelope() -> AutonomyEnvelope {
  {
    contract_id: "moongate.autonomy-envelope.v1",
    envelope_id: "envelope-clean-run",
    mode: "unattended-digital",
    goal_ref: "goals/goal.json",
    workspace_root: "/tmp/moonsuite",
    grants: [
      {
        product_id: "moonflow",
        operations: ["dispatch"],
        authority_ceiling: SandboxExecution,
        claim_ceiling: ScenarioQualified,
        artifact_prefixes: ["books", ".moonsuite/products/moonflow"],
      },
    ],
    budget: {
      model_tokens: 1000,
      tool_calls: 20,
      storage_bytes: 10000,
      attempts: 5,
      concurrency: 2,
    },
    external_effects_allowed: false,
    physical_effects_allowed: false,
    granted_by: "human-owner",
    source_digest: "sha256:" + "a".repeat(64),
    recorded_at: "2026-07-12T04:00:00Z",
    expires_at: "2026-07-13T04:00:00Z",
    revoked: false,
  }
}

///|
fn unattended_event() -> AutonomyEventRequest {
  {
    contract_id: "moongate.autonomy-event-request.v1",
    event_id: "event-dispatch-1",
    run_id: "run-1",
    product_id: "moonflow",
    operation: "dispatch",
    requested_authority: SandboxExecution,
    claim: ScenarioQualified,
    artifact_paths: ["books/robot/evidence/result.json"],
    external_destination: "",
    budget_request: {
      model_tokens: 100,
      tool_calls: 2,
      storage_bytes: 200,
      attempts: 1,
      concurrency: 1,
    },
    recorded_at: "2026-07-12T04:01:00Z",
  }
}

///|
test "unattended envelope authorizes only scoped digital work" {
  let decision = authorize_autonomy_event(
    unattended_envelope(),
    unattended_event(),
    {
      model_tokens: 0,
      tool_calls: 0,
      storage_bytes: 0,
      attempts: 0,
      concurrency: 0,
    },
    "decision-1",
    "2026-07-12T04:01:00Z",
  )
  assert_true(decision.accepted)
  assert_eq(decision.remaining_budget.model_tokens, 900)
}

///|
test "autonomy wire round trips canonical authority and claim ids" {
  let envelope = unattended_envelope()
  let decoded = decode_autonomy_envelope(autonomy_envelope_json(envelope))
  assert_true(decoded == envelope)
  let event = unattended_event()
  let decoded_event = decode_autonomy_event_request(
    autonomy_event_request_json(event),
  )
  assert_true(decoded_event == event)
}

///|
test "unattended envelope fails closed on authority claim path and budget" {
  let event = {
    ..unattended_event(),
    requested_authority: PhysicalEffect,
    claim: PhysicalReadiness,
    artifact_paths: ["../outside.json"],
    external_destination: "https://example.com/upload",
    budget_request: {
      model_tokens: 2000,
      tool_calls: 2,
      storage_bytes: 200,
      attempts: 1,
      concurrency: 1,
    },
  }
  let decision = authorize_autonomy_event(
    unattended_envelope(),
    event,
    {
      model_tokens: 0,
      tool_calls: 0,
      storage_bytes: 0,
      attempts: 0,
      concurrency: 0,
    },
    "decision-negative",
    "2026-07-12T04:01:00Z",
  )
  assert_false(decision.accepted)
  assert_true(
    decision.findings.contains(
      "unattended execution cannot request external or physical authority",
    ),
  )
  assert_true(
    decision.findings.contains(
      "unattended execution cannot claim physical readiness",
    ),
  )
  assert_true(
    decision.findings.contains("autonomy budget exceeded: model_tokens"),
  )
}

///|
test "revoked and expired unattended envelopes fail closed" {
  let event = unattended_event()
  let usage : AutonomyBudgetUsage = {
    model_tokens: 0,
    tool_calls: 0,
    storage_bytes: 0,
    attempts: 0,
    concurrency: 0,
  }
  let revoked = authorize_autonomy_event(
    { ..unattended_envelope(), revoked: true },
    event,
    usage,
    "decision-revoked",
    "2026-07-12T04:01:00Z",
  )
  assert_false(revoked.accepted)
  assert_true(revoked.findings.contains("autonomy envelope is revoked"))
  let expired = authorize_autonomy_event(
    unattended_envelope(),
    event,
    usage,
    "decision-expired",
    "2026-07-13T04:00:00Z",
  )
  assert_false(expired.accepted)
  assert_true(expired.findings.contains("autonomy envelope is expired"))
}

///|
test "intervention scorecard separates constitutional observation and hidden work" {
  let clean = intervention_scorecard(
    "run-clean",
    [
      {
        intervention_id: "start",
        category: ConstitutionalAuthority,
        normal_path: false,
        product_id: "moongate",
        reason: "human approved the original digital envelope",
        evidence_ref: "goals/envelope.json",
        recorded_at: "2026-07-12T04:00:00Z",
      },
      {
        intervention_id: "watch",
        category: OptionalObservation,
        normal_path: false,
        product_id: "moondesk",
        reason: "operator inspected progress",
        evidence_ref: "runs/run-clean/projection.json",
        recorded_at: "2026-07-12T04:02:00Z",
      },
    ],
    "2026-07-12T04:03:00Z",
  )
  assert_true(clean.unattended_qualified)
  let hidden = intervention_scorecard(
    "run-hidden",
    [
      {
        intervention_id: "manual-handoff",
        category: HiddenOrchestration,
        normal_path: true,
        product_id: "moonflow",
        reason: "operator copied an adapter result",
        evidence_ref: "runs/run-hidden/interventions.json",
        recorded_at: "2026-07-12T04:04:00Z",
      },
    ],
    "2026-07-12T04:05:00Z",
  )
  assert_false(hidden.unattended_qualified)
  assert_eq(hidden.hidden_orchestration_count, 1)
}
