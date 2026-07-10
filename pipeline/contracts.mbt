///|
pub fn contract_family() -> String {
  "moonsuite-pipeline.v1"
}

///|
pub(all) enum ContractKind {
  ModelRoute
  RunReceipt
  BookReadiness
  EvidenceEnvelope
  ChangeReceipt
  BookMessage
  RobotDesign
} derive(Debug, Eq, Compare, Hash, ToJson)

///|
pub fn ContractKind::id(self : ContractKind) -> String {
  match self {
    ModelRoute => "moonsuite.model-route.v1"
    RunReceipt => "moonsuite.run-receipt.v1"
    BookReadiness => "moonsuite.book-readiness.v1"
    EvidenceEnvelope => "moonsuite.evidence-envelope.v1"
    ChangeReceipt => "moonsuite.change-receipt.v1"
    BookMessage => "moonsuite.book-message.v1"
    RobotDesign => "moonsuite.robot-design.v1"
  }
}

///|
pub fn contract_kinds() -> Array[ContractKind] {
  [
    ModelRoute,
    RunReceipt,
    BookReadiness,
    EvidenceEnvelope,
    ChangeReceipt,
    BookMessage,
    RobotDesign,
  ]
}

///|
pub fn required_fields(kind : ContractKind) -> Array[String] {
  match kind {
    ModelRoute =>
      [
        "contract_id", "selected_model", "fallback_models", "selection_reason", "probes",
        "recorded_at",
      ]
    RunReceipt =>
      [
        "contract_id", "run_id", "stage_id", "product_id", "book_id", "status", "inputs",
        "outputs", "quality", "trials", "started_at", "finished_at",
      ]
    BookReadiness =>
      [
        "contract_id", "book_id", "revision", "status", "required_artifacts", "quality",
        "checked_at",
      ]
    EvidenceEnvelope =>
      [
        "contract_id", "evidence_id", "claim", "source_refs", "method", "limitations",
        "quality", "recorded_at",
      ]
    ChangeReceipt =>
      [
        "contract_id", "change_id", "repository", "revision_before", "revision_after",
        "changed_paths", "validations", "recorded_at",
      ]
    BookMessage =>
      [
        "contract_id", "message_id", "from_book_id", "to_book_id", "topic", "claim_refs",
        "artifact_refs", "decision_requested", "recorded_at",
      ]
    RobotDesign =>
      [
        "contract_id", "design_id", "revision", "mission", "environment", "subsystems",
        "interfaces", "constraints", "verification_criteria", "evidence_refs", "limitations",
      ]
  }
}

///|
pub fn quality_dimensions() -> Array[String] {
  ["completeness", "traceability", "consistency", "safety", "replayability"]
}

///|
pub fn terminal_statuses() -> Array[String] {
  ["accepted", "rejected", "blocked", "failed"]
}

///|
pub fn schema_json(kind : ContractKind) -> Json {
  {
    "family": contract_family(),
    "contract_id": kind.id(),
    "required_fields": required_fields(kind),
    "quality_dimensions": quality_dimensions(),
    "terminal_statuses": terminal_statuses(),
    "extension_rule": "Consumers must ignore unknown fields and reject missing required fields.",
    "evidence_rule": "Accepted outputs must cite durable inputs and preserve replayable validation evidence.",
    "boundary_rule": "Simulation evidence must not be represented as physical deployment evidence.",
  }
}

///|
pub fn missing_required_fields(
  kind : ContractKind,
  value : Json,
) -> Array[String] {
  let missing : Array[String] = []
  match value {
    Object(fields) =>
      for field in required_fields(kind) {
        if !fields.contains(field) {
          missing.push(field)
        }
      }
    _ =>
      for field in required_fields(kind) {
        missing.push(field)
      }
  }
  missing
}

///|
pub fn has_required_fields(kind : ContractKind, value : Json) -> Bool {
  missing_required_fields(kind, value).is_empty()
}
