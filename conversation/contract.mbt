///|
pub fn contract_id() -> String {
  "moonsuite-conversation.v1"
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
pub fn message_roles() -> Array[String] {
  ["user", "progress", "assistant"]
}

///|
pub fn turn_order() -> Array[String] {
  ["user", "progress", "assistant"]
}

///|
pub fn identity_fields() -> Array[String] {
  ["turn_id", "client_turn_id", "command_id"]
}

///|
pub fn turn_required_fields() -> Array[String] {
  [
    "kind", "turn_id", "client_turn_id", "command_id", "status", "user", "progress",
    "assistant", "items",
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
    "message_roles": message_roles(),
    "turn_required_fields": turn_required_fields(),
    "turn_order": turn_order(),
    "identity_fields": identity_fields(),
    "ownership": {
      "durable_owner": durable_owner,
      "runtime_owner": runtime_owner,
      "ui_owner": ui_owner,
      "shared_contract_owner": "moonlib",
    },
    "event_identity_rule": event_identity_rule(),
    "diagnostics_rule": diagnostics_rule(),
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
