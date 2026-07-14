///|
pub fn journal_contract_id() -> String {
  "moonsuite-conversation-journal.v1"
}

///|
pub fn journal_record_kind() -> String {
  "moonsuite-conversation-journal-record"
}

///|
pub fn journal_record_kinds() -> Array[String] {
  ["command", "runtime-receipt", "event", "package-result", "book-result"]
}

///|
pub fn journal_required_fields() -> Array[String] {
  [
    "kind", "contract_id", "session_id", "sequence", "record_id", "record_kind",
    "command_id", "client_turn_id", "recorded_at", "payload",
  ]
}

///|
pub fn journal_record(
  session_id~ : String,
  sequence~ : Int,
  record_id~ : String,
  record_kind~ : String,
  command_id~ : String,
  client_turn_id~ : String,
  recorded_at~ : Json,
  payload~ : Json,
) -> Json {
  {
    "kind": journal_record_kind(),
    "contract_id": journal_contract_id(),
    "session_id": session_id,
    "sequence": sequence,
    "record_id": record_id,
    "record_kind": record_kind,
    "command_id": command_id,
    "client_turn_id": client_turn_id,
    "recorded_at": recorded_at,
    "payload": payload,
  }
}

///|
pub fn journal_record_issues(record : Json) -> Array[String] {
  let issues : Array[String] = []
  for field in journal_required_fields() {
    if journal_object_field(record, field) is None {
      issues.push("missing required field: \{field}")
    }
  }
  if journal_string(record, "kind") != journal_record_kind() {
    issues.push("kind must be \{journal_record_kind()}")
  }
  if journal_string(record, "contract_id") != journal_contract_id() {
    issues.push("contract_id must be \{journal_contract_id()}")
  }
  if journal_string(record, "session_id") == "" {
    issues.push("session_id must be non-empty")
  }
  if journal_int(record, "sequence") <= 0 {
    issues.push("sequence must be positive")
  }
  if journal_string(record, "record_id") == "" {
    issues.push("record_id must be non-empty")
  }
  if !journal_record_kinds().contains(journal_string(record, "record_kind")) {
    issues.push("record_kind is unsupported")
  }
  if journal_object_field(record, "recorded_at") is Some(Null) {
    issues.push("recorded_at must be non-null")
  }
  if !(journal_object_field(record, "payload") is Some(Object(_))) {
    issues.push("payload must be an object")
  }
  issues
}

///|
pub fn journal_contract_json() -> Json {
  {
    "kind": "moonsuite-conversation-journal-contract",
    "contract_id": journal_contract_id(),
    "record_kind": journal_record_kind(),
    "record_kinds": journal_record_kinds(),
    "required_fields": journal_required_fields(),
    "ordering_rule": "A session has one append-only journal. sequence starts at one, is contiguous, and is allocated while holding the journal append lock.",
    "identity_rule": "record_id is idempotent within one session and record_kind. Re-appending the same identity returns the existing record without allocating a sequence.",
    "recovery_rule": "Only a torn final line may be discarded. Every prior valid record remains authoritative, and snapshots are replaceable checkpoints derived from this journal.",
    "projection_rule": "Canonical conversation revision and last_sequence equal the latest accepted journal sequence; projections may filter record kinds but may not invent another order.",
    "ownership": {
      "contract": "moonlib",
      "journal": "runtime owner",
      "projection": "runtime owner",
      "rendering": "product UI",
    },
  }
}

///|
fn journal_object_field(json : Json, key : String) -> Json? {
  match json {
    Object(fields) => fields.get(key)
    _ => None
  }
}

///|
fn journal_string(json : Json, key : String) -> String {
  match journal_object_field(json, key) {
    Some(String(value)) => value
    _ => ""
  }
}

///|
fn journal_int(json : Json, key : String) -> Int {
  match journal_object_field(json, key) {
    Some(Number(value, ..)) => value.to_int()
    _ => 0
  }
}
