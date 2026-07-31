///|
/// Policy-free projection of one schema entry from a MoonPack manifest.
pub(all) struct PackSchemaProjectionV1 {
  id : String
  version : String
  path : String
} derive(Debug, Eq, ToJson, FromJson)

///|
/// Policy-free projection of one tool entry from a MoonPack manifest.
pub(all) struct PackOperationProjectionV1 {
  id : String
  owner_product : String
  input_schema_id : String
  output_schema_id : String
  authority : String
  idempotent : Bool
  evidence_outputs : Array[String]
  review_required : Bool
} derive(Debug, Eq, ToJson, FromJson)

///|
/// The manifest fields needed to exchange capability identity. Installation,
/// trust, activation, and authority policy remain in the Pack SDK and hosts.
pub(all) struct PackManifestProjectionV1 {
  id : String
  product_id : String
  version : String
  schemas : Array[PackSchemaProjectionV1]
  tools : Array[PackOperationProjectionV1]
} derive(Debug, Eq, ToJson, FromJson)

///|
pub fn PackManifestProjectionV1::conformance_issues(
  self : PackManifestProjectionV1,
) -> Array[ContractIssueV1] {
  let issues : Array[ContractIssueV1] = []
  if !identifier_component_is_canonical(self.id) {
    add_issue(issues, "id", "must be a canonical identifier")
  }
  if !identifier_component_is_canonical(self.product_id) {
    add_issue(issues, "product_id", "must be a canonical identifier")
  }
  if !semantic_version_is_canonical(self.version) {
    add_issue(issues, "version", "must be a canonical semantic version")
  }
  let schema_ids : Array[String] = []
  for index, schema in self.schemas {
    let prefix = "schemas[\{index}]"
    if !identifier_component_is_canonical(schema.id) {
      add_issue(issues, prefix + ".id", "must be a canonical identifier")
    }
    if !semantic_version_is_canonical(schema.version) {
      add_issue(
        issues,
        prefix + ".version",
        "must be a canonical semantic version",
      )
    }
    if !evidence_artifact_ref_is_canonical(schema.path) {
      add_issue(
        issues,
        prefix + ".path",
        "must be a canonical pack-relative artifact reference",
      )
    }
    schema_ids.push(schema.id)
  }
  if has_duplicate(schema_ids) {
    add_issue(issues, "schemas", "schema ids must be unique")
  }
  let tool_ids : Array[String] = []
  for index, tool in self.tools {
    let prefix = "tools[\{index}]"
    if !identifier_component_is_canonical(tool.id) {
      add_issue(issues, prefix + ".id", "must be a canonical identifier")
    }
    if !identifier_component_is_canonical(tool.owner_product) {
      add_issue(
        issues,
        prefix + ".owner_product",
        "must be a canonical identifier",
      )
    }
    if tool.owner_product != self.product_id {
      add_issue(
        issues,
        prefix + ".owner_product",
        "must equal the projected product_id",
      )
    }
    if !schema_ids.contains(tool.input_schema_id) {
      add_issue(
        issues,
        prefix + ".input_schema_id",
        "must name a projected schema",
      )
    }
    if !schema_ids.contains(tool.output_schema_id) {
      add_issue(
        issues,
        prefix + ".output_schema_id",
        "must name a projected schema",
      )
    }
    add_required_issue(issues, prefix + ".authority", tool.authority)
    for output_index, output in tool.evidence_outputs {
      if !evidence_artifact_ref_is_canonical(output) {
        add_issue(
          issues,
          prefix + ".evidence_outputs[\{output_index}]",
          "must be a canonical pack-relative artifact reference",
        )
      }
    }
    if has_duplicate(tool.evidence_outputs) {
      add_issue(
        issues,
        prefix + ".evidence_outputs",
        "artifact references must be unique",
      )
    }
    tool_ids.push(tool.id)
  }
  if has_duplicate(tool_ids) {
    add_issue(issues, "tools", "tool ids must be unique")
  }
  issues
}

///|
pub fn decode_pack_manifest_projection_v1(
  value : Json,
) -> PackManifestProjectionV1 raise CapabilityContractError {
  let projection : PackManifestProjectionV1 = decode_wire(
    value, "moonsuite.pack-manifest-projection.v1",
  )
  raise_if_invalid(
    "moonsuite.pack-manifest-projection.v1",
    projection.conformance_issues(),
  )
  projection
}

///|
pub fn encode_pack_manifest_projection_v1(
  projection : PackManifestProjectionV1,
) -> Json raise CapabilityContractError {
  raise_if_invalid(
    "moonsuite.pack-manifest-projection.v1",
    projection.conformance_issues(),
  )
  projection.to_json()
}
