///|
test "conversation control contract defines resumable approvals" {
  assert_eq(
    @conversation.control_contract_id(),
    "moonsuite-conversation-control.v1",
  )
  assert_true(@conversation.control_kinds().contains("tool-approval"))
  assert_true(@conversation.control_states().contains("pending"))
  assert_true(@conversation.control_states().contains("approved"))
  assert_true(@conversation.approval_decisions().contains("reject"))
  assert_eq(
    @conversation.approval_event_kind("pending"),
    "tool.approval_requested",
  )
  assert_eq(
    @conversation.approval_event_kind("approved"),
    "tool.approval_approved",
  )
  assert_eq(@conversation.cancellation_event_kind(), "runtime.turn_cancelled")
  assert_true(
    @conversation.approval_resume_rule().contains("without a terminal receipt"),
  )
}

///|
test "conversation control contract preserves canonical turn order" {
  let contract = @conversation.control_contract_json()
  assert_eq(
    control_test_string(contract, "contract_id"),
    "moonsuite-conversation-control.v1",
  )
  assert_true(
    control_test_string(contract, "ordering_rule").contains(
      "must never create, remove, or reorder",
    ),
  )
  assert_true(
    control_test_string(contract, "cancellation_rule").contains(
      "interrupts the active runtime task",
    ),
  )
  assert_true(@conversation.approval_required_fields().contains("tool_call_id"))
  assert_true(@conversation.approval_required_fields().contains("arguments"))
}

///|
fn control_test_string(json : Json, key : String) -> String {
  match json {
    Object(fields) =>
      match fields.get(key) {
        Some(String(value)) => value
        _ => ""
      }
    _ => ""
  }
}
