///|
/// One policy-free wire-conformance finding.
///
/// `field` is a stable field path relative to the value being checked. The
/// package deliberately does not attach severity or a remediation decision:
/// those belong to the consuming compiler or runtime.
pub(all) struct ContractIssueV1 {
  field : String
  message : String
} derive(Debug, Eq, ToJson, FromJson)

///|
/// Errors raised while parsing a canonical reference or decoding a typed wire
/// contract.
pub(all) suberror CapabilityContractError {
  InvalidReference(String)
  InvalidWireContract(String, Array[ContractIssueV1])
} derive(Debug, Eq)

///|
fn add_issue(
  issues : Array[ContractIssueV1],
  field : String,
  message : String,
) -> Unit {
  issues.push({ field, message })
}

///|
fn add_required_issue(
  issues : Array[ContractIssueV1],
  field : String,
  value : String,
) -> Unit {
  if value.trim().is_empty() {
    add_issue(issues, field, "must not be empty")
  }
}

///|
fn append_issues(
  target : Array[ContractIssueV1],
  prefix : String,
  source : Array[ContractIssueV1],
) -> Unit {
  for issue in source {
    let field = if issue.field.is_empty() {
      prefix
    } else {
      prefix + "." + issue.field
    }
    target.push({ field, message: issue.message })
  }
}

///|
fn raise_if_invalid(
  contract : String,
  issues : Array[ContractIssueV1],
) -> Unit raise CapabilityContractError {
  if !issues.is_empty() {
    raise InvalidWireContract(contract, issues)
  }
}

///|
fn has_duplicate(values : Array[String]) -> Bool {
  for i in 0..<values.length() {
    for j in (i + 1)..<values.length() {
      if values[i] == values[j] {
        return true
      }
    }
  }
  false
}

///|
fn[T : @json.FromJson] decode_wire(
  value : Json,
  contract : String,
) -> T raise CapabilityContractError {
  @json.from_json(value) catch {
    error =>
      raise InvalidWireContract(contract, [
        { field: "", message: "invalid JSON shape: \{error}" },
      ])
  }
}
