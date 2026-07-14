///|
pub fn watch_contract_id() -> String {
  "moonsuite-conversation-watch.v1"
}

///|
pub fn watch_kind() -> String {
  "moonsuite-conversation-watch"
}

///|
pub fn watch_required_fields() -> Array[String] {
  [
    "contract_id", "session_id", "revision", "next_sequence", "changed", "heartbeat",
    "terminal", "retry_after_ms", "snapshot",
  ]
}

///|
pub fn watch_retry_after_ms_value(value : Int) -> Int {
  if value <= 0 {
    0
  } else if value < 100 {
    100
  } else if value > 30000 {
    30000
  } else {
    value
  }
}

///|
pub fn watch_response(
  session_id~ : String,
  revision~ : Int,
  next_sequence~ : Int,
  changed~ : Bool,
  heartbeat~ : Bool,
  terminal~ : Bool,
  retry_after_ms~ : Int,
  snapshot~ : Json,
) -> Json {
  {
    "kind": watch_kind(),
    "contract_id": watch_contract_id(),
    "session_id": session_id,
    "revision": non_negative_watch_cursor(revision),
    "next_sequence": non_negative_watch_cursor(next_sequence),
    "changed": changed,
    "heartbeat": heartbeat,
    "terminal": terminal,
    "retry_after_ms": watch_retry_after_ms_value(retry_after_ms),
    "snapshot": snapshot,
  }
}

///|
pub fn watch_contract_json() -> Json {
  {
    "kind": "moonsuite-conversation-watch-contract",
    "contract_id": watch_contract_id(),
    "required_fields": watch_required_fields(),
    "resume_rule": "Resume with the last accepted revision and next_sequence. A response may advance cursors but may never move either cursor backward.",
    "payload_rule": "Changed responses carry one canonical snapshot. Heartbeats carry no transcript rows, runtime events, or diagnostic records.",
    "ownership": {
      "snapshot": "runtime projection owner",
      "transport_contract": "moonlib",
      "rendering": "product UI",
    },
  }
}

///|
fn non_negative_watch_cursor(value : Int) -> Int {
  if value < 0 {
    0
  } else {
    value
  }
}
