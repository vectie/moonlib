///|
pub(all) enum CognitionGapKind {
  InformationGap
  CognitionGap
  ExecutionGap
} derive(Debug, Eq, Compare, Hash, ToJson)

///|
pub fn CognitionGapKind::id(self : CognitionGapKind) -> String {
  match self {
    InformationGap => "information-gap"
    CognitionGap => "cognition-gap"
    ExecutionGap => "execution-gap"
  }
}

///|
pub(all) struct KnowledgeGap {
  gap_id : String
  book_id : String
  kind : CognitionGapKind
  question : String
  required_by : Array[String]
  current_evidence : Array[String]
  missing : String
  urgency : String
  resolution_criteria : Array[String]
  status : String
  recorded_at : String
} derive(Debug, Eq, ToJson)

///|
pub fn KnowledgeGap::quality_issues(self : KnowledgeGap) -> Array[String] {
  let issues : Array[String] = []
  if self.gap_id.trim().is_empty() {
    issues.push("gap_id is required")
  }
  if self.book_id.trim().is_empty() {
    issues.push("book_id is required")
  }
  if self.question.trim().is_empty() {
    issues.push("gap question is required")
  }
  if self.required_by.is_empty() {
    issues.push("gap must identify what requires its resolution")
  }
  if self.missing.trim().is_empty() {
    issues.push("gap must state what is missing")
  }
  if self.resolution_criteria.is_empty() {
    issues.push("gap resolution criteria are required")
  }
  issues
}

///|
pub(all) struct BeliefUpdate {
  update_id : String
  book_id : String
  belief_id : String
  statement : String
  change : String
  evidence_refs : Array[String]
  confidence : Double
  affected_refs : Array[String]
  recorded_at : String
} derive(Debug, Eq, ToJson)

///|
pub fn BeliefUpdate::quality_issues(self : BeliefUpdate) -> Array[String] {
  let issues : Array[String] = []
  if self.update_id.trim().is_empty() {
    issues.push("update_id is required")
  }
  if self.belief_id.trim().is_empty() {
    issues.push("belief_id is required")
  }
  if self.statement.trim().is_empty() {
    issues.push("belief statement is required")
  }
  if self.change.trim().is_empty() {
    issues.push("belief change is required")
  }
  if self.evidence_refs.is_empty() {
    issues.push("belief update requires evidence")
  }
  if self.confidence < 0.0 || self.confidence > 1.0 {
    issues.push("belief confidence must be between 0 and 1")
  }
  issues
}

///|
pub(all) struct LearnedProcedure {
  procedure_id : String
  book_id : String
  title : String
  applicability : Array[String]
  steps : Array[String]
  verification_criteria : Array[String]
  failure_modes : Array[String]
  counterexamples : Array[String]
  evidence_refs : Array[String]
  status : String
  recorded_at : String
} derive(Debug, Eq, ToJson)

///|
pub fn LearnedProcedure::quality_issues(
  self : LearnedProcedure,
) -> Array[String] {
  let issues : Array[String] = []
  if self.procedure_id.trim().is_empty() {
    issues.push("procedure_id is required")
  }
  if self.title.trim().is_empty() {
    issues.push("procedure title is required")
  }
  if self.applicability.is_empty() {
    issues.push("procedure applicability is required")
  }
  if self.steps.is_empty() {
    issues.push("procedure steps are required")
  }
  if self.verification_criteria.is_empty() {
    issues.push("procedure verification criteria are required")
  }
  if self.failure_modes.is_empty() {
    issues.push("procedure failure modes are required")
  }
  if self.evidence_refs.is_empty() {
    issues.push("procedure evidence is required")
  }
  issues
}

///|
pub(all) struct BookkeeperReflection {
  reflection_id : String
  book_id : String
  trigger : String
  observations : Array[String]
  gaps : Array[KnowledgeGap]
  belief_updates : Array[BeliefUpdate]
  proposed_actions : Array[ExecutableDeclaration]
  learned_procedures : Array[LearnedProcedure]
  confidence : Double
  uncertainty : Array[String]
  requested_authority : AuthorityClass
  recorded_at : String
} derive(Debug, Eq, ToJson)

///|
pub fn BookkeeperReflection::quality_issues(
  self : BookkeeperReflection,
) -> Array[String] {
  let issues : Array[String] = []
  if self.reflection_id.trim().is_empty() {
    issues.push("reflection_id is required")
  }
  if self.book_id.trim().is_empty() {
    issues.push("book_id is required")
  }
  if self.trigger.trim().is_empty() {
    issues.push("reflection trigger is required")
  }
  if self.observations.is_empty() {
    issues.push("reflection observations are required")
  }
  if self.confidence < 0.0 || self.confidence > 1.0 {
    issues.push("reflection confidence must be between 0 and 1")
  }
  for gap in self.gaps {
    for issue in gap.quality_issues() {
      issues.push("\{gap.gap_id}: \{issue}")
    }
  }
  for update in self.belief_updates {
    for issue in update.quality_issues() {
      issues.push("\{update.update_id}: \{issue}")
    }
  }
  for procedure in self.learned_procedures {
    for issue in procedure.quality_issues() {
      issues.push("\{procedure.procedure_id}: \{issue}")
    }
  }
  let has_execution_gap = self.gaps.any(gap => gap.kind == ExecutionGap)
  if has_execution_gap && self.proposed_actions.is_empty() {
    issues.push("execution gaps require at least one proposed action")
  }
  issues
}
