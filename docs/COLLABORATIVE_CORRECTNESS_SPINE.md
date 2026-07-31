# Collaborative correctness spine

MoonLib 0.1.18 is the sole owner of the portable wire vocabulary used by the
MoonSuite collaboration loop. Products may own lifecycle policy, persistence,
and UI projections, but must not fork these reference or handover contracts.

## Shared references

The `capability` package provides opaque, validated references for principals,
workspaces, correlations, contracts, digests, schemas, operations, delegations,
authority decisions, and content-addressed evidence. JSON codecs are canonical
and decoding fails closed.

Principal kind is structural: a human, agent, and service cannot be exchanged
by changing a label. Authority decisions bind the exact principal and a bounded
validity interval. Digest references use lowercase SHA-256.

## Handover contracts

- `moonsuite.handover-bundle.v1` is an immutable portable manifest. It rejects
  secret artifacts, retains explicit exclusions, and flags untrusted documents
  or executable content for quarantine.
- `moonsuite.handover-control.v1` binds the exact bundle digest, source and
  recipient, source and target operations, typed schema compatibility,
  correlation, checkpoint, budget ceilings, return route, review requirement,
  quarantine metadata, and expiry.
- Signature metadata names `bundle-content-digest` as its signed subject and
  must contain that exact digest. Cryptographic verification remains a host
  responsibility.
- Budget cost is explicitly `max_cost_micro_usd`; no implicit currency exists.

MoonLib records requested authority but never grants it. An importing runtime
must obtain a fresh receiver-bound authority decision. Publishing MoonLib
0.1.18 is the release gate before downstream repositories can build without the
temporary multi-repository workspace.
