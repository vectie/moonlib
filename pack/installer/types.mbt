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
  size : Int32
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

///|
pub extend InstallState with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend InstallState with Eq::{not_equal, equal}

///|
pub extend InstallState with ToJson::{to_json}

///|
pub extend InstallState with @moonbitlang/core/json.FromJson::{from_json}

///|
pub extend InstallPlan with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend InstallPlan with Eq::{not_equal, equal}

///|
pub extend InstallPlan with ToJson::{to_json}

///|
pub extend InstallPlan with @moonbitlang/core/json.FromJson::{from_json}

///|
pub extend HostProfile with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend HostProfile with Eq::{not_equal, equal}

///|
pub extend HostProfile with ToJson::{to_json}

///|
pub extend HostProfile with @moonbitlang/core/json.FromJson::{from_json}

///|
pub extend ArtifactReceipt with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend ArtifactReceipt with Eq::{not_equal, equal}

///|
pub extend ArtifactReceipt with ToJson::{to_json}

///|
pub extend ArtifactReceipt with @moonbitlang/core/json.FromJson::{from_json}

///|
pub extend InstallationReceipt with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend InstallationReceipt with Eq::{not_equal, equal}

///|
pub extend InstallationReceipt with ToJson::{to_json}

///|
pub extend InstallationReceipt with @moonbitlang/core/json.FromJson::{from_json}

///|
pub extend ActivePackPointer with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend ActivePackPointer with Eq::{not_equal, equal}

///|
pub extend ActivePackPointer with ToJson::{to_json}

///|
pub extend ActivePackPointer with @moonbitlang/core/json.FromJson::{from_json}

///|
pub extend InstalledVerification with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend InstalledVerification with Eq::{not_equal, equal}

///|
pub extend InstalledVerification with ToJson::{to_json}

///|
pub extend InstalledVerification with @moonbitlang/core/json.FromJson::{
  from_json,
}

///|
pub extend SourceInspection with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend SourceInspection with Eq::{not_equal, equal}

///|
pub extend SourceInspection with ToJson::{to_json}

///|
pub extend SourceInspection with @moonbitlang/core/json.FromJson::{from_json}
