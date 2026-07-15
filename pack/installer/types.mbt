///|
pub(all) enum InstallState {
  Rejected
  ReadyToStage
} derive(Debug, Eq, ToJson, FromJson)

///|
pub(all) struct InstallPlan {
  pack_id : String
  version : String
  state : InstallState
  validation : @pack.ValidationReport
  authorities : Array[@pack.AuthorityClass]
  owned_namespaces : Array[String]
} derive(Debug, Eq, ToJson, FromJson)

///|
pub(all) struct HostProfile {
  contract : String
  runtime_extensions : Array[String]
  granted_authorities : Array[@pack.AuthorityClass]
} derive(Debug, Eq, ToJson, FromJson)

///|
pub(all) struct ArtifactReceipt {
  path : String
  sha256 : String
  size : Int
} derive(Debug, Eq, ToJson, FromJson)

///|
pub(all) struct InstallationReceipt {
  contract : String
  pack_id : String
  product_id : String
  version : String
  manifest_sha256 : String
  installed_root : String
  artifacts : Array[ArtifactReceipt]
  authorities : Array[@pack.AuthorityClass]
} derive(Debug, Eq, ToJson, FromJson)

///|
pub(all) struct ActivePackPointer {
  contract : String
  pack_id : String
  version : String
  manifest_sha256 : String
  installed_root : String
} derive(Debug, Eq, ToJson, FromJson)

///|
pub(all) struct InstalledVerification {
  ok : Bool
  pack_id : String
  version : String
  issues : Array[String]
} derive(Debug, Eq, ToJson, FromJson)

///|
pub(all) struct SourceInspection {
  manifest : @pack.MoonPackManifest
  plan : InstallPlan
  issues : Array[String]
} derive(Debug, Eq, ToJson, FromJson)
