# MoonLib Pack SDK

The Pack SDK is MoonSuite’s policy-free contract for installable runtime
extensions, domain packs, and app-tool bundles.

Packages:

- `vectie/moonlib/pack`: manifest, disk codec, path rules, and validation;
- `vectie/moonlib/pack/registry`: caller-supplied in-memory catalog;
- `vectie/moonlib/pack/installer`: native staged installation, receipts,
  integrity verification, activation, rollback, and deactivation;
- `vectie/moonlib/pack/host`: generic host activation/deactivation projections.

Dependency direction is strict: domain products may import the SDK; the SDK
must never import or name a domain product. Run `pack/check-boundaries.sh` to
enforce this rule.

Installation grants no runtime dependency or authority by default. A host must
provide an explicit `HostProfile`, and it must still enforce each tool’s schema,
review requirement, evidence output, and effect authorization at invocation.

The native installer uses per-pack file locks, immutable version directories,
SHA-256 receipts, and atomic same-filesystem pointer replacement. Deactivation
removes only the active pointer; installed artifacts and user evidence remain
available for audit and rollback.
