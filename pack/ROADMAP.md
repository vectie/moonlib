# Pack runtime roadmap

The v1 SDK and disk lifecycle are implemented. The remaining work belongs in
generic host integrations and operations, never in the SDK as product policy.

## Integration order

1. Merge and release the SDK before host consumers update their dependency.
2. Merge the lifecycle host, then tool, schedule, app, and metering adapters.
3. Reconcile activation projections into each live runtime registry.
4. Reconcile deactivation projections before pointer removal or version change.
5. Add restart tests proving registrations reconstruct from active pointers.

## Runtime enforcement

- Validate concrete input and output schemas at every tool invocation.
- Treat installation authority as a ceiling, not an invocation approval.
- Require effect review receipts, declared evidence destinations, timeouts,
  retry/idempotency policy, cancellation, and hard cost budgets.
- Resolve provider ports through host configuration and secret references.
- Persist invocation, effect, schedule, delivery, and cost receipts by pack,
  product, workflow, and run identity.

## Upgrade and trust

- Execute migrations in a sandbox with backup, preconditions, postconditions,
  reverse steps, and an operator acceptance receipt.
- Verify signed catalogs, publisher keys, artifact signatures, revocation, SDK
  compatibility, and content-addressed downloads before staging remote packs.
- Recover stale staging directories and retain an audit trail for every active
  pointer transition.

## Operations

- Implement backup and restore for receipts, retained versions, active
  pointers, and user-owned evidence.
- Add per-provider secret grants, quotas, rate limits, tenant isolation,
  retention, audit export, and incident runbooks.
- Add an atomic replacement backend before supporting non-POSIX hosts.

## Production exit gate

A production host must install a signed fixture into a fresh workspace, grant
limited authority, execute a supervised workflow with evidence and cost
receipts, survive restart, upgrade and roll back safely, deactivate without
data loss, and restore from backup.
