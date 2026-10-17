///|
/// Wire-compatible MoonFlow adapter request. Inputs, claims, authority, and
/// acceptance criteria are opaque data here; their interpretation belongs to
/// the orchestrator, host, and product adapter.
pub(all) struct AdapterRequestWireV1 {
  request_id : String
  run_id : String
  book_id : String
  work_item_id : String
  declaration_id : String
  attempt_id : String
  idempotency_key : String
  product_id : String
  operation : String
  requested_authority : String
  acceptance_criteria : Array[String]
  input_contracts : Array[String]
  output_contracts : Array[String]
  required_claim : String
  input_digest : String
  input_artifacts : Array[String]
  timeout_ms : Int32
  created_at : String
} derive(Debug, Eq, ToJson, FromJson)

///|
/// Wire-compatible MoonFlow adapter result. Status-specific retry and terminal
/// behavior is intentionally not defined by MoonLib.
pub(all) struct AdapterResultV1 {
  result_id : String
  request_id : String
  attempt_id : String
  idempotency_key : String
  product_id : String
  external_job_id : String
  status : String
  output_digest : String
  output_artifacts : Array[String]
  error_kind : String
  compensable : Bool
  recorded_at : String
} derive(Debug, Eq, ToJson, FromJson)

///|
/// Product-owned durable reconciliation receipt. `decision` and
/// `retry_allowed` are recorded outputs, never computed by this package.
pub(all) struct AdapterReconcileReceiptV1 {
  contract_id : String
  adapter_id : String
  request_id : String
  attempt_id : String
  decision : String
  retry_allowed : Bool
  evidence_refs : Array[String]
  result : AdapterResultV1
  message : String
  recorded_at : String
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn AdapterRequestWireV1::conformance_issues(
  self : AdapterRequestWireV1,
) -> Array[ContractIssueV1] {
  let issues : Array[ContractIssueV1] = []
  for
    pair in [
      ("request_id", self.request_id),
      ("run_id", self.run_id),
      ("book_id", self.book_id),
      ("work_item_id", self.work_item_id),
      ("declaration_id", self.declaration_id),
      ("attempt_id", self.attempt_id),
      ("idempotency_key", self.idempotency_key),
      ("product_id", self.product_id),
      ("operation", self.operation),
      ("requested_authority", self.requested_authority),
      ("input_digest", self.input_digest),
    ] {
    let (field, value) = pair
    add_required_issue(issues, field, value)
  }
  if !identifier_component_is_canonical(self.product_id) {
    add_issue(issues, "product_id", "must be a canonical identifier")
  }
  if self.timeout_ms <= 0 {
    add_issue(issues, "timeout_ms", "must be positive")
  }
  if !wire_timestamp_is_canonical(self.created_at) {
    add_issue(issues, "created_at", "must be a canonical UTC timestamp")
  }
  for index, artifact in self.input_artifacts {
    if !evidence_artifact_ref_is_canonical(artifact) {
      add_issue(
        issues,
        "input_artifacts[\{index}]",
        "must be a canonical workspace-relative artifact reference",
      )
    }
  }
  issues
}

///|
pub fn AdapterResultV1::conformance_issues(
  self : AdapterResultV1,
) -> Array[ContractIssueV1] {
  let issues : Array[ContractIssueV1] = []
  for
    pair in [
      ("result_id", self.result_id),
      ("request_id", self.request_id),
      ("attempt_id", self.attempt_id),
      ("idempotency_key", self.idempotency_key),
      ("product_id", self.product_id),
      ("status", self.status),
    ] {
    let (field, value) = pair
    add_required_issue(issues, field, value)
  }
  if !identifier_component_is_canonical(self.product_id) {
    add_issue(issues, "product_id", "must be a canonical identifier")
  }
  for index, artifact in self.output_artifacts {
    if !evidence_artifact_ref_is_canonical(artifact) {
      add_issue(
        issues,
        "output_artifacts[\{index}]",
        "must be a canonical workspace-relative artifact reference",
      )
    }
  }
  if !wire_timestamp_is_canonical(self.recorded_at) {
    add_issue(issues, "recorded_at", "must be a canonical UTC timestamp")
  }
  issues
}

///|
pub fn AdapterReconcileReceiptV1::conformance_issues(
  self : AdapterReconcileReceiptV1,
) -> Array[ContractIssueV1] {
  let issues : Array[ContractIssueV1] = []
  for
    pair in [
      ("contract_id", self.contract_id),
      ("adapter_id", self.adapter_id),
      ("request_id", self.request_id),
      ("attempt_id", self.attempt_id),
      ("decision", self.decision),
    ] {
    let (field, value) = pair
    add_required_issue(issues, field, value)
  }
  if !identifier_component_is_canonical(self.adapter_id) {
    add_issue(issues, "adapter_id", "must be a canonical identifier")
  }
  for index, artifact in self.evidence_refs {
    if !evidence_artifact_ref_is_canonical(artifact) {
      add_issue(
        issues,
        "evidence_refs[\{index}]",
        "must be a canonical workspace-relative artifact reference",
      )
    }
  }
  append_issues(issues, "result", self.result.conformance_issues())
  if self.request_id != self.result.request_id {
    add_issue(issues, "result.request_id", "must match the receipt request_id")
  }
  if self.attempt_id != self.result.attempt_id {
    add_issue(issues, "result.attempt_id", "must match the receipt attempt_id")
  }
  if !wire_timestamp_is_canonical(self.recorded_at) {
    add_issue(issues, "recorded_at", "must be a canonical UTC timestamp")
  }
  issues
}

///|
/// This is a DTO-version label, not a serialized MoonFlow contract id. Adapter
/// requests currently have no `contract_id` field.
pub fn decode_adapter_request_wire_v1(
  value : Json,
) -> AdapterRequestWireV1 raise CapabilityContractError {
  let request : AdapterRequestWireV1 = decode_wire(
    value, "MoonFlow adapter request wire shape",
  )
  raise_if_invalid(
    "MoonFlow adapter request wire shape",
    request.conformance_issues(),
  )
  request
}

///|
pub fn encode_adapter_request_wire_v1(
  request : AdapterRequestWireV1,
) -> Json raise CapabilityContractError {
  raise_if_invalid(
    "MoonFlow adapter request wire shape",
    request.conformance_issues(),
  )
  request.to_json()
}

///|
pub fn adapter_result_contract_v1() -> String {
  "moonflow.adapter-result.v1"
}

///|
pub fn decode_adapter_result_v1(
  value : Json,
) -> AdapterResultV1 raise CapabilityContractError {
  let result : AdapterResultV1 = decode_wire(
    value,
    adapter_result_contract_v1(),
  )
  raise_if_invalid(adapter_result_contract_v1(), result.conformance_issues())
  result
}

///|
pub fn encode_adapter_result_v1(
  result : AdapterResultV1,
) -> Json raise CapabilityContractError {
  raise_if_invalid(adapter_result_contract_v1(), result.conformance_issues())
  result.to_json()
}

///|
pub fn decode_adapter_reconcile_receipt_v1(
  value : Json,
) -> AdapterReconcileReceiptV1 raise CapabilityContractError {
  let receipt : AdapterReconcileReceiptV1 = decode_wire(
    value, "product adapter reconciliation receipt projection",
  )
  raise_if_invalid(
    "product adapter reconciliation receipt projection",
    receipt.conformance_issues(),
  )
  receipt
}

///|
pub fn encode_adapter_reconcile_receipt_v1(
  receipt : AdapterReconcileReceiptV1,
) -> Json raise CapabilityContractError {
  raise_if_invalid(
    "product adapter reconciliation receipt projection",
    receipt.conformance_issues(),
  )
  receipt.to_json()
}

///|
pub extend AdapterRequestWireV1 with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend AdapterRequestWireV1 with Eq::{not_equal, equal}

///|
pub extend AdapterRequestWireV1 with ToJson::{to_json}

///|
pub extend AdapterRequestWireV1 with @moonbitlang/core/json.FromJson::{
  from_json,
}

///|
pub extend AdapterResultV1 with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend AdapterResultV1 with Eq::{not_equal, equal}

///|
pub extend AdapterResultV1 with ToJson::{to_json}

///|
pub extend AdapterResultV1 with @moonbitlang/core/json.FromJson::{from_json}

///|
pub extend AdapterReconcileReceiptV1 with @moonbitlang/core/debug.Debug::{
  to_repr,
}

///|
pub extend AdapterReconcileReceiptV1 with Eq::{not_equal, equal}

///|
pub extend AdapterReconcileReceiptV1 with ToJson::{to_json}

///|
pub extend AdapterReconcileReceiptV1 with @moonbitlang/core/json.FromJson::{
  from_json,
}
