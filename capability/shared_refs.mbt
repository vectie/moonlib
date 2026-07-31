///|
/// The kind of principal that performed or received a governed action.
/// Authentication and authorization remain host responsibilities; this enum
/// only prevents humans, agents, and services from being conflated on wire.
pub(all) enum PrincipalKindV1 {
  Human
  Agent
  Service
} derive(Debug, Eq)

///|
pub fn PrincipalKindV1::id(self : PrincipalKindV1) -> String {
  match self {
    Human => "human"
    Agent => "agent"
    Service => "service"
  }
}

///|
fn principal_kind_v1_from_id(value : String) -> PrincipalKindV1 raise CapabilityContractError {
  match value {
    "human" => Human
    "agent" => Agent
    "service" => Service
    _ => raise InvalidReference("unsupported principal kind: \{value}")
  }
}

///|
/// A validated identity for a human, agent, or service. The issuer/subject pair
/// is retained separately from the suite-local id so a UI label can never be
/// mistaken for authenticated identity.
pub struct PrincipalRefV1 {
  principal_id : String
  kind : PrincipalKindV1
  issuer : String
  subject : String
} derive(Debug, Eq)

///|
pub fn principal_ref_v1(
  principal_id : String,
  kind : PrincipalKindV1,
  issuer : String,
  subject : String,
) -> PrincipalRefV1 raise CapabilityContractError {
  if !identifier_component_is_canonical(principal_id) ||
    !identifier_component_is_canonical(issuer) ||
    !identifier_component_is_canonical(subject) {
    raise InvalidReference("principal reference is not canonical")
  }
  { principal_id, kind, issuer, subject }
}

///|
pub fn PrincipalRefV1::principal_id(self : PrincipalRefV1) -> String {
  self.principal_id
}

///|
pub fn PrincipalRefV1::kind(self : PrincipalRefV1) -> PrincipalKindV1 {
  self.kind
}

///|
pub fn PrincipalRefV1::issuer(self : PrincipalRefV1) -> String {
  self.issuer
}

///|
pub fn PrincipalRefV1::subject(self : PrincipalRefV1) -> String {
  self.subject
}

///|
pub fn PrincipalRefV1::canonical_text(self : PrincipalRefV1) -> String {
  "\{self.kind.id()}|\{self.principal_id}|\{self.issuer}|\{self.subject}"
}

///|
/// A validated SHA-256 identity. The bytes are not trusted merely because a
/// digest is well formed; consumers still verify the referenced bytes.
pub struct DigestRefV1 {
  text : String
} derive(Debug, Eq, Compare, Hash)

///|
pub fn digest_ref_v1(value : String) -> DigestRefV1 raise CapabilityContractError {
  if !sha256_digest_is_canonical(value) {
    raise InvalidReference("digest must be lowercase sha256")
  }
  { text: value }
}

///|
pub fn DigestRefV1::text(self : DigestRefV1) -> String {
  self.text
}

///|
fn shared_hex_digit(value : Int) -> Char {
  if value < 10 {
    ('0'.to_int() + value).unsafe_to_char()
  } else {
    ('a'.to_int() + value - 10).unsafe_to_char()
  }
}

///|
pub fn sha256_digest_ref_v1(bytes : Bytes) -> DigestRefV1 {
  let digest = @crypto.sha256(bytes)
  let builder = StringBuilder::new()
  builder.write_string("sha256:")
  for byte in digest {
    let value = byte.to_int()
    builder.write_char(shared_hex_digit(value / 16))
    builder.write_char(shared_hex_digit(value % 16))
  }
  { text: builder.to_string() }
}

///|
/// A versioned contract identity distinct from an operation or schema.
pub struct ContractRefV1 {
  contract_id : String
  contract_version : String
} derive(Debug, Eq)

///|
pub fn contract_ref_v1(
  contract_id : String,
  contract_version : String,
) -> ContractRefV1 raise CapabilityContractError {
  if !identifier_component_is_canonical(contract_id) ||
    !semantic_version_is_canonical(contract_version) {
    raise InvalidReference("contract reference is not canonical")
  }
  { contract_id, contract_version }
}

///|
pub fn ContractRefV1::contract_id(self : ContractRefV1) -> String {
  self.contract_id
}

///|
pub fn ContractRefV1::contract_version(self : ContractRefV1) -> String {
  self.contract_version
}

///|
pub fn ContractRefV1::format(self : ContractRefV1) -> String {
  "\{self.contract_id}@\{self.contract_version}"
}

///|
/// A content-bound workspace identity. It does not grant access to the path.
pub struct WorkspaceRefV1 {
  workspace_id : String
  revision : String
  digest : DigestRefV1
} derive(Debug, Eq)

///|
pub fn workspace_ref_v1(
  workspace_id : String,
  revision : String,
  digest : String,
) -> WorkspaceRefV1 raise CapabilityContractError {
  if !identifier_component_is_canonical(workspace_id) ||
    !identifier_component_is_canonical(revision) {
    raise InvalidReference("workspace identity is not canonical")
  }
  { workspace_id, revision, digest: digest_ref_v1(digest) }
}

///|
pub fn WorkspaceRefV1::workspace_id(self : WorkspaceRefV1) -> String {
  self.workspace_id
}

///|
pub fn WorkspaceRefV1::revision(self : WorkspaceRefV1) -> String {
  self.revision
}

///|
pub fn WorkspaceRefV1::digest(self : WorkspaceRefV1) -> DigestRefV1 {
  self.digest
}

///|
pub fn WorkspaceRefV1::canonical_text(self : WorkspaceRefV1) -> String {
  "\{self.workspace_id}|\{self.revision}|\{self.digest.text()}"
}

///|
fn portable_correlation_token(value : String) -> Bool {
  !value.is_empty() &&
  value.length() <= 512 &&
  value.iter().all(fn(char) {
    char.is_ascii_alphabetic() ||
    char.is_ascii_digit() ||
    char == '.' ||
    char == '-' ||
    char == '_' ||
    char == ':' ||
    char == '/' ||
    char == '@'
  })
}

///|
/// Exact cross-product correlation. Empty optional identities are represented
/// as `None`, never as magic empty strings.
pub struct CorrelationRefV1 {
  run_id : String
  work_item_id : String
  request_id : String?
  attempt_id : String?
  idempotency_key : String?
} derive(Debug, Eq)

///|
pub fn correlation_ref_v1(
  run_id : String,
  work_item_id : String,
  request_id? : String,
  attempt_id? : String,
  idempotency_key? : String,
) -> CorrelationRefV1 raise CapabilityContractError {
  let required = [run_id, work_item_id]
  if required.any(value => !portable_correlation_token(value)) ||
    [request_id, attempt_id, idempotency_key].any(value =>
      value is Some(token) && !portable_correlation_token(token)
    ) {
    raise InvalidReference("correlation reference is not canonical")
  }
  { run_id, work_item_id, request_id, attempt_id, idempotency_key }
}

///|
pub fn CorrelationRefV1::run_id(self : CorrelationRefV1) -> String {
  self.run_id
}

///|
pub fn CorrelationRefV1::work_item_id(self : CorrelationRefV1) -> String {
  self.work_item_id
}

///|
pub fn CorrelationRefV1::request_id(self : CorrelationRefV1) -> String? {
  self.request_id
}

///|
pub fn CorrelationRefV1::attempt_id(self : CorrelationRefV1) -> String? {
  self.attempt_id
}

///|
pub fn CorrelationRefV1::idempotency_key(self : CorrelationRefV1) -> String? {
  self.idempotency_key
}

///|
pub fn CorrelationRefV1::canonical_text(self : CorrelationRefV1) -> String {
  let request = self.request_id.unwrap_or("-")
  let attempt = self.attempt_id.unwrap_or("-")
  let idempotency = self.idempotency_key.unwrap_or("-")
  "\{self.run_id}|\{self.work_item_id}|\{request}|\{attempt}|\{idempotency}"
}

///|
/// Reference to an immutable, content-bound delegation. Scope and budgets live
/// in the owning runtime record; this shared value only preserves the chain.
pub struct DelegationRefV1 {
  delegation_id : String
  delegator : PrincipalRefV1
  delegate : PrincipalRefV1
  digest : DigestRefV1
  parent_digest : DigestRefV1?
} derive(Debug, Eq)

///|
pub fn delegation_ref_v1(
  delegation_id : String,
  delegator : PrincipalRefV1,
  delegate : PrincipalRefV1,
  digest : String,
  parent_digest? : String,
) -> DelegationRefV1 raise CapabilityContractError {
  if !identifier_component_is_canonical(delegation_id) || delegator == delegate {
    raise InvalidReference("delegation identity is not canonical")
  }
  {
    delegation_id,
    delegator,
    delegate,
    digest: digest_ref_v1(digest),
    parent_digest: match parent_digest {
      Some(value) => Some(digest_ref_v1(value))
      None => None
    },
  }
}

///|
pub fn DelegationRefV1::delegation_id(self : DelegationRefV1) -> String {
  self.delegation_id
}

///|
pub fn DelegationRefV1::delegator(self : DelegationRefV1) -> PrincipalRefV1 {
  self.delegator
}

///|
pub fn DelegationRefV1::delegate(self : DelegationRefV1) -> PrincipalRefV1 {
  self.delegate
}

///|
pub fn DelegationRefV1::digest(self : DelegationRefV1) -> DigestRefV1 {
  self.digest
}

///|
pub fn DelegationRefV1::parent_digest(self : DelegationRefV1) -> DigestRefV1? {
  self.parent_digest
}

///|
/// Reference to a fresh authority decision. A handover may cite an older
/// decision as evidence, but an importing runtime must require a decision that
/// names its own receiver principal and remains unexpired.
pub struct AuthorityDecisionRefV1 {
  decision_id : String
  principal : PrincipalRefV1
  digest : DigestRefV1
  decided_at : String
  expires_at : String
} derive(Debug, Eq)

///|
pub fn authority_decision_ref_v1(
  decision_id : String,
  principal : PrincipalRefV1,
  digest : String,
  decided_at : String,
  expires_at : String,
) -> AuthorityDecisionRefV1 raise CapabilityContractError {
  if !identifier_component_is_canonical(decision_id) ||
    !wire_timestamp_is_canonical(decided_at) ||
    !wire_timestamp_is_canonical(expires_at) ||
    decided_at >= expires_at {
    raise InvalidReference("authority decision reference is not canonical")
  }
  { decision_id, principal, digest: digest_ref_v1(digest), decided_at, expires_at }
}

///|
pub fn AuthorityDecisionRefV1::decision_id(self : AuthorityDecisionRefV1) -> String {
  self.decision_id
}

///|
pub fn AuthorityDecisionRefV1::principal(self : AuthorityDecisionRefV1) -> PrincipalRefV1 {
  self.principal
}

///|
pub fn AuthorityDecisionRefV1::digest(self : AuthorityDecisionRefV1) -> DigestRefV1 {
  self.digest
}

///|
pub fn AuthorityDecisionRefV1::decided_at(self : AuthorityDecisionRefV1) -> String {
  self.decided_at
}

///|
pub fn AuthorityDecisionRefV1::expires_at(self : AuthorityDecisionRefV1) -> String {
  self.expires_at
}

///|
pub fn AuthorityDecisionRefV1::is_fresh_for(
  self : AuthorityDecisionRefV1,
  principal : PrincipalRefV1,
  at : String,
) -> Bool {
  self.principal == principal &&
  wire_timestamp_is_canonical(at) &&
  self.decided_at <= at &&
  at < self.expires_at
}

///|
priv struct PrincipalRefWireV1 {
  contract_id : String
  principal_id : String
  kind : String
  issuer : String
  subject : String
} derive(ToJson, FromJson)

///|
pub fn encode_principal_ref_v1(reference : PrincipalRefV1) -> Json {
  PrincipalRefWireV1::{
    contract_id: "moonsuite.principal-ref.v1",
    principal_id: reference.principal_id,
    kind: reference.kind.id(),
    issuer: reference.issuer,
    subject: reference.subject,
  }.to_json()
}

///|
pub fn decode_principal_ref_v1(value : Json) -> PrincipalRefV1 raise CapabilityContractError {
  let wire : PrincipalRefWireV1 = decode_wire(value, "moonsuite.principal-ref.v1")
  if wire.contract_id != "moonsuite.principal-ref.v1" {
    raise InvalidReference("unsupported principal reference contract")
  }
  principal_ref_v1(
    wire.principal_id,
    principal_kind_v1_from_id(wire.kind),
    wire.issuer,
    wire.subject,
  )
}

///|
priv struct ContractRefWireV1 {
  contract_id : String
  referenced_contract_id : String
  referenced_contract_version : String
} derive(ToJson, FromJson)

///|
pub fn encode_contract_ref_v1(reference : ContractRefV1) -> Json {
  ContractRefWireV1::{
    contract_id: "moonsuite.contract-ref.v1",
    referenced_contract_id: reference.contract_id,
    referenced_contract_version: reference.contract_version,
  }.to_json()
}

///|
pub fn decode_contract_ref_v1(value : Json) -> ContractRefV1 raise CapabilityContractError {
  let wire : ContractRefWireV1 = decode_wire(value, "moonsuite.contract-ref.v1")
  if wire.contract_id != "moonsuite.contract-ref.v1" {
    raise InvalidReference("unsupported contract reference contract")
  }
  contract_ref_v1(wire.referenced_contract_id, wire.referenced_contract_version)
}

///|
priv struct WorkspaceRefWireV1 {
  contract_id : String
  workspace_id : String
  revision : String
  digest : String
} derive(ToJson, FromJson)

///|
pub fn encode_workspace_ref_v1(reference : WorkspaceRefV1) -> Json {
  WorkspaceRefWireV1::{
    contract_id: "moonsuite.workspace-ref.v1",
    workspace_id: reference.workspace_id,
    revision: reference.revision,
    digest: reference.digest.text(),
  }.to_json()
}

///|
pub fn decode_workspace_ref_v1(value : Json) -> WorkspaceRefV1 raise CapabilityContractError {
  let wire : WorkspaceRefWireV1 = decode_wire(value, "moonsuite.workspace-ref.v1")
  if wire.contract_id != "moonsuite.workspace-ref.v1" {
    raise InvalidReference("unsupported workspace reference contract")
  }
  workspace_ref_v1(wire.workspace_id, wire.revision, wire.digest)
}

///|
priv struct CorrelationRefWireV1 {
  contract_id : String
  run_id : String
  work_item_id : String
  request_id : String?
  attempt_id : String?
  idempotency_key : String?
} derive(ToJson, FromJson)

///|
pub fn encode_correlation_ref_v1(reference : CorrelationRefV1) -> Json {
  CorrelationRefWireV1::{
    contract_id: "moonsuite.correlation-ref.v1",
    run_id: reference.run_id,
    work_item_id: reference.work_item_id,
    request_id: reference.request_id,
    attempt_id: reference.attempt_id,
    idempotency_key: reference.idempotency_key,
  }.to_json()
}

///|
pub fn decode_correlation_ref_v1(value : Json) -> CorrelationRefV1 raise CapabilityContractError {
  let wire : CorrelationRefWireV1 = decode_wire(value, "moonsuite.correlation-ref.v1")
  if wire.contract_id != "moonsuite.correlation-ref.v1" {
    raise InvalidReference("unsupported correlation reference contract")
  }
  correlation_ref_v1(
    wire.run_id,
    wire.work_item_id,
    request_id?=wire.request_id,
    attempt_id?=wire.attempt_id,
    idempotency_key?=wire.idempotency_key,
  )
}

///|
priv struct DigestRefWireV1 {
  contract_id : String
  digest : String
} derive(ToJson, FromJson)

///|
pub fn encode_digest_ref_v1(reference : DigestRefV1) -> Json {
  DigestRefWireV1::{
    contract_id: "moonsuite.digest-ref.v1",
    digest: reference.text,
  }.to_json()
}

///|
pub fn decode_digest_ref_v1(value : Json) -> DigestRefV1 raise CapabilityContractError {
  let wire : DigestRefWireV1 = decode_wire(value, "moonsuite.digest-ref.v1")
  if wire.contract_id != "moonsuite.digest-ref.v1" {
    raise InvalidReference("unsupported digest reference contract")
  }
  digest_ref_v1(wire.digest)
}

///|
priv struct SchemaRefWireV1 {
  contract_id : String
  product_id : String
  schema_id : String
  schema_version : String
} derive(ToJson, FromJson)

///|
pub fn encode_schema_ref_v1(reference : SchemaRef) -> Json {
  SchemaRefWireV1::{
    contract_id: "moonsuite.schema-ref.v1",
    product_id: reference.product_id,
    schema_id: reference.schema_id,
    schema_version: reference.schema_version,
  }.to_json()
}

///|
pub fn decode_schema_ref_v1(value : Json) -> SchemaRef raise CapabilityContractError {
  let wire : SchemaRefWireV1 = decode_wire(value, "moonsuite.schema-ref.v1")
  if wire.contract_id != "moonsuite.schema-ref.v1" {
    raise InvalidReference("unsupported schema reference contract")
  }
  schema_ref(wire.product_id, wire.schema_id, wire.schema_version)
}

///|
priv struct OperationRefWireV1 {
  contract_id : String
  product_id : String
  tool_id : String
  pack_version : String
} derive(ToJson, FromJson)

///|
pub fn encode_operation_ref_v1(reference : OperationRef) -> Json {
  OperationRefWireV1::{
    contract_id: "moonsuite.operation-ref.v1",
    product_id: reference.product_id,
    tool_id: reference.tool_id,
    pack_version: reference.pack_version,
  }.to_json()
}

///|
pub fn decode_operation_ref_v1(value : Json) -> OperationRef raise CapabilityContractError {
  let wire : OperationRefWireV1 = decode_wire(value, "moonsuite.operation-ref.v1")
  if wire.contract_id != "moonsuite.operation-ref.v1" {
    raise InvalidReference("unsupported operation reference contract")
  }
  operation_ref(wire.product_id, wire.tool_id, wire.pack_version)
}

///|
priv struct DelegationRefWireV1 {
  contract_id : String
  delegation_id : String
  delegator : Json
  delegate : Json
  digest : String
  parent_digest : String?
} derive(ToJson, FromJson)

///|
pub fn encode_delegation_ref_v1(reference : DelegationRefV1) -> Json {
  DelegationRefWireV1::{
    contract_id: "moonsuite.delegation-ref.v1",
    delegation_id: reference.delegation_id,
    delegator: encode_principal_ref_v1(reference.delegator),
    delegate: encode_principal_ref_v1(reference.delegate),
    digest: reference.digest.text(),
    parent_digest: reference.parent_digest.map(value => value.text()),
  }.to_json()
}

///|
pub fn decode_delegation_ref_v1(value : Json) -> DelegationRefV1 raise CapabilityContractError {
  let wire : DelegationRefWireV1 = decode_wire(value, "moonsuite.delegation-ref.v1")
  if wire.contract_id != "moonsuite.delegation-ref.v1" {
    raise InvalidReference("unsupported delegation reference contract")
  }
  delegation_ref_v1(
    wire.delegation_id,
    decode_principal_ref_v1(wire.delegator),
    decode_principal_ref_v1(wire.delegate),
    wire.digest,
    parent_digest?=wire.parent_digest,
  )
}

///|
priv struct AuthorityDecisionRefWireV1 {
  contract_id : String
  decision_id : String
  principal : Json
  digest : String
  decided_at : String
  expires_at : String
} derive(ToJson, FromJson)

///|
pub fn encode_authority_decision_ref_v1(reference : AuthorityDecisionRefV1) -> Json {
  AuthorityDecisionRefWireV1::{
    contract_id: "moonsuite.authority-decision-ref.v1",
    decision_id: reference.decision_id,
    principal: encode_principal_ref_v1(reference.principal),
    digest: reference.digest.text(),
    decided_at: reference.decided_at,
    expires_at: reference.expires_at,
  }.to_json()
}

///|
pub fn decode_authority_decision_ref_v1(
  value : Json,
) -> AuthorityDecisionRefV1 raise CapabilityContractError {
  let wire : AuthorityDecisionRefWireV1 = decode_wire(
    value,
    "moonsuite.authority-decision-ref.v1",
  )
  if wire.contract_id != "moonsuite.authority-decision-ref.v1" {
    raise InvalidReference("unsupported authority decision reference contract")
  }
  authority_decision_ref_v1(
    wire.decision_id,
    decode_principal_ref_v1(wire.principal),
    wire.digest,
    wire.decided_at,
    wire.expires_at,
  )
}
