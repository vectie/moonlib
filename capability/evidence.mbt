///|
/// A workspace-relative artifact reference bound to the digest of its exact
/// bytes. This type records identity only; it does not read, trust, authorize,
/// or retain the artifact.
pub struct ContentAddressedEvidenceRefV1 {
  evidence_ref : String
  evidence_digest : String
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn ContentAddressedEvidenceRefV1::evidence_ref(
  self : ContentAddressedEvidenceRefV1,
) -> String {
  self.evidence_ref
}

///|
pub fn ContentAddressedEvidenceRefV1::evidence_digest(
  self : ContentAddressedEvidenceRefV1,
) -> String {
  self.evidence_digest
}

///|
/// Canonical SHA-256 identity used on the capability wire.
pub fn sha256_digest_is_canonical(value : String) -> Bool {
  value.length() == 71 &&
  value.has_prefix("sha256:") &&
  value[7:]
  .iter()
  .all(fn(char) { char.is_ascii_digit() || ('a' <= char && char <= 'f') })
}

///|
/// Returns whether an evidence reference is portable and remains relative to a
/// consumer-owned workspace. Wildcard segments are allowed because manifests
/// may declare evidence output prefixes; traversal and empty segments are not.
pub fn evidence_artifact_ref_is_canonical(value : String) -> Bool {
  if value.is_empty() ||
    value.length() > 2048 ||
    value.has_prefix("/") ||
    value.contains("\\") {
    return false
  }
  let segments = value.split("/").to_array()
  !segments.is_empty() &&
  segments.all(fn(segment) {
    !segment.is_empty() && segment != "." && segment != ".."
  })
}

///|
pub fn ContentAddressedEvidenceRefV1::conformance_issues(
  self : ContentAddressedEvidenceRefV1,
) -> Array[ContractIssueV1] {
  let issues : Array[ContractIssueV1] = []
  if !evidence_artifact_ref_is_canonical(self.evidence_ref) {
    add_issue(
      issues, "evidence_ref", "must be a canonical workspace-relative artifact reference",
    )
  }
  if !sha256_digest_is_canonical(self.evidence_digest) {
    add_issue(
      issues, "evidence_digest", "must be a lowercase sha256 content identity",
    )
  }
  issues
}

///|
pub fn content_addressed_evidence_ref(
  evidence_ref : String,
  evidence_digest : String,
) -> ContentAddressedEvidenceRefV1 raise CapabilityContractError {
  let reference = { evidence_ref, evidence_digest, }
  raise_if_invalid(
    "moonsuite.content-addressed-evidence-ref.v1",
    reference.conformance_issues(),
  )
  reference
}

///|
/// Current UTC timestamp spelling used by the shared wire DTOs. Expiration
/// evaluation is intentionally left to the consumer.
pub fn wire_timestamp_is_canonical(value : String) -> Bool {
  value.length() == 20 &&
  value[4] == '-' &&
  value[7] == '-' &&
  value[10] == 'T' &&
  value[13] == ':' &&
  value[16] == ':' &&
  value[19] == 'Z' &&
  value
  .iter()
  .all(fn(char) {
    char.is_ascii_digit() ||
    char == '-' ||
    char == 'T' ||
    char == ':' ||
    char == 'Z'
  })
}
