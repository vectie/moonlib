///|
test "pipeline contract ids are unique and versioned" {
  let ids : Array[String] = []
  for kind in @pipeline.contract_kinds() {
    let id = kind.id()
    assert_true(
      id.has_prefix("moonsuite.") ||
      id.has_prefix("moonbook.") ||
      id.has_prefix("moontown.") ||
      id.has_prefix("moongate.") ||
      id.has_prefix("moonflow."),
    )
    assert_true(id.has_suffix(".v1"))
    assert_false(ids.contains(id))
    ids.push(id)
  }
  assert_eq(ids.length(), 22)
}

///|
test "all pipeline schemas carry shared evidence and boundary rules" {
  for kind in @pipeline.contract_kinds() {
    let schema = @pipeline.schema_json(kind)
    let text = schema.stringify()
    assert_true(text.contains(kind.id()))
    assert_true(text.contains("replayable validation evidence"))
    assert_true(text.contains("physical deployment evidence"))
  }
}

///|
test "required field validation accepts extensions and reports omissions" {
  let route : Json = {
    "contract_id": "moonsuite.model-route.v1",
    "selected_model": "gpt-5.6-sol",
    "fallback_models": ["gpt-5.5"],
    "selection_reason": "live probe",
    "probes": [],
    "recorded_at": "2026-07-11T00:00:00Z",
    "future_extension": true,
  }
  assert_true(@pipeline.has_required_fields(ModelRoute, route))
  json_inspect(@pipeline.missing_required_fields(ModelRoute, route), content=[])
  let incomplete : Json = { "contract_id": "moonsuite.model-route.v1" }
  let missing = @pipeline.missing_required_fields(ModelRoute, incomplete)
  assert_true(missing.contains("selected_model"))
  assert_true(missing.contains("probes"))
  assert_false(@pipeline.has_required_fields(ModelRoute, incomplete))
}

///|
test "quality contract covers every pipeline acceptance dimension" {
  json_inspect(@pipeline.quality_dimensions(), content=[
    "completeness", "traceability", "consistency", "safety", "replayability",
  ])
  json_inspect(@pipeline.terminal_statuses(), content=[
    "accepted", "rejected", "blocked", "failed",
  ])
}
