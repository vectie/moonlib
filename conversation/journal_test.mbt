///|
test "conversation journal contract defines one total-order envelope" {
  let payload : Json = { "kind": "mooncode-command", "command_id": "command-1" }
  let record = @conversation.journal_record(
    session_id="session-a",
    sequence=7,
    record_id="command:command-1",
    record_kind="command",
    command_id="command-1",
    client_turn_id="client-turn-1",
    recorded_at="2026-07-15T00:00:00Z",
    payload~,
  )
  assert_eq(
    journal_test_string(record, "contract_id"),
    "moonsuite-conversation-journal.v1",
  )
  assert_eq(journal_test_int(record, "sequence"), 7)
  assert_eq(journal_test_string(record, "record_kind"), "command")
  assert_eq(journal_test_string(record, "command_id"), "command-1")
  assert_eq(journal_test_string(record, "client_turn_id"), "client-turn-1")
  assert_eq(@conversation.journal_record_issues(record).length(), 0)
}

///|
test "conversation journal validator rejects invalid ordering records" {
  let invalid = @conversation.journal_record(
    session_id="",
    sequence=0,
    record_id="",
    record_kind="legacy-event-log",
    command_id="",
    client_turn_id="",
    recorded_at=Json::null(),
    payload="not-an-object",
  )
  let issues = @conversation.journal_record_issues(invalid)
  assert_true(issues.contains("session_id must be non-empty"))
  assert_true(issues.contains("sequence must be positive"))
  assert_true(issues.contains("record_id must be non-empty"))
  assert_true(issues.contains("record_kind is unsupported"))
  assert_true(issues.contains("recorded_at must be non-null"))
  assert_true(issues.contains("payload must be an object"))
}

///|
test "conversation journal contract records recovery and idempotency rules" {
  let contract = @conversation.journal_contract_json()
  assert_true(
    journal_test_string(contract, "ordering_rule").contains(
      "one append-only journal",
    ),
  )
  assert_true(
    journal_test_string(contract, "identity_rule").contains(
      "without allocating a sequence",
    ),
  )
  assert_true(
    journal_test_string(contract, "recovery_rule").contains("torn final line"),
  )
  assert_true(
    journal_test_string(contract, "projection_rule").contains(
      "latest accepted journal sequence",
    ),
  )
  assert_eq(@conversation.journal_record_kinds().length(), 5)
}

///|
fn journal_test_field(json : Json, key : String) -> Json? {
  match json {
    Object(fields) => fields.get(key)
    _ => None
  }
}

///|
fn journal_test_string(json : Json, key : String) -> String {
  match journal_test_field(json, key) {
    Some(String(value)) => value
    _ => ""
  }
}

///|
fn journal_test_int(json : Json, key : String) -> Int {
  match journal_test_field(json, key) {
    Some(Number(value, ..)) => value.to_int()
    _ => 0
  }
}
