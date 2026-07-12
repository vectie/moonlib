///|
pub(all) enum InterventionCategory {
  ConstitutionalAuthority
  OptionalObservation
  RequiredIntervention
  HiddenOrchestration
} derive(Debug, Eq, Compare, Hash, ToJson)

///|
pub fn InterventionCategory::id(self : InterventionCategory) -> String {
  match self {
    ConstitutionalAuthority => "constitutional-authority"
    OptionalObservation => "optional-observation"
    RequiredIntervention => "required-intervention"
    HiddenOrchestration => "hidden-orchestration"
  }
}

///|
pub fn intervention_category_from_id(id : String) -> InterventionCategory raise {
  match id {
    "constitutional-authority" => ConstitutionalAuthority
    "optional-observation" => OptionalObservation
    "required-intervention" => RequiredIntervention
    "hidden-orchestration" => HiddenOrchestration
    _ => fail("unsupported intervention category: \{id}")
  }
}

///|
pub(all) struct InterventionRecord {
  intervention_id : String
  category : InterventionCategory
  normal_path : Bool
  product_id : String
  reason : String
  evidence_ref : String
  recorded_at : String
} derive(Debug, Eq, ToJson)

///|
pub(all) struct InterventionScorecard {
  contract_id : String
  run_id : String
  constitutional_authority_count : Int
  optional_observation_count : Int
  required_intervention_count : Int
  hidden_orchestration_count : Int
  normal_path_intervention_count : Int
  unattended_qualified : Bool
  records : Array[InterventionRecord]
  checked_at : String
} derive(Debug, Eq, ToJson)

///|
pub fn intervention_scorecard(
  run_id : String,
  records : Array[InterventionRecord],
  checked_at : String,
) -> InterventionScorecard {
  let mut constitutional = 0
  let mut optional = 0
  let mut required = 0
  let mut hidden = 0
  let mut normal_path = 0
  for record in records {
    match record.category {
      ConstitutionalAuthority => constitutional += 1
      OptionalObservation => optional += 1
      RequiredIntervention => required += 1
      HiddenOrchestration => hidden += 1
    }
    if record.normal_path &&
      (
        record.category == RequiredIntervention ||
        record.category == HiddenOrchestration
      ) {
      normal_path += 1
    }
  }
  {
    contract_id: "moonflow.intervention-scorecard.v1",
    run_id,
    constitutional_authority_count: constitutional,
    optional_observation_count: optional,
    required_intervention_count: required,
    hidden_orchestration_count: hidden,
    normal_path_intervention_count: normal_path,
    unattended_qualified: hidden == 0 && normal_path == 0,
    records,
    checked_at,
  }
}
