///|
test "conversation watch contract carries only snapshot and resume cursors" {
  let snapshot : Json = {
    "kind": "mooncode-conversation",
    "contract_id": "moonsuite-conversation.v2",
    "session_id": "session-a",
    "revision": 7,
    "turns": [],
  }
  let response = @conversation.watch_response(
    session_id="session-a",
    revision=7,
    next_sequence=5,
    changed=true,
    heartbeat=false,
    terminal=false,
    retry_after_ms=25,
    snapshot~,
  )
  assert_eq(
    watch_test_json_string(response, "kind", default=""),
    "moonsuite-conversation-watch",
  )
  assert_eq(
    watch_test_json_string(response, "contract_id", default=""),
    "moonsuite-conversation-watch.v1",
  )
  assert_eq(watch_test_json_int(response, "revision", default=0), 7)
  assert_eq(watch_test_json_int(response, "next_sequence", default=0), 5)
  assert_eq(watch_test_json_int(response, "retry_after_ms", default=0), 100)
  assert_true(watch_test_json_bool(response, "changed", default=false))
  assert_false(watch_test_json_bool(response, "heartbeat", default=true))
  let carried = watch_test_json_object_field_or_empty(response, "snapshot")
  assert_eq(
    watch_test_json_string(carried, "session_id", default=""),
    "session-a",
  )
  assert_true(watch_test_json_object_field(response, "events") is None)
  assert_true(watch_test_json_object_field(response, "tail_events") is None)
}

///|
test "conversation watch heartbeat clamps cursors and exposes retry guidance" {
  let response = @conversation.watch_response(
    session_id="session-a",
    revision=-4,
    next_sequence=-2,
    changed=false,
    heartbeat=true,
    terminal=true,
    retry_after_ms=90000,
    snapshot=Json::null(),
  )
  assert_eq(watch_test_json_int(response, "revision", default=-1), 0)
  assert_eq(watch_test_json_int(response, "next_sequence", default=-1), 0)
  assert_eq(watch_test_json_int(response, "retry_after_ms", default=0), 30000)
  assert_false(watch_test_json_bool(response, "changed", default=true))
  assert_true(watch_test_json_bool(response, "heartbeat", default=false))
  assert_true(watch_test_json_bool(response, "terminal", default=false))
  assert_true(watch_test_json_object_field(response, "snapshot") is Some(Null))
  let contract = @conversation.watch_contract_json()
  assert_true(
    watch_test_json_string(contract, "resume_rule", default="").contains(
      "may never move either cursor backward",
    ),
  )
  assert_true(
    watch_test_json_string(contract, "payload_rule", default="").contains(
      "no transcript rows",
    ),
  )
}

///|
fn watch_test_json_object_field(json : Json, key : String) -> Json? {
  match json {
    Object(fields) => fields.get(key)
    _ => None
  }
}

///|
fn watch_test_json_object_field_or_empty(json : Json, key : String) -> Json {
  watch_test_json_object_field(json, key).unwrap_or(Json::object({}))
}

///|
fn watch_test_json_string(
  json : Json,
  key : String,
  default~ : String,
) -> String {
  match watch_test_json_object_field(json, key) {
    Some(String(value)) => value
    _ => default
  }
}

///|
fn watch_test_json_int(json : Json, key : String, default~ : Int) -> Int {
  match watch_test_json_object_field(json, key) {
    Some(Number(value, ..)) => value.to_int()
    _ => default
  }
}

///|
fn watch_test_json_bool(json : Json, key : String, default~ : Bool) -> Bool {
  match watch_test_json_object_field(json, key) {
    Some(True) => true
    Some(False) => false
    _ => default
  }
}
