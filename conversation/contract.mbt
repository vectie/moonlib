///|
pub fn contract_id() -> String {
  "moonsuite-conversation.v2"
}

///|
pub fn contract_kind() -> String {
  "moonsuite-conversation-contract"
}

///|
pub fn conversation_kind(product_id~ : String) -> String {
  normalized_product_id(product_id) + "-conversation"
}

///|
pub fn turn_kind(product_id~ : String) -> String {
  normalized_product_id(product_id) + "-conversation-turn"
}

///|
pub fn conversation_required_fields() -> Array[String] {
  ["contract_id", "session_id", "revision", "last_sequence", "turns"]
}

///|
pub fn turn_order() -> Array[String] {
  ["user", "work", "assistant"]
}

///|
pub fn identity_fields() -> Array[String] {
  ["turn_id", "client_turn_id", "command_id", "ordinal"]
}

///|
pub fn turn_required_fields() -> Array[String] {
  [
    "kind", "turn_id", "client_turn_id", "command_id", "ordinal", "status", "user",
    "work", "assistant",
  ]
}

///|
pub fn slot_required_fields() -> Array[String] {
  ["item_id", "status"]
}

///|
pub fn work_required_fields() -> Array[String] {
  ["item_id", "status", "summary", "steps", "live"]
}

///|
pub fn work_step_kinds() -> Array[String] {
  [
    "thought", "context", "tool", "approval", "edit", "test", "artifact", "status",
  ]
}

///|
pub fn event_identity_rule() -> String {
  "Every user-facing runtime event must carry turn_id or command_id before it can update a conversation turn."
}

///|
pub fn diagnostics_rule() -> String {
  "Raw runtime, service, stream, and queue records are diagnostic evidence; they are not transcript rows unless projected through this contract."
}

///|
pub fn ordering_rule() -> String {
  "Turns are append-only by ordinal; later evidence may update a stable slot or step id but must never move an existing turn or item."
}

///|
pub fn revision_rule() -> String {
  "revision and last_sequence are monotonic; unchanged revisions represent an unchanged canonical conversation."
}

///|
pub fn contract_json(
  product_id~ : String,
  protocol~ : String,
  durable_owner~ : String,
  runtime_owner~ : String,
  ui_owner~ : String,
) -> Json {
  {
    "kind": contract_kind(),
    "protocol": protocol,
    "contract_id": contract_id(),
    "product_id": normalized_product_id(product_id),
    "conversation_kind": conversation_kind(product_id~),
    "turn_kind": turn_kind(product_id~),
    "conversation_required_fields": conversation_required_fields(),
    "turn_required_fields": turn_required_fields(),
    "slot_required_fields": slot_required_fields(),
    "work_required_fields": work_required_fields(),
    "work_step_kinds": work_step_kinds(),
    "turn_order": turn_order(),
    "identity_fields": identity_fields(),
    "ownership": {
      "durable_owner": durable_owner,
      "projection_owner": runtime_owner,
      "ui_owner": ui_owner,
      "shared_contract_owner": "moonlib",
    },
    "event_identity_rule": event_identity_rule(),
    "diagnostics_rule": diagnostics_rule(),
    "ordering_rule": ordering_rule(),
    "revision_rule": revision_rule(),
  }
}

///|
fn normalized_product_id(product_id : String) -> String {
  let trimmed = product_id.trim().to_owned()
  if trimmed == "" {
    "moon"
  } else {
    trimmed
  }
}
