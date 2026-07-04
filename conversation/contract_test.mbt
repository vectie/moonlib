///|
test "conversation contract exposes shared schema constants" {
  assert_eq(@conversation.contract_id(), "moonsuite-conversation.v1")
  assert_eq(
    @conversation.conversation_kind(product_id="mooncode"),
    "mooncode-conversation",
  )
  assert_eq(
    @conversation.turn_kind(product_id="mooncode"),
    "mooncode-conversation-turn",
  )
  json_inspect(@conversation.message_roles(), content=[
    "user", "progress", "assistant",
  ])
  json_inspect(@conversation.turn_order(), content=[
    "user", "progress", "assistant",
  ])
  assert_true(@conversation.identity_fields().contains("turn_id"))
  assert_true(@conversation.identity_fields().contains("client_turn_id"))
  assert_true(@conversation.identity_fields().contains("command_id"))
  assert_true(@conversation.turn_required_fields().contains("items"))
}

///|
test "conversation contract json binds product owners without owning diagnostics" {
  let payload = @conversation.contract_json(
    product_id="mooncode",
    protocol="mooncode.v1",
    durable_owner="mooncode",
    runtime_owner="moonclaw",
    ui_owner="moondesk",
  )
  assert_eq(
    test_json_string(payload, "kind", default=""),
    "moonsuite-conversation-contract",
  )
  assert_eq(
    test_json_string(payload, "contract_id", default=""),
    "moonsuite-conversation.v1",
  )
  assert_eq(test_json_string(payload, "product_id", default=""), "mooncode")
  assert_eq(
    test_json_string(payload, "conversation_kind", default=""),
    "mooncode-conversation",
  )
  assert_eq(
    test_json_string(payload, "turn_kind", default=""),
    "mooncode-conversation-turn",
  )
  assert_true(
    payload.stringify().contains("\"shared_contract_owner\":\"moonlib\""),
  )
  assert_true(payload.stringify().contains("\"turn_id\""))
  assert_true(payload.stringify().contains("\"client_turn_id\""))
  assert_true(payload.stringify().contains("\"command_id\""))
}

///|
test "conversation contract normalizes empty product ids" {
  assert_eq(
    @conversation.conversation_kind(product_id="  "),
    "moon-conversation",
  )
  let payload = @conversation.contract_json(
    product_id="",
    protocol="moon.v1",
    durable_owner="moon",
    runtime_owner="moon",
    ui_owner="moon",
  )
  assert_eq(test_json_string(payload, "product_id", default=""), "moon")
  assert_eq(
    test_json_string(payload, "conversation_kind", default=""),
    "moon-conversation",
  )
}

///|
fn test_json_string(json : Json, key : String, default~ : String) -> String {
  match json {
    Object(fields) =>
      match fields.get(key) {
        Some(String(value)) => value
        _ => default
      }
    _ => default
  }
}
