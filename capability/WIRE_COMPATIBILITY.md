# Capability wire compatibility

Status: additive v1 package
Reviewed: 2026-07-31

## Contract ownership

| DTO | Serialized identity | Compatibility rule |
| --- | --- | --- |
| `OperationRef` | `<product>/<tool>@<pack-version>` | exact canonical parse and format |
| `SchemaRef` | `<product>/<schema>@<schema-version>` | exact canonical parse and format |
| `PackManifestProjectionV1` | no new manifest contract id | reads only the existing schema/tool projection; the Pack SDK owns the full manifest |
| `AdapterDeclarationV1` | `moonflow.adapter-declaration.v1` | exact existing fields |
| `AdapterHealthV1` | `moonflow.adapter-health.v1` | records expiry and content evidence; consumers decide freshness and usability |
| `CapabilityCatalogProjectionV1` | `moonflow.capability-catalog.v1` | DTO only; MoonFlow owns compilation and conformance decisions |
| `AdapterRequestWireV1` | none | `V1` versions this MoonLib DTO, not the MoonFlow adapter protocol; the wire has no `contract_id` |
| `AdapterResultV1` | `moonflow.adapter-result.v1` | preserves the existing stable result shape |
| `AdapterReconcileReceiptV1` | product-owned `contract_id` | common projection only; MoonLib does not invent a universal reconciliation contract |

`moonflow.adapter.v2` is an adapter protocol value carried opaquely by
declarations, health, and catalogs. It is not used to rename the request or
result wire contracts.

## Evolution

- Adding an optional consumer-local field does not require changing this
  package when the projection can ignore it.
- Adding a required shared field or changing a field meaning requires a new DTO
  version.
- Changing canonical reference syntax requires a new reference type; current
  parsers remain exact.
- Authority strings, claim strings, status strings, reconciliation decisions,
  and protocol values remain opaque. Their enum sets and ordering belong to
  consumers.
- Expiration is recorded as `checked_at` and `valid_until`. MoonLib checks only
  timestamp shape and non-inverted bounds; it never compares them with a
  clock.

The request projection matches the current product-adapter request fields. A
consumer of an older partial fixture must use an explicit compatibility
adapter rather than silently filling missing durable identities.

## Adoption sequence

Consumers should first prove their existing JSON round-trips through this
package, then replace private duplicate DTOs without changing runtime policy.
Catalog compilers, registries, and executors should remain in their owning
products.
