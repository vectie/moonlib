///|
/// Parsed canonical operation identity:
/// `<product>/<tool>@<pack-version>`.
pub struct OperationRef {
  product_id : String
  tool_id : String
  pack_version : String
} derive(Debug, Eq)

///|
/// Parsed canonical schema identity:
/// `<product>/<schema>@<schema-version>`.
pub struct SchemaRef {
  product_id : String
  schema_id : String
  schema_version : String
} derive(Debug, Eq)

///|
/// Returns whether a product, tool, schema, pack, or adapter identifier uses
/// the common portable spelling.
///
/// A canonical component starts and ends with an ASCII letter or digit and may
/// contain ASCII letters, digits, `.`, `-`, and `_` between them.
pub fn identifier_component_is_canonical(value : String) -> Bool {
  if value.is_empty() || value.length() > 128 {
    return false
  }
  let chars = value.iter().to_array()
  let boundary = fn(char : Char) {
    char.is_ascii_alphabetic() || char.is_ascii_digit()
  }
  boundary(chars[0]) &&
  boundary(chars[chars.length() - 1]) &&
  chars.all(fn(char) {
    boundary(char) || char == '.' || char == '-' || char == '_'
  })
}

///|
/// Returns whether `value` is the numeric, non-zero-padded SemVer core used by
/// the current capability wire contracts.
pub fn semantic_version_is_canonical(value : String) -> Bool {
  let parts = value.split(".").to_array()
  parts.length() == 3 &&
  parts.all(fn(part) {
    !part.is_empty() &&
    part.iter().all(fn(char) { char.is_ascii_digit() }) &&
    (part == "0" || !part.has_prefix("0"))
  })
}

///|
fn canonical_identity_parts(
  value : String,
  kind : String,
) -> (String, String, String) raise CapabilityContractError {
  let owner_parts = value.split("/").to_array()
  if owner_parts.length() != 2 {
    raise InvalidReference(
      "\{kind} reference must contain exactly one '/': \{value}",
    )
  }
  let product_id = owner_parts[0].to_owned()
  let version_parts = owner_parts[1].split("@").to_array()
  if version_parts.length() != 2 {
    raise InvalidReference(
      "\{kind} reference must contain exactly one '@': \{value}",
    )
  }
  let member_id = version_parts[0].to_owned()
  let version = version_parts[1].to_owned()
  if !identifier_component_is_canonical(product_id) ||
    !identifier_component_is_canonical(member_id) ||
    !semantic_version_is_canonical(version) {
    raise InvalidReference("non-canonical \{kind} reference: \{value}")
  }
  (product_id, member_id, version)
}

///|
pub fn OperationRef::format(self : OperationRef) -> String {
  "\{self.product_id}/\{self.tool_id}@\{self.pack_version}"
}

///|
pub fn OperationRef::product_id(self : OperationRef) -> String {
  self.product_id
}

///|
pub fn OperationRef::tool_id(self : OperationRef) -> String {
  self.tool_id
}

///|
pub fn OperationRef::pack_version(self : OperationRef) -> String {
  self.pack_version
}

///|
pub fn OperationRef::is_canonical(self : OperationRef) -> Bool {
  identifier_component_is_canonical(self.product_id) &&
  identifier_component_is_canonical(self.tool_id) &&
  semantic_version_is_canonical(self.pack_version)
}

///|
/// Constructs a canonical operation reference or raises if any component is
/// not portable.
pub fn operation_ref(
  product_id : String,
  tool_id : String,
  pack_version : String,
) -> OperationRef raise CapabilityContractError {
  let reference = { product_id, tool_id, pack_version, }
  if !reference.is_canonical() {
    raise InvalidReference(
      "non-canonical operation reference: \{reference.format()}",
    )
  }
  reference
}

///|
/// Parses exactly `<product>/<tool>@<pack-version>`.
pub fn parse_operation_ref(
  value : String,
) -> OperationRef raise CapabilityContractError {
  let (product_id, tool_id, pack_version) = canonical_identity_parts(
    value, "operation",
  )
  let reference = { product_id, tool_id, pack_version, }
  if reference.format() != value {
    raise InvalidReference("non-canonical operation reference: \{value}")
  }
  reference
}

///|
pub fn operation_ref_is_canonical(value : String) -> Bool {
  try {
    let _ = parse_operation_ref(value)
    true
  } catch {
    _ => false
  }
}

///|
fn parse_operation_ref_or_none(value : String) -> OperationRef? {
  try parse_operation_ref(value) catch {
    _ => None
  } noraise {
    reference => Some(reference)
  }
}

///|
pub fn SchemaRef::format(self : SchemaRef) -> String {
  "\{self.product_id}/\{self.schema_id}@\{self.schema_version}"
}

///|
pub fn SchemaRef::product_id(self : SchemaRef) -> String {
  self.product_id
}

///|
pub fn SchemaRef::schema_id(self : SchemaRef) -> String {
  self.schema_id
}

///|
pub fn SchemaRef::schema_version(self : SchemaRef) -> String {
  self.schema_version
}

///|
pub fn SchemaRef::is_canonical(self : SchemaRef) -> Bool {
  identifier_component_is_canonical(self.product_id) &&
  identifier_component_is_canonical(self.schema_id) &&
  semantic_version_is_canonical(self.schema_version)
}

///|
/// Constructs a canonical schema reference or raises if any component is not
/// portable.
pub fn schema_ref(
  product_id : String,
  schema_id : String,
  schema_version : String,
) -> SchemaRef raise CapabilityContractError {
  let reference = { product_id, schema_id, schema_version, }
  if !reference.is_canonical() {
    raise InvalidReference(
      "non-canonical schema reference: \{reference.format()}",
    )
  }
  reference
}

///|
/// Parses exactly `<product>/<schema>@<schema-version>`.
pub fn parse_schema_ref(
  value : String,
) -> SchemaRef raise CapabilityContractError {
  let (product_id, schema_id, schema_version) = canonical_identity_parts(
    value, "schema",
  )
  let reference = { product_id, schema_id, schema_version, }
  if reference.format() != value {
    raise InvalidReference("non-canonical schema reference: \{value}")
  }
  reference
}

///|
pub fn schema_ref_is_canonical(value : String) -> Bool {
  try {
    let _ = parse_schema_ref(value)
    true
  } catch {
    _ => false
  }
}

///|
pub extend OperationRef with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend OperationRef with Eq::{not_equal, equal}

///|
pub extend SchemaRef with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend SchemaRef with Eq::{not_equal, equal}
