///|
pub(all) enum ClaimClass {
  Observation
  ResearchEvidence
  ExecutionResult
  AcceptedKnowledge
  DigitalArtifact
  SimulationEvidence
  ScenarioQualified
  CalibratedDigitalTwin
  HardwareInLoopQualified
  EngineeringUnitQualified
  PhysicalReadiness
  PhysicalEffectClaim
} derive(Debug, Eq, Compare, Hash, ToJson)

///|
pub fn ClaimClass::id(self : ClaimClass) -> String {
  match self {
    Observation => "observation"
    ResearchEvidence => "research-evidence"
    ExecutionResult => "execution-result"
    AcceptedKnowledge => "accepted-knowledge"
    DigitalArtifact => "digital-artifact"
    SimulationEvidence => "simulation-evidence"
    ScenarioQualified => "scenario-qualified"
    CalibratedDigitalTwin => "calibrated-digital-twin"
    HardwareInLoopQualified => "hardware-in-loop-qualified"
    EngineeringUnitQualified => "engineering-unit-qualified"
    PhysicalReadiness => "physical-readiness"
    PhysicalEffectClaim => "physical-effect-claim"
  }
}

///|
fn ClaimClass::rank(self : ClaimClass) -> Int {
  match self {
    Observation => 0
    ResearchEvidence => 1
    ExecutionResult => 2
    AcceptedKnowledge => 3
    DigitalArtifact => 4
    SimulationEvidence => 5
    ScenarioQualified => 6
    CalibratedDigitalTwin => 7
    HardwareInLoopQualified => 8
    EngineeringUnitQualified => 9
    PhysicalReadiness => 10
    PhysicalEffectClaim => 11
  }
}

///|
pub fn ClaimClass::allows(self : ClaimClass, requested : ClaimClass) -> Bool {
  self.rank() >= requested.rank()
}

///|
pub(all) struct ProductBoundary {
  product_id : String
  owner : String
  operations : Array[String]
  allowed_authorities : Array[AuthorityClass]
  input_contracts : Array[String]
  output_contracts : Array[String]
  claim_ceiling : ClaimClass
  prohibited_claims : Array[ClaimClass]
} derive(Debug, Eq, ToJson)

///|
pub fn ProductBoundary::quality_issues(self : ProductBoundary) -> Array[String] {
  let issues : Array[String] = []
  if self.product_id.trim().is_empty() {
    issues.push("product_id is required")
  }
  if self.owner.trim().is_empty() {
    issues.push("product owner is required")
  }
  if self.operations.is_empty() {
    issues.push("at least one operation is required")
  }
  if self.allowed_authorities.is_empty() {
    issues.push("at least one authority is required")
  }
  if self.output_contracts.is_empty() {
    issues.push("at least one output contract is required")
  }
  if self.prohibited_claims.contains(self.claim_ceiling) {
    issues.push("claim ceiling cannot also be prohibited")
  }
  issues
}

///|
pub(all) struct CriterionOwnership {
  criterion_id : String
  owner_product_id : String
  required_claim : ClaimClass
  negative_path_required : Bool
  evidence_refs : Array[String]
} derive(Debug, Eq, ToJson)

///|
pub(all) struct ConformanceSubject {
  subject_id : String
  product_id : String
  operation : String
  requested_authority : AuthorityClass
  input_contracts : Array[String]
  output_contracts : Array[String]
  claim : ClaimClass
  criteria : Array[CriterionOwnership]
  negative_path_count : Int
  execution_succeeded : Bool
  accepted : Bool
  acceptance_review_ref : String
  workspace_root : String
  artifact_paths : Array[String]
} derive(Debug, Eq, ToJson)

///|
pub(all) struct ConformanceFinding {
  code : String
  path : String
  message : String
  severity : String
} derive(Debug, Eq, ToJson)

///|
pub(all) struct ConstitutionConformanceReport {
  contract_id : String
  report_id : String
  subject_id : String
  product_id : String
  accepted : Bool
  findings : Array[ConformanceFinding]
  checked_at : String
} derive(Debug, Eq, ToJson)

///|
fn conformance_finding(
  code : String,
  path : String,
  message : String,
) -> ConformanceFinding {
  { code, path, message, severity: "error" }
}

///|
fn find_boundary(
  registry : Array[ProductBoundary],
  product_id : String,
) -> ProductBoundary? {
  for boundary in registry {
    if boundary.product_id == product_id {
      return Some(boundary)
    }
  }
  None
}

///|
fn safe_workspace_artifact(path : String) -> Bool {
  let normalized = path.trim().replace(old="\\", new="/")
  !normalized.is_empty() &&
  !normalized.has_prefix("/") &&
  !normalized.split("/").any(segment => segment == "..")
}

///|
fn duplicate_product_id(registry : Array[ProductBoundary]) -> String? {
  let seen : Array[String] = []
  for boundary in registry {
    if seen.contains(boundary.product_id) {
      return Some(boundary.product_id)
    }
    seen.push(boundary.product_id)
  }
  None
}

///|
pub fn validate_constitutional_conformance(
  registry : Array[ProductBoundary],
  subject : ConformanceSubject,
  report_id : String,
  checked_at : String,
) -> ConstitutionConformanceReport {
  let findings : Array[ConformanceFinding] = []
  if report_id.trim().is_empty() {
    findings.push(
      conformance_finding(
        "missing-report-id", "report_id", "report identity is required",
      ),
    )
  }
  if checked_at.trim().is_empty() {
    findings.push(
      conformance_finding(
        "missing-checked-at", "checked_at", "check timestamp is required",
      ),
    )
  }
  match duplicate_product_id(registry) {
    Some(id) =>
      findings.push(
        conformance_finding(
          "duplicate-product-boundary",
          "registry",
          "duplicate product boundary: \{id}",
        ),
      )
    None => ()
  }
  for boundary in registry {
    for issue in boundary.quality_issues() {
      findings.push(
        conformance_finding(
          "invalid-product-boundary",
          "registry.\{boundary.product_id}",
          issue,
        ),
      )
    }
  }
  match find_boundary(registry, subject.product_id) {
    None =>
      findings.push(
        conformance_finding(
          "unknown-product",
          "product_id",
          "no constitutional boundary exists for \{subject.product_id}",
        ),
      )
    Some(boundary) => {
      if !boundary.operations.contains(subject.operation) {
        findings.push(
          conformance_finding(
            "operation-not-owned",
            "operation",
            "\{subject.product_id} does not own operation \{subject.operation}",
          ),
        )
      }
      if !boundary.allowed_authorities.contains(subject.requested_authority) {
        findings.push(
          conformance_finding(
            "authority-not-allowed",
            "requested_authority",
            "\{subject.requested_authority.id()} is outside the product boundary",
          ),
        )
      }
      for contract in subject.input_contracts {
        if !boundary.input_contracts.contains(contract) {
          findings.push(
            conformance_finding(
              "input-contract-not-allowed",
              "input_contracts",
              "input contract \{contract} is outside the product boundary",
            ),
          )
        }
      }
      for contract in subject.output_contracts {
        if !boundary.output_contracts.contains(contract) {
          findings.push(
            conformance_finding(
              "output-contract-not-owned",
              "output_contracts",
              "output contract \{contract} is not owned by \{subject.product_id}",
            ),
          )
        }
      }
      if !boundary.claim_ceiling.allows(subject.claim) {
        findings.push(
          conformance_finding(
            "claim-ceiling-exceeded",
            "claim",
            "claim \{subject.claim.id()} exceeds \{boundary.claim_ceiling.id()}",
          ),
        )
      }
      if boundary.prohibited_claims.contains(subject.claim) {
        findings.push(
          conformance_finding(
            "prohibited-claim",
            "claim",
            "claim \{subject.claim.id()} is explicitly prohibited",
          ),
        )
      }
      for criterion in subject.criteria {
        if criterion.owner_product_id != subject.product_id {
          findings.push(
            conformance_finding(
              "criterion-owned-by-another-product",
              "criteria.\{criterion.criterion_id}",
              "criterion belongs to \{criterion.owner_product_id}, not \{subject.product_id}",
            ),
          )
        }
        if !boundary.claim_ceiling.allows(criterion.required_claim) {
          findings.push(
            conformance_finding(
              "criterion-requires-downstream-claim",
              "criteria.\{criterion.criterion_id}",
              "criterion requires \{criterion.required_claim.id()} above the product claim ceiling",
            ),
          )
        }
        if criterion.negative_path_required && subject.negative_path_count < 1 {
          findings.push(
            conformance_finding(
              "missing-negative-path",
              "criteria.\{criterion.criterion_id}",
              "criterion requires at least one declared negative-path result",
            ),
          )
        }
        if subject.accepted && criterion.evidence_refs.is_empty() {
          findings.push(
            conformance_finding(
              "accepted-criterion-without-evidence",
              "criteria.\{criterion.criterion_id}",
              "accepted criteria require durable evidence",
            ),
          )
        }
      }
    }
  }
  if subject.accepted && !subject.execution_succeeded {
    findings.push(
      conformance_finding(
        "acceptance-without-execution-result", "accepted", "acceptance requires a successfully reconciled execution result",
      ),
    )
  }
  if subject.accepted && subject.acceptance_review_ref.trim().is_empty() {
    findings.push(
      conformance_finding(
        "acceptance-without-review", "acceptance_review_ref", "execution success cannot become acceptance without a review receipt",
      ),
    )
  }
  if subject.requested_authority == PhysicalEffect &&
    subject.claim.rank() <= SimulationEvidence.rank() {
    findings.push(
      conformance_finding(
        "simulation-cannot-authorize-physical-effect", "requested_authority", "simulation or lower evidence cannot grant physical-effect authority",
      ),
    )
  }
  if subject.workspace_root.trim().is_empty() {
    findings.push(
      conformance_finding(
        "missing-workspace-root", "workspace_root", "an explicit workspace root is required",
      ),
    )
  }
  for path in subject.artifact_paths {
    if !safe_workspace_artifact(path) {
      findings.push(
        conformance_finding(
          "workspace-artifact-escape",
          "artifact_paths",
          "artifact path must be workspace-relative without traversal: \{path}",
        ),
      )
    }
  }
  {
    contract_id: "moonsuite.constitution-conformance.v1",
    report_id,
    subject_id: subject.subject_id,
    product_id: subject.product_id,
    accepted: findings.is_empty(),
    findings,
    checked_at,
  }
}
