///|
pub fn adapter_declaration_contract_v1() -> String {
  "moonflow.adapter-declaration.v1"
}

///|
pub fn adapter_health_contract_v1() -> String {
  "moonflow.adapter-health.v1"
}

///|
pub fn capability_catalog_contract_v1() -> String {
  "moonflow.capability-catalog.v1"
}

///|
pub(all) struct AdapterOperationDeclarationV1 {
  operation_id : String
  claim_ceiling : String
  supports_cancel : Bool
  supports_reconcile : Bool
} derive(Debug, Eq, ToJson, FromJson)

///|
pub(all) struct AdapterDeclarationV1 {
  contract_id : String
  adapter_id : String
  product_id : String
  pack_id : String
  pack_version : String
  protocol : String
  operations : Array[AdapterOperationDeclarationV1]
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn AdapterDeclarationV1::conformance_issues(
  self : AdapterDeclarationV1,
) -> Array[ContractIssueV1] {
  let issues : Array[ContractIssueV1] = []
  if self.contract_id != adapter_declaration_contract_v1() {
    add_issue(
      issues,
      "contract_id",
      "must equal \{adapter_declaration_contract_v1()}",
    )
  }
  for
    pair in [
      ("adapter_id", self.adapter_id),
      ("product_id", self.product_id),
      ("pack_id", self.pack_id),
    ] {
    let (field, value) = pair
    if !identifier_component_is_canonical(value) {
      add_issue(issues, field, "must be a canonical identifier")
    }
  }
  if !semantic_version_is_canonical(self.pack_version) {
    add_issue(issues, "pack_version", "must be a canonical semantic version")
  }
  add_required_issue(issues, "protocol", self.protocol)
  let operation_ids : Array[String] = []
  for index, operation in self.operations {
    let prefix = "operations[\{index}]"
    if !identifier_component_is_canonical(operation.operation_id) {
      add_issue(
        issues,
        prefix + ".operation_id",
        "must be a canonical identifier",
      )
    }
    add_required_issue(
      issues,
      prefix + ".claim_ceiling",
      operation.claim_ceiling,
    )
    operation_ids.push(operation.operation_id)
  }
  if has_duplicate(operation_ids) {
    add_issue(issues, "operations", "operation ids must be unique")
  }
  issues
}

///|
pub fn decode_adapter_declaration_v1(
  value : Json,
) -> AdapterDeclarationV1 raise CapabilityContractError {
  let declaration : AdapterDeclarationV1 = decode_wire(
    value,
    adapter_declaration_contract_v1(),
  )
  raise_if_invalid(
    adapter_declaration_contract_v1(),
    declaration.conformance_issues(),
  )
  declaration
}

///|
pub fn encode_adapter_declaration_v1(
  declaration : AdapterDeclarationV1,
) -> Json raise CapabilityContractError {
  raise_if_invalid(
    adapter_declaration_contract_v1(),
    declaration.conformance_issues(),
  )
  declaration.to_json()
}

///|
/// Expiring health evidence exchanged by product-owned adapters. The DTO
/// records timestamps and evidence identity; it deliberately does not decide
/// whether the attestation is currently usable.
pub(all) struct AdapterHealthV1 {
  contract_id : String
  adapter_id : String
  product_id : String
  pack_id : String
  pack_version : String
  protocol : String
  status : String
  checked_at : String
  valid_until : String
  operation_refs : Array[String]
  evidence_ref : String
  evidence_digest : String
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn AdapterHealthV1::evidence(
  self : AdapterHealthV1,
) -> ContentAddressedEvidenceRefV1 {
  { evidence_ref: self.evidence_ref, evidence_digest: self.evidence_digest, }
}

///|
pub fn AdapterHealthV1::conformance_issues(
  self : AdapterHealthV1,
) -> Array[ContractIssueV1] {
  let issues : Array[ContractIssueV1] = []
  if self.contract_id != adapter_health_contract_v1() {
    add_issue(
      issues,
      "contract_id",
      "must equal \{adapter_health_contract_v1()}",
    )
  }
  for
    pair in [
      ("adapter_id", self.adapter_id),
      ("product_id", self.product_id),
      ("pack_id", self.pack_id),
    ] {
    let (field, value) = pair
    if !identifier_component_is_canonical(value) {
      add_issue(issues, field, "must be a canonical identifier")
    }
  }
  if !semantic_version_is_canonical(self.pack_version) {
    add_issue(issues, "pack_version", "must be a canonical semantic version")
  }
  add_required_issue(issues, "protocol", self.protocol)
  add_required_issue(issues, "status", self.status)
  if !wire_timestamp_is_canonical(self.checked_at) {
    add_issue(issues, "checked_at", "must be a canonical UTC timestamp")
  }
  if !wire_timestamp_is_canonical(self.valid_until) {
    add_issue(issues, "valid_until", "must be a canonical UTC timestamp")
  }
  if wire_timestamp_is_canonical(self.checked_at) &&
    wire_timestamp_is_canonical(self.valid_until) &&
    self.valid_until < self.checked_at {
    add_issue(issues, "valid_until", "must not precede checked_at")
  }
  for index, value in self.operation_refs {
    match parse_operation_ref_or_none(value) {
      Some(reference) => {
        if reference.product_id != self.product_id {
          add_issue(
            issues,
            "operation_refs[\{index}]",
            "product must match product_id",
          )
        }
        if reference.pack_version != self.pack_version {
          add_issue(
            issues,
            "operation_refs[\{index}]",
            "version must match pack_version",
          )
        }
      }
      None =>
        add_issue(
          issues,
          "operation_refs[\{index}]",
          "must be a canonical operation reference",
        )
    }
  }
  if has_duplicate(self.operation_refs) {
    add_issue(issues, "operation_refs", "references must be unique")
  }
  append_issues(issues, "evidence", self.evidence().conformance_issues())
  issues
}

///|
pub fn decode_adapter_health_v1(
  value : Json,
) -> AdapterHealthV1 raise CapabilityContractError {
  let health : AdapterHealthV1 = decode_wire(
    value,
    adapter_health_contract_v1(),
  )
  raise_if_invalid(adapter_health_contract_v1(), health.conformance_issues())
  health
}

///|
pub fn encode_adapter_health_v1(
  health : AdapterHealthV1,
) -> Json raise CapabilityContractError {
  raise_if_invalid(adapter_health_contract_v1(), health.conformance_issues())
  health.to_json()
}

///|
pub(all) struct CatalogProductProjectionV1 {
  product_id : String
  pack_id : String
  pack_version : String
} derive(Debug, Eq, ToJson, FromJson)

///|
/// One operation projected by a capability catalog. Claim and authority values
/// remain opaque strings: this package does not rank or authorize either.
pub(all) struct CatalogOperationProjectionV1 {
  operation_ref : String
  product_id : String
  pack_id : String
  pack_version : String
  tool_id : String
  adapter_id : String
  protocol : String
  authority : String
  input_schema_ref : String
  output_schema_ref : String
  claim_ceiling : String
  idempotent : Bool
  review_required : Bool
  supports_cancel : Bool
  supports_reconcile : Bool
  health_checked_at : String
  health_valid_until : String
  health_evidence_ref : String
  health_evidence_digest : String
} derive(Debug, Eq, ToJson, FromJson)

///|
pub(all) struct CatalogIssueProjectionV1 {
  code : String
  subject : String
  detail : String
  suggestions : Array[String]
} derive(Debug, Eq, ToJson, FromJson)

///|
pub(all) struct CapabilityCatalogProjectionV1 {
  contract_id : String
  catalog_id : String
  compiled_at : String
  conformant : Bool
  products : Array[CatalogProductProjectionV1]
  operations : Array[CatalogOperationProjectionV1]
  issues : Array[CatalogIssueProjectionV1]
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn CatalogOperationProjectionV1::health_evidence(
  self : CatalogOperationProjectionV1,
) -> ContentAddressedEvidenceRefV1 {
  {
    evidence_ref: self.health_evidence_ref,
    evidence_digest: self.health_evidence_digest,
  }
}

///|
pub fn CatalogOperationProjectionV1::conformance_issues(
  self : CatalogOperationProjectionV1,
) -> Array[ContractIssueV1] {
  let issues : Array[ContractIssueV1] = []
  for
    pair in [
      ("product_id", self.product_id),
      ("pack_id", self.pack_id),
      ("tool_id", self.tool_id),
      ("adapter_id", self.adapter_id),
    ] {
    let (field, value) = pair
    if !identifier_component_is_canonical(value) {
      add_issue(issues, field, "must be a canonical identifier")
    }
  }
  if !semantic_version_is_canonical(self.pack_version) {
    add_issue(issues, "pack_version", "must be a canonical semantic version")
  }
  match parse_operation_ref_or_none(self.operation_ref) {
    Some(reference) => {
      if reference.product_id != self.product_id {
        add_issue(issues, "operation_ref", "product must match product_id")
      }
      if reference.tool_id != self.tool_id {
        add_issue(issues, "operation_ref", "tool must match tool_id")
      }
      if reference.pack_version != self.pack_version {
        add_issue(issues, "operation_ref", "version must match pack_version")
      }
    }
    None =>
      add_issue(
        issues, "operation_ref", "must be a canonical operation reference",
      )
  }
  if !schema_ref_is_canonical(self.input_schema_ref) {
    add_issue(
      issues, "input_schema_ref", "must be a canonical schema reference",
    )
  }
  if !schema_ref_is_canonical(self.output_schema_ref) {
    add_issue(
      issues, "output_schema_ref", "must be a canonical schema reference",
    )
  }
  for
    pair in [
      ("protocol", self.protocol),
      ("authority", self.authority),
      ("claim_ceiling", self.claim_ceiling),
    ] {
    let (field, value) = pair
    add_required_issue(issues, field, value)
  }
  if !wire_timestamp_is_canonical(self.health_checked_at) {
    add_issue(issues, "health_checked_at", "must be a canonical UTC timestamp")
  }
  if !wire_timestamp_is_canonical(self.health_valid_until) {
    add_issue(issues, "health_valid_until", "must be a canonical UTC timestamp")
  }
  append_issues(
    issues,
    "health_evidence",
    self.health_evidence().conformance_issues(),
  )
  issues
}

///|
pub fn CapabilityCatalogProjectionV1::conformance_issues(
  self : CapabilityCatalogProjectionV1,
) -> Array[ContractIssueV1] {
  let issues : Array[ContractIssueV1] = []
  if self.contract_id != capability_catalog_contract_v1() {
    add_issue(
      issues,
      "contract_id",
      "must equal \{capability_catalog_contract_v1()}",
    )
  }
  add_required_issue(issues, "catalog_id", self.catalog_id)
  if !wire_timestamp_is_canonical(self.compiled_at) {
    add_issue(issues, "compiled_at", "must be a canonical UTC timestamp")
  }
  for index, product in self.products {
    let prefix = "products[\{index}]"
    for
      pair in [("product_id", product.product_id), ("pack_id", product.pack_id)] {
      let (field, value) = pair
      if !identifier_component_is_canonical(value) {
        add_issue(
          issues,
          prefix + "." + field,
          "must be a canonical identifier",
        )
      }
    }
    if !semantic_version_is_canonical(product.pack_version) {
      add_issue(
        issues,
        prefix + ".pack_version",
        "must be a canonical semantic version",
      )
    }
  }
  for index, operation in self.operations {
    append_issues(
      issues,
      "operations[\{index}]",
      operation.conformance_issues(),
    )
  }
  for index, issue in self.issues {
    let prefix = "issues[\{index}]"
    add_required_issue(issues, prefix + ".code", issue.code)
    add_required_issue(issues, prefix + ".subject", issue.subject)
    add_required_issue(issues, prefix + ".detail", issue.detail)
  }
  if has_duplicate(self.operations.map(fn(item) { item.operation_ref })) {
    add_issue(issues, "operations", "operation references must be unique")
  }
  issues
}

///|
pub fn decode_capability_catalog_projection_v1(
  value : Json,
) -> CapabilityCatalogProjectionV1 raise CapabilityContractError {
  let catalog : CapabilityCatalogProjectionV1 = decode_wire(
    value,
    capability_catalog_contract_v1(),
  )
  raise_if_invalid(
    capability_catalog_contract_v1(),
    catalog.conformance_issues(),
  )
  catalog
}

///|
pub fn encode_capability_catalog_projection_v1(
  catalog : CapabilityCatalogProjectionV1,
) -> Json raise CapabilityContractError {
  raise_if_invalid(
    capability_catalog_contract_v1(),
    catalog.conformance_issues(),
  )
  catalog.to_json()
}
