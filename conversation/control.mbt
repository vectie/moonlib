///|
pub fn control_contract_id() -> String {
  "moonsuite-conversation-control.v1"
}

///|
pub fn control_record_kind() -> String {
  "moonsuite-conversation-control"
}

///|
pub fn control_kinds() -> Array[String] {
  ["tool-approval", "turn-cancellation"]
}

///|
pub fn control_states() -> Array[String] {
  ["pending", "approved", "rejected", "cancelled"]
}

///|
pub fn approval_decisions() -> Array[String] {
  ["approve", "reject"]
}

///|
pub fn control_required_fields() -> Array[String] {
  [
    "contract_id", "control_id", "control_kind", "state", "session_id", "target_command_id",
  ]
}

///|
pub fn approval_required_fields() -> Array[String] {
  control_required_fields() + ["tool_call_id", "tool", "arguments"]
}

///|
pub fn approval_event_kind(state : String) -> String {
  match state {
    "approved" => "tool.approval_approved"
    "rejected" => "tool.approval_rejected"
    _ => "tool.approval_requested"
  }
}

///|
pub fn cancellation_event_kind() -> String {
  "runtime.turn_cancelled"
}

///|
pub fn control_ordering_rule() -> String {
  "A control record targets one existing command. It may update one stable work-step identity, but it must never create, remove, or reorder a visible conversation turn."
}

///|
pub fn approval_resume_rule() -> String {
  "A pending approval leaves the target command claimed without a terminal receipt. An approval decision is durable before the runtime resumes that same command."
}

///|
pub fn cancellation_rule() -> String {
  "Cancellation interrupts the active runtime task, records a terminal cancelled receipt for the target command, and records a delivered receipt for the hidden control command."
}

///|
pub fn control_contract_json() -> Json {
  {
    "kind": "moonsuite-conversation-control-contract",
    "contract_id": control_contract_id(),
    "record_kind": control_record_kind(),
    "control_kinds": control_kinds(),
    "control_states": control_states(),
    "approval_decisions": approval_decisions(),
    "required_fields": control_required_fields(),
    "approval_required_fields": approval_required_fields(),
    "ordering_rule": control_ordering_rule(),
    "approval_resume_rule": approval_resume_rule(),
    "cancellation_rule": cancellation_rule(),
    "ownership": {
      "contract": "moonlib",
      "enforcement": "runtime owner",
      "projection": "runtime owner",
      "rendering": "product UI",
    },
  }
}
