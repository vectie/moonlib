///|
fn add_issue(
  issues : Array[ValidationIssue],
  path : String,
  message : String,
) -> Unit {
  issues.push({ path, message })
}

///|
fn validate_contract(
  contract : ContractRef,
  path : String,
  issues : Array[ValidationIssue],
) -> Unit {
  if !safe_identifier(contract.id) {
    add_issue(issues, path + ".id", "must be a safe identifier")
  }
  if contract.version.trim().is_empty() {
    add_issue(issues, path + ".version", "must not be empty")
  }
  if !safe_artifact_path(contract.path) {
    add_issue(issues, path + ".path", "must remain inside the pack root")
  }
}

///|
fn validate_unique_contracts(
  contracts : Array[ContractRef],
  section : String,
  issues : Array[ValidationIssue],
) -> Unit {
  for i in 0..<contracts.length() {
    validate_contract(contracts[i], section + "[" + i.to_string() + "]", issues)
    for j in (i + 1)..<contracts.length() {
      if contracts[i].id == contracts[j].id {
        add_issue(issues, section, "duplicate id: " + contracts[i].id)
      }
    }
  }
}

///|
fn schema_declared(manifest : MoonPackManifest, id : String) -> Bool {
  manifest.schemas.any(fn(schema) { schema.id == id })
}

///|
fn workflow_declared(manifest : MoonPackManifest, id : String) -> Bool {
  manifest.workflows.any(fn(workflow) { workflow.id == id })
}

///|
pub fn validate_manifest(manifest : MoonPackManifest) -> ValidationReport {
  let issues : Array[ValidationIssue] = []
  if !safe_identifier(manifest.id) {
    add_issue(issues, "id", "must be a safe identifier")
  }
  if manifest.version.trim().is_empty() {
    add_issue(issues, "version", "must not be empty")
  }
  if manifest.display_name.trim().is_empty() {
    add_issue(issues, "display_name", "must not be empty")
  }
  if !safe_identifier(manifest.product_id) {
    add_issue(issues, "product_id", "must be a safe identifier")
  }
  for i in 0..<manifest.required_runtime_extensions.length() {
    let extension = manifest.required_runtime_extensions[i]
    if !safe_identifier(extension) {
      add_issue(
        issues,
        "required_runtime_extensions",
        "unsafe id: " + extension,
      )
    }
    for j in (i + 1)..<manifest.required_runtime_extensions.length() {
      if extension == manifest.required_runtime_extensions[j] {
        add_issue(
          issues,
          "required_runtime_extensions",
          "duplicate id: " + extension,
        )
      }
    }
  }
  validate_unique_contracts(manifest.book_templates, "book_templates", issues)
  validate_unique_contracts(manifest.schemas, "schemas", issues)
  validate_unique_contracts(manifest.workflows, "workflows", issues)
  validate_unique_contracts(manifest.skills, "skills", issues)
  validate_unique_contracts(manifest.policies, "policies", issues)
  validate_unique_contracts(manifest.provider_ports, "provider_ports", issues)
  validate_unique_contracts(manifest.migrations, "migrations", issues)
  validate_unique_contracts(manifest.evaluations, "evaluations", issues)
  let artifacts = artifact_contracts(manifest)
  for i in 0..<artifacts.length() {
    for j in (i + 1)..<artifacts.length() {
      if artifacts[i].path == artifacts[j].path {
        add_issue(issues, "artifacts", "duplicate path: " + artifacts[i].path)
      }
    }
  }
  for i in 0..<manifest.tools.length() {
    let tool = manifest.tools[i]
    if !safe_identifier(tool.id) {
      add_issue(issues, "tools.id", "must be a safe identifier")
    }
    if tool.owner_product != manifest.product_id {
      add_issue(issues, "tools." + tool.id, "owner must match product_id")
    }
    if !schema_declared(manifest, tool.input_schema_id) {
      add_issue(issues, "tools." + tool.id, "input schema is not declared")
    }
    if !schema_declared(manifest, tool.output_schema_id) {
      add_issue(issues, "tools." + tool.id, "output schema is not declared")
    }
    if (tool.authority == ExternalEffect || tool.authority == PhysicalEffect) &&
      !tool.review_required {
      add_issue(issues, "tools." + tool.id, "effects require review")
    }
    if (tool.authority == ExternalEffect || tool.authority == PhysicalEffect) &&
      tool.evidence_outputs.is_empty() {
      add_issue(issues, "tools." + tool.id, "effects require evidence outputs")
    }
    for output in tool.evidence_outputs {
      if !safe_artifact_path(output) {
        add_issue(issues, "tools." + tool.id, "unsafe evidence output")
      }
    }
    for j in (i + 1)..<manifest.tools.length() {
      if tool.id == manifest.tools[j].id {
        add_issue(issues, "tools", "duplicate id: " + tool.id)
      }
    }
  }
  for i in 0..<manifest.schedules.length() {
    let schedule = manifest.schedules[i]
    if !safe_identifier(schedule.id) ||
      schedule.cadence.trim().is_empty() ||
      schedule.timezone.trim().is_empty() {
      add_issue(
        issues, "schedules", "safe id, cadence, and timezone are required",
      )
    }
    if !workflow_declared(manifest, schedule.workflow_id) {
      add_issue(issues, "schedules." + schedule.id, "workflow is not declared")
    }
    for j in (i + 1)..<manifest.schedules.length() {
      if schedule.id == manifest.schedules[j].id {
        add_issue(issues, "schedules", "duplicate id: " + schedule.id)
      }
    }
  }
  for i in 0..<manifest.app_entrypoints.length() {
    let entrypoint = manifest.app_entrypoints[i]
    if !safe_identifier(entrypoint.id) ||
      entrypoint.path.trim().is_empty() ||
      entrypoint.audience.trim().is_empty() {
      add_issue(
        issues, "app_entrypoints", "safe id, path, and audience are required",
      )
    }
    for j in (i + 1)..<manifest.app_entrypoints.length() {
      if entrypoint.id == manifest.app_entrypoints[j].id {
        add_issue(issues, "app_entrypoints", "duplicate id: " + entrypoint.id)
      }
    }
  }
  match manifest.uninstall_contract {
    None => add_issue(issues, "uninstall_contract", "must be declared")
    Some(contract) => validate_contract(contract, "uninstall_contract", issues)
  }
  { ok: issues.is_empty(), issues }
}

///|
pub fn has_authority(
  manifest : MoonPackManifest,
  authority : AuthorityClass,
) -> Bool {
  manifest.tools.any(fn(tool) { tool.authority == authority })
}
