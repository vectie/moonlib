# MoonLib capability contracts

`vectie/moonlib/capability` is the policy-free wire vocabulary shared by
MoonSuite capability producers and consumers.

It provides:

- canonical operation references
  `<product>/<tool>@<pack-version>`;
- canonical schema references
  `<product>/<schema>@<schema-version>`;
- content-addressed, workspace-relative evidence references;
- minimal typed projections for MoonPack schemas/tools, adapter declaration and
  health, capability-catalog operations, adapter requests/results, and
  product-owned reconciliation receipts.

```mbt check
///|
test "canonical capability identities" {
  let operation = @capability.parse_operation_ref(
    "moonmold/spatial.operation.execute@0.2.0",
  )
  assert_eq(operation.product_id, "moonmold")
  assert_eq(operation.tool_id, "spatial.operation.execute")
  assert_eq(operation.pack_version, "0.2.0")
  assert_eq(operation.format(), "moonmold/spatial.operation.execute@0.2.0")
}
```

The package does not compile catalogs, rank claims, evaluate whether health is
fresh, authorize effects, choose retry behavior, run adapters, or know any
domain. Those decisions remain with MoonFlow, hosts, and the product-owned
adapter.

The manifest DTO is deliberately a projection, not a second Pack SDK. Use
`vectie/moonlib/pack` for full manifest installation, activation, and host
projection contracts.

See [WIRE_COMPATIBILITY.md](WIRE_COMPATIBILITY.md) before adopting the DTOs in
an existing consumer.
