///|
/// Export classification is descriptive, not an authority grant. Secret bytes
/// are never valid members of a portable handover bundle.
pub(all) enum ExportClassificationV1 {
  Public
  Internal
  Confidential
  Secret
} derive(Debug, Eq)

///|
pub fn ExportClassificationV1::id(self : ExportClassificationV1) -> String {
  match self {
    Public => "public"
    Internal => "internal"
    Confidential => "confidential"
    Secret => "secret"
  }
}

///|
fn export_classification_v1_from_id(
  value : String,
) -> ExportClassificationV1 raise CapabilityContractError {
  match value {
    "public" => Public
    "internal" => Internal
    "confidential" => Confidential
    "secret" => Secret
    _ => raise InvalidReference("unsupported export classification: \{value}")
  }
}

///|
/// One content-addressed artifact in a portable handover. The record contains
/// identity and provenance, never the artifact bytes or a credential.
pub struct HandoverBundleEntryV1 {
  artifact : ContentAddressedEvidenceRefV1
  contract : ContractRefV1
  media_type : String
  classification : ExportClassificationV1
  provenance_digest : DigestRefV1
  untrusted_document : Bool
  executable_content : Bool
} derive(Debug, Eq)

///|
pub fn handover_bundle_entry_v1(
  artifact_ref : String,
  artifact_digest : String,
  contract : ContractRefV1,
  media_type : String,
  classification : ExportClassificationV1,
  provenance_digest : String,
  untrusted_document? : Bool = false,
  executable_content? : Bool = false,
) -> HandoverBundleEntryV1 raise CapabilityContractError {
  if media_type.trim().is_empty() || media_type.length() > 256 {
    raise InvalidReference("handover media type is required")
  }
  if classification == Secret {
    raise InvalidReference("secret artifacts cannot enter a handover bundle")
  }
  {
    artifact: content_addressed_evidence_ref(artifact_ref, artifact_digest),
    contract,
    media_type,
    classification,
    provenance_digest: digest_ref_v1(provenance_digest),
    untrusted_document,
    executable_content,
  }
}

///|
pub fn HandoverBundleEntryV1::artifact(
  self : HandoverBundleEntryV1,
) -> ContentAddressedEvidenceRefV1 {
  self.artifact
}

///|
pub fn HandoverBundleEntryV1::contract(
  self : HandoverBundleEntryV1,
) -> ContractRefV1 {
  self.contract
}

///|
pub fn HandoverBundleEntryV1::classification(
  self : HandoverBundleEntryV1,
) -> ExportClassificationV1 {
  self.classification
}

///|
pub fn HandoverBundleEntryV1::untrusted_document(
  self : HandoverBundleEntryV1,
) -> Bool {
  self.untrusted_document
}

///|
pub fn HandoverBundleEntryV1::executable_content(
  self : HandoverBundleEntryV1,
) -> Bool {
  self.executable_content
}

///|
priv struct HandoverBundleEntryWireV1 {
  artifact_ref : String
  artifact_digest : String
  contract_ref : Json
  media_type : String
  classification : String
  provenance_digest : String
  untrusted_document : Bool
  executable_content : Bool
} derive(ToJson, FromJson)

///|
fn handover_bundle_entry_wire_v1(
  entry : HandoverBundleEntryV1,
) -> HandoverBundleEntryWireV1 {
  {
    artifact_ref: entry.artifact.evidence_ref(),
    artifact_digest: entry.artifact.evidence_digest(),
    contract_ref: encode_contract_ref_v1(entry.contract),
    media_type: entry.media_type,
    classification: entry.classification.id(),
    provenance_digest: entry.provenance_digest.text(),
    untrusted_document: entry.untrusted_document,
    executable_content: entry.executable_content,
  }
}

///|
fn decode_handover_bundle_entry_v1(
  value : Json,
) -> HandoverBundleEntryV1 raise CapabilityContractError {
  let wire : HandoverBundleEntryWireV1 = decode_wire(
    value, "moonsuite.handover-bundle-entry.v1",
  )
  handover_bundle_entry_v1(
    wire.artifact_ref,
    wire.artifact_digest,
    decode_contract_ref_v1(wire.contract_ref),
    wire.media_type,
    export_classification_v1_from_id(wire.classification),
    wire.provenance_digest,
    untrusted_document=wire.untrusted_document,
    executable_content=wire.executable_content,
  )
}

///|
priv struct HandoverBundlePayloadWireV1 {
  contract_id : String
  bundle_id : String
  workspace_ref : Json
  created_by : Json
  entries : Array[HandoverBundleEntryWireV1]
  excluded_secret_refs : Array[String]
  created_at : String
} derive(ToJson)

///|
priv struct HandoverBundleWireV1 {
  contract_id : String
  bundle_id : String
  workspace_ref : Json
  created_by : Json
  entries : Array[HandoverBundleEntryWireV1]
  excluded_secret_refs : Array[String]
  created_at : String
  content_digest : String
} derive(ToJson, FromJson)

///|
/// Immutable, content-addressed portable bundle manifest. Repeated construction
/// from the same normalized fields produces the same digest.
pub struct HandoverBundleV1 {
  bundle_id : String
  workspace : WorkspaceRefV1
  created_by : PrincipalRefV1
  entries : ReadOnlyArray[HandoverBundleEntryV1]
  excluded_secret_refs : ReadOnlyArray[String]
  created_at : String
  content_digest : DigestRefV1
} derive(Debug, Eq)

///|
fn handover_bundle_payload_wire_v1(
  bundle_id : String,
  workspace : WorkspaceRefV1,
  created_by : PrincipalRefV1,
  entries : Array[HandoverBundleEntryV1],
  excluded_secret_refs : Array[String],
  created_at : String,
) -> HandoverBundlePayloadWireV1 {
  {
    contract_id: "moonsuite.handover-bundle.v1",
    bundle_id,
    workspace_ref: encode_workspace_ref_v1(workspace),
    created_by: encode_principal_ref_v1(created_by),
    entries: entries.map(entry => handover_bundle_entry_wire_v1(entry)),
    excluded_secret_refs,
    created_at,
  }
}

///|
fn validate_handover_bundle_inputs_v1(
  bundle_id : String,
  entries : Array[HandoverBundleEntryV1],
  excluded_secret_refs : Array[String],
  created_at : String,
) -> Unit raise CapabilityContractError {
  if !identifier_component_is_canonical(bundle_id) ||
    !wire_timestamp_is_canonical(created_at) ||
    entries.is_empty() {
    raise InvalidReference(
      "handover bundle identity, timestamp, and entries are required",
    )
  }
  let artifact_refs : Array[String] = []
  for entry in entries {
    let artifact_ref = entry.artifact.evidence_ref()
    if artifact_refs.contains(artifact_ref) {
      raise InvalidReference("duplicate handover artifact: \{artifact_ref}")
    }
    artifact_refs.push(artifact_ref)
    if entry.classification == Secret {
      raise InvalidReference("secret artifacts cannot enter a handover bundle")
    }
  }
  if has_duplicate(excluded_secret_refs) ||
    excluded_secret_refs.any(value => value.trim().is_empty()) {
    raise InvalidReference(
      "excluded secret references must be unique non-empty labels",
    )
  }
}

///|
pub fn handover_bundle_v1(
  bundle_id : String,
  workspace : WorkspaceRefV1,
  created_by : PrincipalRefV1,
  entries : Array[HandoverBundleEntryV1],
  excluded_secret_refs? : Array[String] = [],
  created_at~ : String,
) -> HandoverBundleV1 raise CapabilityContractError {
  validate_handover_bundle_inputs_v1(
    bundle_id, entries, excluded_secret_refs, created_at,
  )
  let payload = handover_bundle_payload_wire_v1(
    bundle_id, workspace, created_by, entries, excluded_secret_refs, created_at,
  )
  let content_digest = sha256_digest_ref_v1(
    @utf8.encode(payload.to_json().stringify()),
  )
  {
    bundle_id,
    workspace,
    created_by,
    entries: ReadOnlyArray::from_array(entries),
    excluded_secret_refs: ReadOnlyArray::from_array(excluded_secret_refs),
    created_at,
    content_digest,
  }
}

///|
pub fn HandoverBundleV1::bundle_id(self : HandoverBundleV1) -> String {
  self.bundle_id
}

///|
pub fn HandoverBundleV1::workspace(self : HandoverBundleV1) -> WorkspaceRefV1 {
  self.workspace
}

///|
pub fn HandoverBundleV1::created_by(self : HandoverBundleV1) -> PrincipalRefV1 {
  self.created_by
}

///|
pub fn HandoverBundleV1::entries(
  self : HandoverBundleV1,
) -> ReadOnlyArray[HandoverBundleEntryV1] {
  self.entries
}

///|
pub fn HandoverBundleV1::excluded_secret_refs(
  self : HandoverBundleV1,
) -> ReadOnlyArray[String] {
  self.excluded_secret_refs
}

///|
pub fn HandoverBundleV1::content_digest(self : HandoverBundleV1) -> DigestRefV1 {
  self.content_digest
}

///|
pub fn HandoverBundleV1::requires_quarantine(self : HandoverBundleV1) -> Bool {
  self.entries.any(entry => entry.untrusted_document || entry.executable_content)
}

///|
pub fn encode_handover_bundle_v1(bundle : HandoverBundleV1) -> Json {
  HandoverBundleWireV1::{
    contract_id: "moonsuite.handover-bundle.v1",
    bundle_id: bundle.bundle_id,
    workspace_ref: encode_workspace_ref_v1(bundle.workspace),
    created_by: encode_principal_ref_v1(bundle.created_by),
    entries: bundle.entries
    .iter()
    .to_array()
    .map(entry => handover_bundle_entry_wire_v1(entry)),
    excluded_secret_refs: bundle.excluded_secret_refs.iter().to_array(),
    created_at: bundle.created_at,
    content_digest: bundle.content_digest.text(),
  }.to_json()
}

///|
pub fn decode_handover_bundle_v1(
  value : Json,
) -> HandoverBundleV1 raise CapabilityContractError {
  let wire : HandoverBundleWireV1 = decode_wire(
    value, "moonsuite.handover-bundle.v1",
  )
  if wire.contract_id != "moonsuite.handover-bundle.v1" {
    raise InvalidReference("unsupported handover bundle contract")
  }
  let bundle = handover_bundle_v1(
    wire.bundle_id,
    decode_workspace_ref_v1(wire.workspace_ref),
    decode_principal_ref_v1(wire.created_by),
    wire.entries.map(entry => decode_handover_bundle_entry_v1(entry.to_json())),
    excluded_secret_refs=wire.excluded_secret_refs,
    created_at=wire.created_at,
  )
  if bundle.content_digest.text() != wire.content_digest {
    raise InvalidReference("handover bundle content digest mismatch")
  }
  bundle
}

///|
pub(all) enum QuarantineStatusV1 {
  NotRequired
  Pending
  Cleared
  Rejected
} derive(Debug, Eq)

///|
pub fn QuarantineStatusV1::id(self : QuarantineStatusV1) -> String {
  match self {
    NotRequired => "not-required"
    Pending => "pending"
    Cleared => "cleared"
    Rejected => "rejected"
  }
}

///|
fn quarantine_status_v1_from_id(
  value : String,
) -> QuarantineStatusV1 raise CapabilityContractError {
  match value {
    "not-required" => NotRequired
    "pending" => Pending
    "cleared" => Cleared
    "rejected" => Rejected
    _ => raise InvalidReference("unsupported quarantine status: \{value}")
  }
}

///|
pub struct QuarantineMetadataV1 {
  status : QuarantineStatusV1
  evidence_refs : ReadOnlyArray[ContentAddressedEvidenceRefV1]
  reason : String
} derive(Debug, Eq)

///|
pub fn quarantine_metadata_v1(
  status : QuarantineStatusV1,
  evidence_refs? : Array[ContentAddressedEvidenceRefV1] = [],
  reason? : String = "",
) -> QuarantineMetadataV1 raise CapabilityContractError {
  if status == Cleared && evidence_refs.is_empty() {
    raise InvalidReference("cleared quarantine requires evidence")
  }
  if status == Rejected && reason.trim().is_empty() {
    raise InvalidReference("rejected quarantine requires a reason")
  }
  { status, evidence_refs: ReadOnlyArray::from_array(evidence_refs), reason }
}

///|
pub fn QuarantineMetadataV1::status(
  self : QuarantineMetadataV1,
) -> QuarantineStatusV1 {
  self.status
}

///|
pub fn QuarantineMetadataV1::evidence_refs(
  self : QuarantineMetadataV1,
) -> ReadOnlyArray[ContentAddressedEvidenceRefV1] {
  self.evidence_refs
}

///|
priv struct QuarantineMetadataWireV1 {
  status : String
  evidence_refs : Array[Json]
  reason : String
} derive(ToJson, FromJson)

///|
pub fn encode_quarantine_metadata_v1(metadata : QuarantineMetadataV1) -> Json {
  QuarantineMetadataWireV1::{
    status: metadata.status.id(),
    evidence_refs: metadata.evidence_refs
    .iter()
    .to_array()
    .map(reference => {
      "evidence_ref": reference.evidence_ref(),
      "evidence_digest": reference.evidence_digest(),
    }),
    reason: metadata.reason,
  }.to_json()
}

///|
pub fn decode_quarantine_metadata_v1(
  value : Json,
) -> QuarantineMetadataV1 raise CapabilityContractError {
  let wire : QuarantineMetadataWireV1 = decode_wire(
    value, "moonsuite.quarantine-metadata.v1",
  )
  let evidence : Array[ContentAddressedEvidenceRefV1] = []
  for item in wire.evidence_refs {
    guard item
      is {
        "evidence_ref": String(reference),
        "evidence_digest": String(digest),
        ..
      } else {
      raise InvalidReference("invalid quarantine evidence reference")
    }
    evidence.push(content_addressed_evidence_ref(reference, digest))
  }
  quarantine_metadata_v1(
    quarantine_status_v1_from_id(wire.status),
    evidence_refs=evidence,
    reason=wire.reason,
  )
}

///|
/// Bounded ceilings travel with continuation context. Missing dimensions are
/// unsupported rather than unlimited; at least one explicit ceiling is needed.
pub struct HandoverBudgetCeilingsV1 {
  max_cost_micro_usd : Int64?
  max_runtime_ms : Int64?
  max_tokens : Int64?
  max_artifacts : Int?
} derive(Debug, Eq)

///|
pub fn handover_budget_ceilings_v1(
  max_cost_micro_usd? : Int64,
  max_runtime_ms? : Int64,
  max_tokens? : Int64,
  max_artifacts? : Int,
) -> HandoverBudgetCeilingsV1 raise CapabilityContractError {
  if max_cost_micro_usd is None &&
    max_runtime_ms is None &&
    max_tokens is None &&
    max_artifacts is None {
    raise InvalidReference("handover budget must declare at least one ceiling")
  }
  if (max_cost_micro_usd is Some(value) && value <= 0L) ||
    (max_runtime_ms is Some(value) && value <= 0L) ||
    (max_tokens is Some(value) && value <= 0L) ||
    (max_artifacts is Some(value) && value <= 0) {
    raise InvalidReference("handover budget ceilings must be positive")
  }
  { max_cost_micro_usd, max_runtime_ms, max_tokens, max_artifacts }
}

///|
pub fn HandoverBudgetCeilingsV1::max_cost_micro_usd(
  self : HandoverBudgetCeilingsV1,
) -> Int64? {
  self.max_cost_micro_usd
}

///|
pub fn HandoverBudgetCeilingsV1::max_runtime_ms(
  self : HandoverBudgetCeilingsV1,
) -> Int64? {
  self.max_runtime_ms
}

///|
pub fn HandoverBudgetCeilingsV1::max_tokens(
  self : HandoverBudgetCeilingsV1,
) -> Int64? {
  self.max_tokens
}

///|
pub fn HandoverBudgetCeilingsV1::max_artifacts(
  self : HandoverBudgetCeilingsV1,
) -> Int? {
  self.max_artifacts
}

///|
priv struct HandoverBudgetCeilingsWireV1 {
  max_cost_micro_usd : Int64?
  max_runtime_ms : Int64?
  max_tokens : Int64?
  max_artifacts : Int?
} derive(ToJson, FromJson)

///|
fn encode_handover_budget_ceilings_v1(
  ceilings : HandoverBudgetCeilingsV1,
) -> Json {
  HandoverBudgetCeilingsWireV1::{
    max_cost_micro_usd: ceilings.max_cost_micro_usd,
    max_runtime_ms: ceilings.max_runtime_ms,
    max_tokens: ceilings.max_tokens,
    max_artifacts: ceilings.max_artifacts,
  }.to_json()
}

///|
fn decode_handover_budget_ceilings_v1(
  value : Json,
) -> HandoverBudgetCeilingsV1 raise CapabilityContractError {
  let wire : HandoverBudgetCeilingsWireV1 = decode_wire(
    value, "moonsuite.handover-budget-ceilings.v1",
  )
  handover_budget_ceilings_v1(
    max_cost_micro_usd?=wire.max_cost_micro_usd,
    max_runtime_ms?=wire.max_runtime_ms,
    max_tokens?=wire.max_tokens,
    max_artifacts?=wire.max_artifacts,
  )
}

///|
/// Reference to the prior immutable envelope in a continuation chain.
pub struct PreviousHandoverRefV1 {
  handover_id : String
  envelope_digest : DigestRefV1
} derive(Debug, Eq)

///|
pub fn previous_handover_ref_v1(
  handover_id : String,
  envelope_digest : String,
) -> PreviousHandoverRefV1 raise CapabilityContractError {
  if !identifier_component_is_canonical(handover_id) {
    raise InvalidReference("previous handover id is not canonical")
  }
  { handover_id, envelope_digest: digest_ref_v1(envelope_digest) }
}

///|
pub fn PreviousHandoverRefV1::handover_id(
  self : PreviousHandoverRefV1,
) -> String {
  self.handover_id
}

///|
pub fn PreviousHandoverRefV1::envelope_digest(
  self : PreviousHandoverRefV1,
) -> DigestRefV1 {
  self.envelope_digest
}

///|
priv struct PreviousHandoverWireV1 {
  handover_id : String
  envelope_digest : String
} derive(ToJson, FromJson)

///|
fn encode_previous_handover_ref_v1(reference : PreviousHandoverRefV1) -> Json {
  PreviousHandoverWireV1::{
    handover_id: reference.handover_id,
    envelope_digest: reference.envelope_digest.text(),
  }.to_json()
}

///|
fn decode_previous_handover_ref_v1(
  value : Json,
) -> PreviousHandoverRefV1 raise CapabilityContractError {
  let wire : PreviousHandoverWireV1 = decode_wire(
    value, "moonsuite.previous-handover-ref.v1",
  )
  previous_handover_ref_v1(wire.handover_id, wire.envelope_digest)
}

///|
/// Explicit restart context. It is data, never an authority grant. Consumers
/// must use the named checkpoint and may not infer a broader continuation.
pub struct HandoverContinuationContextV1 {
  purpose : String
  run_ref : String
  work_ref : String
  stage_ref : String?
  attempt_ref : String?
  checkpoint : ContentAddressedEvidenceRefV1?
  budget_ceilings : HandoverBudgetCeilingsV1?
  compatibility_requirements : ReadOnlyArray[ContractRefV1]
  previous_handover : PreviousHandoverRefV1?
} derive(Debug, Eq)

///|
pub fn handover_continuation_context_v1(
  purpose : String,
  run_ref : String,
  work_ref : String,
  compatibility_requirements : Array[ContractRefV1],
  stage_ref? : String,
  attempt_ref? : String,
  checkpoint? : ContentAddressedEvidenceRefV1,
  budget_ceilings? : HandoverBudgetCeilingsV1,
  previous_handover? : PreviousHandoverRefV1,
) -> HandoverContinuationContextV1 raise CapabilityContractError {
  if purpose.trim().is_empty() ||
    purpose.length() > 1024 ||
    !portable_correlation_token(run_ref) ||
    !portable_correlation_token(work_ref) ||
    (stage_ref is Some(value) && !portable_correlation_token(value)) ||
    (attempt_ref is Some(value) && !portable_correlation_token(value)) {
    raise InvalidReference("handover continuation context is not canonical")
  }
  let contracts : Array[String] = []
  for requirement in compatibility_requirements {
    let formatted = requirement.format()
    if contracts.contains(formatted) {
      raise InvalidReference(
        "duplicate compatibility requirement: \{formatted}",
      )
    }
    contracts.push(formatted)
  }
  {
    purpose,
    run_ref,
    work_ref,
    stage_ref,
    attempt_ref,
    checkpoint,
    budget_ceilings,
    compatibility_requirements: ReadOnlyArray::from_array(
      compatibility_requirements,
    ),
    previous_handover,
  }
}

///|
pub fn HandoverContinuationContextV1::purpose(
  self : HandoverContinuationContextV1,
) -> String {
  self.purpose
}

///|
pub fn HandoverContinuationContextV1::run_ref(
  self : HandoverContinuationContextV1,
) -> String {
  self.run_ref
}

///|
pub fn HandoverContinuationContextV1::work_ref(
  self : HandoverContinuationContextV1,
) -> String {
  self.work_ref
}

///|
pub fn HandoverContinuationContextV1::stage_ref(
  self : HandoverContinuationContextV1,
) -> String? {
  self.stage_ref
}

///|
pub fn HandoverContinuationContextV1::attempt_ref(
  self : HandoverContinuationContextV1,
) -> String? {
  self.attempt_ref
}

///|
pub fn HandoverContinuationContextV1::checkpoint(
  self : HandoverContinuationContextV1,
) -> ContentAddressedEvidenceRefV1? {
  self.checkpoint
}

///|
pub fn HandoverContinuationContextV1::budget_ceilings(
  self : HandoverContinuationContextV1,
) -> HandoverBudgetCeilingsV1? {
  self.budget_ceilings
}

///|
pub fn HandoverContinuationContextV1::compatibility_requirements(
  self : HandoverContinuationContextV1,
) -> ReadOnlyArray[ContractRefV1] {
  self.compatibility_requirements
}

///|
pub fn HandoverContinuationContextV1::previous_handover(
  self : HandoverContinuationContextV1,
) -> PreviousHandoverRefV1? {
  self.previous_handover
}

///|
priv struct HandoverContinuationContextWireV1 {
  purpose : String
  run_ref : String
  work_ref : String
  stage_ref : String?
  attempt_ref : String?
  checkpoint_ref : String?
  checkpoint_digest : String?
  budget_ceilings : Json?
  compatibility_requirements : Array[Json]
  previous_handover : Json?
} derive(ToJson, FromJson)

///|
fn encode_handover_continuation_context_v1(
  context : HandoverContinuationContextV1,
) -> Json {
  HandoverContinuationContextWireV1::{
    purpose: context.purpose,
    run_ref: context.run_ref,
    work_ref: context.work_ref,
    stage_ref: context.stage_ref,
    attempt_ref: context.attempt_ref,
    checkpoint_ref: context.checkpoint.map(value => value.evidence_ref()),
    checkpoint_digest: context.checkpoint.map(value => value.evidence_digest()),
    budget_ceilings: context.budget_ceilings.map(value => {
      encode_handover_budget_ceilings_v1(value)
    }),
    compatibility_requirements: context.compatibility_requirements
    .iter()
    .to_array()
    .map(value => encode_contract_ref_v1(value)),
    previous_handover: context.previous_handover.map(value => {
      encode_previous_handover_ref_v1(value)
    }),
  }.to_json()
}

///|
fn decode_handover_continuation_context_v1(
  value : Json,
) -> HandoverContinuationContextV1 raise CapabilityContractError {
  let wire : HandoverContinuationContextWireV1 = decode_wire(
    value, "moonsuite.handover-continuation-context.v1",
  )
  if (wire.checkpoint_ref is Some(_)) != (wire.checkpoint_digest is Some(_)) {
    raise InvalidReference(
      "checkpoint reference and digest must appear together",
    )
  }
  let checkpoint = match (wire.checkpoint_ref, wire.checkpoint_digest) {
    (Some(reference), Some(digest)) =>
      Some(content_addressed_evidence_ref(reference, digest))
    _ => None
  }
  handover_continuation_context_v1(
    wire.purpose,
    wire.run_ref,
    wire.work_ref,
    wire.compatibility_requirements.map(value => decode_contract_ref_v1(value)),
    stage_ref?=wire.stage_ref,
    attempt_ref?=wire.attempt_ref,
    checkpoint?,
    budget_ceilings?=wire.budget_ceilings.map(value => {
      decode_handover_budget_ceilings_v1(value)
    }),
    previous_handover?=wire.previous_handover.map(value => {
      decode_previous_handover_ref_v1(value)
    }),
  )
}

///|
/// Detached signature metadata. Cryptographic verification remains a host
/// responsibility; the metadata and signature artifact are digest-bound here.
pub struct HandoverSignatureMetadataV1 {
  signer : PrincipalRefV1
  algorithm : String
  key_id : String
  signed_bundle_digest : DigestRefV1
  signature : ContentAddressedEvidenceRefV1
  signed_at : String
} derive(Debug, Eq)

///|
pub fn handover_signature_metadata_v1(
  signer : PrincipalRefV1,
  algorithm : String,
  key_id : String,
  signed_bundle_digest : String,
  signature_ref : String,
  signature_digest : String,
  signed_at : String,
) -> HandoverSignatureMetadataV1 raise CapabilityContractError {
  if !identifier_component_is_canonical(algorithm) ||
    !identifier_component_is_canonical(key_id) ||
    !wire_timestamp_is_canonical(signed_at) {
    raise InvalidReference("handover signature metadata is not canonical")
  }
  {
    signer,
    algorithm,
    key_id,
    signed_bundle_digest: digest_ref_v1(signed_bundle_digest),
    signature: content_addressed_evidence_ref(signature_ref, signature_digest),
    signed_at,
  }
}

///|
pub fn HandoverSignatureMetadataV1::signer(
  self : HandoverSignatureMetadataV1,
) -> PrincipalRefV1 {
  self.signer
}

///|
pub fn HandoverSignatureMetadataV1::signed_bundle_digest(
  self : HandoverSignatureMetadataV1,
) -> DigestRefV1 {
  self.signed_bundle_digest
}

///|
priv struct HandoverSignatureMetadataWireV1 {
  signer : Json
  algorithm : String
  key_id : String
  signed_subject : String
  signed_digest : String
  signature_ref : String
  signature_digest : String
  signed_at : String
} derive(ToJson, FromJson)

///|
fn encode_handover_signature_metadata_v1(
  metadata : HandoverSignatureMetadataV1,
) -> Json {
  HandoverSignatureMetadataWireV1::{
    signer: encode_principal_ref_v1(metadata.signer),
    algorithm: metadata.algorithm,
    key_id: metadata.key_id,
    signed_subject: "bundle-content-digest",
    signed_digest: metadata.signed_bundle_digest.text(),
    signature_ref: metadata.signature.evidence_ref(),
    signature_digest: metadata.signature.evidence_digest(),
    signed_at: metadata.signed_at,
  }.to_json()
}

///|
fn decode_handover_signature_metadata_v1(
  value : Json,
) -> HandoverSignatureMetadataV1 raise CapabilityContractError {
  let wire : HandoverSignatureMetadataWireV1 = decode_wire(
    value, "moonsuite.handover-signature-metadata.v1",
  )
  if wire.signed_subject != "bundle-content-digest" {
    raise InvalidReference(
      "handover signature subject must be the bundle digest",
    )
  }
  handover_signature_metadata_v1(
    decode_principal_ref_v1(wire.signer),
    wire.algorithm,
    wire.key_id,
    wire.signed_digest,
    wire.signature_ref,
    wire.signature_digest,
    wire.signed_at,
  )
}

///|
/// Immutable control envelope around a portable bundle. It requests authority
/// but deliberately contains no grant; import always requires a fresh decision
/// for the exact recipient.
pub struct HandoverControlEnvelopeV1 {
  handover_id : String
  bundle_digest : DigestRefV1
  source_principal : PrincipalRefV1
  recipient_principal : PrincipalRefV1
  workspace : WorkspaceRefV1
  correlation : CorrelationRefV1
  source_product_id : String
  target_product_id : String
  source_operation : OperationRef
  target_operation : OperationRef
  source_output_schemas : ReadOnlyArray[SchemaRef]
  target_input_schemas : ReadOnlyArray[SchemaRef]
  target_output_schemas : ReadOnlyArray[SchemaRef]
  continuation : HandoverContinuationContextV1
  open_items : ReadOnlyArray[String]
  blockers : ReadOnlyArray[String]
  acceptance_criteria : ReadOnlyArray[String]
  requested_authority : String
  review_required : Bool
  return_destination : String
  quarantine : QuarantineMetadataV1
  signature_metadata : HandoverSignatureMetadataV1?
  created_at : String
  expires_at : String
  envelope_digest : DigestRefV1
} derive(Debug, Eq)

///|
priv struct HandoverControlPayloadWireV1 {
  contract_id : String
  handover_id : String
  bundle_digest : String
  source_principal : Json
  recipient_principal : Json
  workspace_ref : Json
  correlation_ref : Json
  source_product_id : String
  target_product_id : String
  source_operation_ref : Json
  target_operation_ref : Json
  source_output_schema_refs : Array[Json]
  target_input_schema_refs : Array[Json]
  target_output_schema_refs : Array[Json]
  continuation_context : Json
  open_items : Array[String]
  blockers : Array[String]
  acceptance_criteria : Array[String]
  requested_authority : String
  fresh_authority_required : Bool
  review_required : Bool
  return_destination : String
  quarantine : Json
  signature_metadata : Json?
  created_at : String
  expires_at : String
} derive(ToJson)

///|
priv struct HandoverControlWireV1 {
  contract_id : String
  handover_id : String
  bundle_digest : String
  source_principal : Json
  recipient_principal : Json
  workspace_ref : Json
  correlation_ref : Json
  source_product_id : String
  target_product_id : String
  source_operation_ref : Json
  target_operation_ref : Json
  source_output_schema_refs : Array[Json]
  target_input_schema_refs : Array[Json]
  target_output_schema_refs : Array[Json]
  continuation_context : Json
  open_items : Array[String]
  blockers : Array[String]
  acceptance_criteria : Array[String]
  requested_authority : String
  fresh_authority_required : Bool
  review_required : Bool
  return_destination : String
  quarantine : Json
  signature_metadata : Json?
  created_at : String
  expires_at : String
  envelope_digest : String
} derive(ToJson, FromJson)

///|
fn handover_control_payload_wire_v1(
  handover_id : String,
  bundle_digest : DigestRefV1,
  source_principal : PrincipalRefV1,
  recipient_principal : PrincipalRefV1,
  workspace : WorkspaceRefV1,
  correlation : CorrelationRefV1,
  source_product_id : String,
  target_product_id : String,
  source_operation : OperationRef,
  target_operation : OperationRef,
  source_output_schemas : Array[SchemaRef],
  target_input_schemas : Array[SchemaRef],
  target_output_schemas : Array[SchemaRef],
  continuation : HandoverContinuationContextV1,
  open_items : Array[String],
  blockers : Array[String],
  acceptance_criteria : Array[String],
  requested_authority : String,
  review_required : Bool,
  return_destination : String,
  quarantine : QuarantineMetadataV1,
  signature_metadata : HandoverSignatureMetadataV1?,
  created_at : String,
  expires_at : String,
) -> HandoverControlPayloadWireV1 {
  {
    contract_id: "moonsuite.handover-control.v1",
    handover_id,
    bundle_digest: bundle_digest.text(),
    source_principal: encode_principal_ref_v1(source_principal),
    recipient_principal: encode_principal_ref_v1(recipient_principal),
    workspace_ref: encode_workspace_ref_v1(workspace),
    correlation_ref: encode_correlation_ref_v1(correlation),
    source_product_id,
    target_product_id,
    source_operation_ref: encode_operation_ref_v1(source_operation),
    target_operation_ref: encode_operation_ref_v1(target_operation),
    source_output_schema_refs: source_output_schemas.map(schema => {
      encode_schema_ref_v1(schema)
    }),
    target_input_schema_refs: target_input_schemas.map(schema => {
      encode_schema_ref_v1(schema)
    }),
    target_output_schema_refs: target_output_schemas.map(schema => {
      encode_schema_ref_v1(schema)
    }),
    continuation_context: encode_handover_continuation_context_v1(continuation),
    open_items,
    blockers,
    acceptance_criteria,
    requested_authority,
    fresh_authority_required: true,
    review_required,
    return_destination,
    quarantine: encode_quarantine_metadata_v1(quarantine),
    signature_metadata: signature_metadata.map(value => {
      encode_handover_signature_metadata_v1(value)
    }),
    created_at,
    expires_at,
  }
}

///|
fn handover_string_list_is_canonical_v1(values : Array[String]) -> Bool {
  let seen : Array[String] = []
  for value in values {
    if value.trim().is_empty() || value.length() > 2048 || seen.contains(value) {
      return false
    }
    seen.push(value)
  }
  true
}

///|
fn handover_schema_list_is_canonical_v1(
  schemas : Array[SchemaRef],
  product_id : String,
) -> Bool {
  if schemas.is_empty() {
    return false
  }
  let seen : Array[String] = []
  for schema in schemas {
    let formatted = schema.format()
    if schema.product_id() != product_id || seen.contains(formatted) {
      return false
    }
    seen.push(formatted)
  }
  true
}

///|
pub fn handover_control_envelope_v1(
  handover_id : String,
  bundle : HandoverBundleV1,
  source_principal : PrincipalRefV1,
  recipient_principal : PrincipalRefV1,
  correlation : CorrelationRefV1,
  source_operation~ : OperationRef,
  target_operation~ : OperationRef,
  source_output_schemas~ : Array[SchemaRef],
  target_input_schemas~ : Array[SchemaRef],
  target_output_schemas~ : Array[SchemaRef],
  continuation~ : HandoverContinuationContextV1,
  open_items? : Array[String] = [],
  blockers? : Array[String] = [],
  acceptance_criteria~ : Array[String],
  requested_authority~ : String,
  review_required? : Bool = true,
  return_destination~ : String,
  quarantine~ : QuarantineMetadataV1,
  signature_metadata? : HandoverSignatureMetadataV1,
  created_at~ : String,
  expires_at~ : String,
) -> HandoverControlEnvelopeV1 raise CapabilityContractError {
  if !identifier_component_is_canonical(handover_id) ||
    source_principal != bundle.created_by ||
    source_principal == recipient_principal ||
    !handover_schema_list_is_canonical_v1(
      source_output_schemas,
      source_operation.product_id(),
    ) ||
    !handover_schema_list_is_canonical_v1(
      target_input_schemas,
      target_operation.product_id(),
    ) ||
    !handover_schema_list_is_canonical_v1(
      target_output_schemas,
      target_operation.product_id(),
    ) ||
    continuation.run_ref != correlation.run_id() ||
    continuation.work_ref != correlation.work_item_id() ||
    continuation.attempt_ref != correlation.attempt_id() ||
    !handover_string_list_is_canonical_v1(open_items) ||
    !handover_string_list_is_canonical_v1(blockers) ||
    acceptance_criteria.is_empty() ||
    !handover_string_list_is_canonical_v1(acceptance_criteria) ||
    !identifier_component_is_canonical(requested_authority) ||
    !evidence_artifact_ref_is_canonical(return_destination) ||
    !wire_timestamp_is_canonical(created_at) ||
    !wire_timestamp_is_canonical(expires_at) ||
    created_at >= expires_at {
    raise InvalidReference("handover control envelope is not canonical")
  }
  if bundle.requires_quarantine() && quarantine.status == NotRequired {
    raise InvalidReference(
      "untrusted or executable content requires quarantine",
    )
  }
  if continuation.checkpoint is Some(checkpoint) &&
    !bundle.entries.any(entry => entry.artifact == checkpoint) {
    raise InvalidReference(
      "continuation checkpoint must be present in the bundle",
    )
  }
  if continuation.previous_handover is Some(previous) &&
    previous.handover_id == handover_id {
    raise InvalidReference("handover cannot cite itself as its predecessor")
  }
  if signature_metadata is Some(signature) &&
    (
      signature.signer != source_principal ||
      signature.signed_at > created_at ||
      signature.signed_bundle_digest != bundle.content_digest
    ) {
    raise InvalidReference(
      "handover signature must bind the source and exact bundle before creation",
    )
  }
  let source_product_id = source_operation.product_id()
  let target_product_id = target_operation.product_id()
  let payload = handover_control_payload_wire_v1(
    handover_id,
    bundle.content_digest,
    source_principal,
    recipient_principal,
    bundle.workspace,
    correlation,
    source_product_id,
    target_product_id,
    source_operation,
    target_operation,
    source_output_schemas,
    target_input_schemas,
    target_output_schemas,
    continuation,
    open_items,
    blockers,
    acceptance_criteria,
    requested_authority,
    review_required,
    return_destination,
    quarantine,
    signature_metadata,
    created_at,
    expires_at,
  )
  let envelope_digest = sha256_digest_ref_v1(
    @utf8.encode(payload.to_json().stringify()),
  )
  {
    handover_id,
    bundle_digest: bundle.content_digest,
    source_principal,
    recipient_principal,
    workspace: bundle.workspace,
    correlation,
    source_product_id,
    target_product_id,
    source_operation,
    target_operation,
    source_output_schemas: ReadOnlyArray::from_array(source_output_schemas),
    target_input_schemas: ReadOnlyArray::from_array(target_input_schemas),
    target_output_schemas: ReadOnlyArray::from_array(target_output_schemas),
    continuation,
    open_items: ReadOnlyArray::from_array(open_items),
    blockers: ReadOnlyArray::from_array(blockers),
    acceptance_criteria: ReadOnlyArray::from_array(acceptance_criteria),
    requested_authority,
    review_required,
    return_destination,
    quarantine,
    signature_metadata,
    created_at,
    expires_at,
    envelope_digest,
  }
}

///|
pub fn HandoverControlEnvelopeV1::handover_id(
  self : HandoverControlEnvelopeV1,
) -> String {
  self.handover_id
}

///|
pub fn HandoverControlEnvelopeV1::bundle_digest(
  self : HandoverControlEnvelopeV1,
) -> DigestRefV1 {
  self.bundle_digest
}

///|
pub fn HandoverControlEnvelopeV1::source_principal(
  self : HandoverControlEnvelopeV1,
) -> PrincipalRefV1 {
  self.source_principal
}

///|
pub fn HandoverControlEnvelopeV1::recipient_principal(
  self : HandoverControlEnvelopeV1,
) -> PrincipalRefV1 {
  self.recipient_principal
}

///|
pub fn HandoverControlEnvelopeV1::workspace(
  self : HandoverControlEnvelopeV1,
) -> WorkspaceRefV1 {
  self.workspace
}

///|
pub fn HandoverControlEnvelopeV1::correlation(
  self : HandoverControlEnvelopeV1,
) -> CorrelationRefV1 {
  self.correlation
}

///|
pub fn HandoverControlEnvelopeV1::source_product_id(
  self : HandoverControlEnvelopeV1,
) -> String {
  self.source_product_id
}

///|
pub fn HandoverControlEnvelopeV1::target_product_id(
  self : HandoverControlEnvelopeV1,
) -> String {
  self.target_product_id
}

///|
pub fn HandoverControlEnvelopeV1::source_operation(
  self : HandoverControlEnvelopeV1,
) -> OperationRef {
  self.source_operation
}

///|
pub fn HandoverControlEnvelopeV1::target_operation(
  self : HandoverControlEnvelopeV1,
) -> OperationRef {
  self.target_operation
}

///|
/// Compatibility alias for callers that previously treated the only operation
/// as the target continuation operation.
pub fn HandoverControlEnvelopeV1::operation(
  self : HandoverControlEnvelopeV1,
) -> OperationRef {
  self.target_operation
}

///|
pub fn HandoverControlEnvelopeV1::source_output_schemas(
  self : HandoverControlEnvelopeV1,
) -> ReadOnlyArray[SchemaRef] {
  self.source_output_schemas
}

///|
pub fn HandoverControlEnvelopeV1::target_input_schemas(
  self : HandoverControlEnvelopeV1,
) -> ReadOnlyArray[SchemaRef] {
  self.target_input_schemas
}

///|
pub fn HandoverControlEnvelopeV1::target_output_schemas(
  self : HandoverControlEnvelopeV1,
) -> ReadOnlyArray[SchemaRef] {
  self.target_output_schemas
}

///|
pub fn HandoverControlEnvelopeV1::continuation(
  self : HandoverControlEnvelopeV1,
) -> HandoverContinuationContextV1 {
  self.continuation
}

///|
pub fn HandoverControlEnvelopeV1::open_items(
  self : HandoverControlEnvelopeV1,
) -> ReadOnlyArray[String] {
  self.open_items
}

///|
pub fn HandoverControlEnvelopeV1::blockers(
  self : HandoverControlEnvelopeV1,
) -> ReadOnlyArray[String] {
  self.blockers
}

///|
pub fn HandoverControlEnvelopeV1::acceptance_criteria(
  self : HandoverControlEnvelopeV1,
) -> ReadOnlyArray[String] {
  self.acceptance_criteria
}

///|
pub fn HandoverControlEnvelopeV1::requested_authority(
  self : HandoverControlEnvelopeV1,
) -> String {
  self.requested_authority
}

///|
pub fn HandoverControlEnvelopeV1::quarantine(
  self : HandoverControlEnvelopeV1,
) -> QuarantineMetadataV1 {
  self.quarantine
}

///|
pub fn HandoverControlEnvelopeV1::review_required(
  self : HandoverControlEnvelopeV1,
) -> Bool {
  self.review_required
}

///|
pub fn HandoverControlEnvelopeV1::return_destination(
  self : HandoverControlEnvelopeV1,
) -> String {
  self.return_destination
}

///|
pub fn HandoverControlEnvelopeV1::signature_metadata(
  self : HandoverControlEnvelopeV1,
) -> HandoverSignatureMetadataV1? {
  self.signature_metadata
}

///|
pub fn HandoverControlEnvelopeV1::created_at(
  self : HandoverControlEnvelopeV1,
) -> String {
  self.created_at
}

///|
pub fn HandoverControlEnvelopeV1::expires_at(
  self : HandoverControlEnvelopeV1,
) -> String {
  self.expires_at
}

///|
pub fn HandoverControlEnvelopeV1::envelope_digest(
  self : HandoverControlEnvelopeV1,
) -> DigestRefV1 {
  self.envelope_digest
}

///|
pub fn encode_handover_control_envelope_v1(
  envelope : HandoverControlEnvelopeV1,
) -> Json {
  let payload = handover_control_payload_wire_v1(
    envelope.handover_id,
    envelope.bundle_digest,
    envelope.source_principal,
    envelope.recipient_principal,
    envelope.workspace,
    envelope.correlation,
    envelope.source_product_id,
    envelope.target_product_id,
    envelope.source_operation,
    envelope.target_operation,
    envelope.source_output_schemas.iter().to_array(),
    envelope.target_input_schemas.iter().to_array(),
    envelope.target_output_schemas.iter().to_array(),
    envelope.continuation,
    envelope.open_items.iter().to_array(),
    envelope.blockers.iter().to_array(),
    envelope.acceptance_criteria.iter().to_array(),
    envelope.requested_authority,
    envelope.review_required,
    envelope.return_destination,
    envelope.quarantine,
    envelope.signature_metadata,
    envelope.created_at,
    envelope.expires_at,
  )
  HandoverControlWireV1::{
    contract_id: payload.contract_id,
    handover_id: payload.handover_id,
    bundle_digest: payload.bundle_digest,
    source_principal: payload.source_principal,
    recipient_principal: payload.recipient_principal,
    workspace_ref: payload.workspace_ref,
    correlation_ref: payload.correlation_ref,
    source_product_id: payload.source_product_id,
    target_product_id: payload.target_product_id,
    source_operation_ref: payload.source_operation_ref,
    target_operation_ref: payload.target_operation_ref,
    source_output_schema_refs: payload.source_output_schema_refs,
    target_input_schema_refs: payload.target_input_schema_refs,
    target_output_schema_refs: payload.target_output_schema_refs,
    continuation_context: payload.continuation_context,
    open_items: payload.open_items,
    blockers: payload.blockers,
    acceptance_criteria: payload.acceptance_criteria,
    requested_authority: payload.requested_authority,
    fresh_authority_required: true,
    review_required: payload.review_required,
    return_destination: payload.return_destination,
    quarantine: payload.quarantine,
    signature_metadata: payload.signature_metadata,
    created_at: payload.created_at,
    expires_at: payload.expires_at,
    envelope_digest: envelope.envelope_digest.text(),
  }.to_json()
}

///|
pub fn decode_handover_control_envelope_v1(
  value : Json,
  bundle : HandoverBundleV1,
) -> HandoverControlEnvelopeV1 raise CapabilityContractError {
  let wire : HandoverControlWireV1 = decode_wire(
    value, "moonsuite.handover-control.v1",
  )
  if wire.contract_id != "moonsuite.handover-control.v1" ||
    !wire.fresh_authority_required {
    raise InvalidReference("unsupported or unsafe handover control contract")
  }
  let envelope = handover_control_envelope_v1(
    wire.handover_id,
    bundle,
    decode_principal_ref_v1(wire.source_principal),
    decode_principal_ref_v1(wire.recipient_principal),
    decode_correlation_ref_v1(wire.correlation_ref),
    source_operation=decode_operation_ref_v1(wire.source_operation_ref),
    target_operation=decode_operation_ref_v1(wire.target_operation_ref),
    source_output_schemas=wire.source_output_schema_refs.map(value => {
      decode_schema_ref_v1(value)
    }),
    target_input_schemas=wire.target_input_schema_refs.map(value => {
      decode_schema_ref_v1(value)
    }),
    target_output_schemas=wire.target_output_schema_refs.map(value => {
      decode_schema_ref_v1(value)
    }),
    continuation=decode_handover_continuation_context_v1(
      wire.continuation_context,
    ),
    open_items=wire.open_items,
    blockers=wire.blockers,
    acceptance_criteria=wire.acceptance_criteria,
    requested_authority=wire.requested_authority,
    review_required=wire.review_required,
    return_destination=wire.return_destination,
    quarantine=decode_quarantine_metadata_v1(wire.quarantine),
    signature_metadata?=wire.signature_metadata.map(value => {
      decode_handover_signature_metadata_v1(value)
    }),
    created_at=wire.created_at,
    expires_at=wire.expires_at,
  )
  if wire.bundle_digest != bundle.content_digest.text() ||
    wire.workspace_ref != encode_workspace_ref_v1(bundle.workspace) ||
    wire.source_product_id != envelope.source_product_id ||
    wire.target_product_id != envelope.target_product_id ||
    wire.envelope_digest != envelope.envelope_digest.text() {
    raise InvalidReference("handover control identity or digest mismatch")
  }
  envelope
}
