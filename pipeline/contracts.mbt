///|
pub fn contract_family() -> String {
  "moonsuite-pipeline.v1"
}

///|
pub(all) enum ContractKind {
  Identity
  Authority
  ArtifactRef
  ExecutableDocument
  WorkModel
  KnowledgeGap
  BeliefUpdate
  BookkeeperReflection
  LearnedProcedure
  TownCommission
  TownPromotion
  ModelRoute
  RunReceipt
  BookReadiness
  EvidenceEnvelope
  ChangeReceipt
  BookMessage
  RobotDesign
  ConstitutionConformance
  AutonomyEnvelope
  AutonomyDecision
  InterventionScorecard
  BrowserSession
  BrowserActionReceiptContract
  SpatialArtifact
  RepresentationTransformContract
} derive(Debug, Eq, Compare, Hash, ToJson)

///|
pub fn ContractKind::id(self : ContractKind) -> String {
  match self {
    Identity => "moonsuite.identity.v1"
    Authority => "moonsuite.authority.v1"
    ArtifactRef => "moonsuite.artifact-ref.v1"
    ExecutableDocument => "moonsuite.executable-document.v1"
    WorkModel => "moonsuite.work-model.v1"
    KnowledgeGap => "moonbook.knowledge-gap.v1"
    BeliefUpdate => "moonbook.belief-update.v1"
    BookkeeperReflection => "moonbook.bookkeeper-reflection.v1"
    LearnedProcedure => "moonbook.learned-procedure.v1"
    TownCommission => "moontown.commission.v1"
    TownPromotion => "moontown.promotion.v1"
    ModelRoute => "moonsuite.model-route.v1"
    RunReceipt => "moonsuite.run-receipt.v1"
    BookReadiness => "moonsuite.book-readiness.v1"
    EvidenceEnvelope => "moonsuite.evidence-envelope.v1"
    ChangeReceipt => "moonsuite.change-receipt.v1"
    BookMessage => "moonsuite.book-message.v1"
    RobotDesign => "moonsuite.robot-design.v1"
    ConstitutionConformance => "moonsuite.constitution-conformance.v1"
    AutonomyEnvelope => "moongate.autonomy-envelope.v1"
    AutonomyDecision => "moongate.autonomy-decision.v1"
    InterventionScorecard => "moonflow.intervention-scorecard.v1"
    BrowserSession => "moonsuite.browser-session.v1"
    BrowserActionReceiptContract => "moonsuite.browser-action-receipt.v1"
    SpatialArtifact => "moonmold.spatial-artifact.v1"
    RepresentationTransformContract => "moonmold.representation-transform.v1"
  }
}

///|
pub fn contract_kinds() -> Array[ContractKind] {
  [
    Identity,
    Authority,
    ArtifactRef,
    ExecutableDocument,
    WorkModel,
    KnowledgeGap,
    BeliefUpdate,
    BookkeeperReflection,
    LearnedProcedure,
    TownCommission,
    TownPromotion,
    ModelRoute,
    RunReceipt,
    BookReadiness,
    EvidenceEnvelope,
    ChangeReceipt,
    BookMessage,
    RobotDesign,
    ConstitutionConformance,
    AutonomyEnvelope,
    AutonomyDecision,
    InterventionScorecard,
    BrowserSession,
    BrowserActionReceiptContract,
    SpatialArtifact,
    RepresentationTransformContract,
  ]
}

///|
pub fn required_fields(kind : ContractKind) -> Array[String] {
  match kind {
    Identity => ["contract_id", "kind", "id", "revision", "recorded_at"]
    Authority =>
      [
        "contract_id", "authority_id", "actor_id", "class", "scope", "granted_by",
        "recorded_at",
      ]
    ArtifactRef =>
      [
        "contract_id", "artifact_id", "producer", "digest", "uri", "authority", "recorded_at",
      ]
    ExecutableDocument =>
      [
        "contract_id", "book_id", "revision", "declarations", "source_digest", "recorded_at",
      ]
    WorkModel =>
      [
        "contract_id", "graph_id", "book_id", "declaration_revision", "items", "recorded_at",
      ]
    KnowledgeGap =>
      [
        "contract_id", "gap_id", "book_id", "kind", "question", "required_by", "missing",
        "resolution_criteria", "status", "recorded_at",
      ]
    BeliefUpdate =>
      [
        "contract_id", "update_id", "book_id", "belief_id", "statement", "change",
        "evidence_refs", "confidence", "affected_refs", "recorded_at",
      ]
    BookkeeperReflection =>
      [
        "contract_id", "reflection_id", "book_id", "trigger", "observations", "gaps",
        "belief_updates", "proposed_actions", "learned_procedures", "confidence",
        "requested_authority", "recorded_at",
      ]
    LearnedProcedure =>
      [
        "contract_id", "procedure_id", "book_id", "title", "applicability", "steps",
        "verification_criteria", "failure_modes", "evidence_refs", "status", "recorded_at",
      ]
    TownCommission =>
      [
        "contract_id", "commission_id", "work_item_id", "scope", "perspectives",
        "evidence_requirements", "budget", "deadline", "requested_output", "recorded_at",
      ]
    TownPromotion =>
      [
        "contract_id", "promotion_id", "candidate_id", "origin", "contributors",
        "evidence_refs", "dissent", "expected_value", "success_criteria", "risks",
        "requested_authority", "draft_graph", "recorded_at",
      ]
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
    ConstitutionConformance =>
      [
        "contract_id", "report_id", "subject_id", "product_id", "accepted", "findings",
        "checked_at",
      ]
    AutonomyEnvelope =>
      [
        "contract_id", "envelope_id", "mode", "goal_ref", "workspace_root", "grants",
        "budget", "external_effects_allowed", "physical_effects_allowed", "granted_by",
        "source_digest", "recorded_at", "expires_at", "revoked",
      ]
    AutonomyDecision =>
      [
        "contract_id", "decision_id", "envelope_id", "event_id", "accepted", "findings",
        "remaining_budget", "checked_at",
      ]
    InterventionScorecard =>
      [
        "contract_id", "run_id", "constitutional_authority_count", "optional_observation_count",
        "required_intervention_count", "hidden_orchestration_count", "normal_path_intervention_count",
        "unattended_qualified", "records", "checked_at",
      ]
    BrowserSession =>
      [
        "contract_id", "session_id", "book_id", "book_revision", "code_revision",
        "run_id", "artifact_id", "authority_envelope_id", "origin_class", "network_policy",
        "allowed_origins", "allowed_operations", "upload_artifact_refs", "download_root",
        "storage_lifetime", "capability_digest", "expires_at",
      ]
    BrowserActionReceiptContract =>
      [
        "contract_id", "receipt_id", "session_id", "action_id", "actor_kind", "actor_id",
        "operation", "semantic_target", "redacted_arguments", "expected_observation",
        "authority_decision_ref", "before_digest", "after_digest", "outcome", "observations",
        "evidence_refs", "completed_at",
      ]
    SpatialArtifact =>
      [
        "contract_id", "artifact_id", "project_id", "representation", "parent_artifact_ids",
        "digest", "payload_ref", "units", "coordinate_system", "up_axis", "handedness",
        "source_refs", "backend_id", "backend_version", "procedure_ref", "authority_envelope_id",
        "assumptions", "unresolved_gaps", "validation_refs", "intended_consumers",
        "forbidden_consumers", "claim_ceiling", "recorded_at",
      ]
    RepresentationTransformContract =>
      [
        "contract_id", "transform_id", "parent_artifact_id", "parent_digest", "parent_representation",
        "child_artifact_id", "child_digest", "child_representation", "lineage_relation",
        "operation", "parameters_digest", "tool_id", "tool_version", "authority_ref",
        "declared_losses", "validation_refs", "recorded_at",
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
