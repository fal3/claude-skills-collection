# CloudKit, rollback, and migration testing

## Contents

1. Test fixture matrix
2. Invariants and failure tests
3. Copied production stores
4. CloudKit rollout
5. Rollback and recovery

## 1. Test fixture matrix

Keep versioned, non-sensitive on-disk fixtures. An in-memory store is useful for model logic but does not prove an on-disk migration.

| Lane | Store source | Purpose |
|---|---|---|
| Fresh | Empty URL, newest model | Verify final schema creation and seed behavior |
| Upgrade | Fixture from every supported release | Verify every migration path, including skipped releases |
| Production-like | Sanitized copied store at realistic size | Detect data-shape, scale, and performance failures |
| Synced | Development CloudKit container and multiple clients | Verify compatibility while rollout is mixed-version |

Run each on the oldest supported OS and current OS where framework behavior can differ. Reopen the migrated store using a new container to ensure success is durable rather than context-cached.

## 2. Invariants and failure tests

Capture before/after evidence:

- Entity counts and stable identifiers.
- Required and unique value constraints.
- Relationship destinations, inverses, and delete-rule outcomes.
- Aggregate totals or checksums for irreplaceable values.
- Fetches used by real application screens.
- Migration duration and peak temporary disk use.

Exercise empty stores, nil/edge values, duplicate candidates, maximum relationship fan-out, a large store, and an injected transform failure. Verify the original store remains recoverable when explicit migration fails.

Do not make “delete and recreate” the default error handler. It converts an implementation failure into user data loss.

## 3. Copied production stores

Obtain user consent and sanitize data before retaining a diagnostic store. Capture a consistent store:

- Close/quiesce writers and use framework-supported replacement/backup APIs where possible.
- Do not copy only `Store.sqlite` while data remains in `Store.sqlite-wal`.
- Preserve metadata needed to identify the source model version.
- Work on a disposable copy; hash the original and migrated artifacts for traceability.

Run the production executable's container construction, not a simplified one-off stack. Record compiler, OS, model versions, store size, command/test name, duration, and validation result.

## 4. CloudKit rollout

CloudKit adds a second compatibility surface:

- Local model migration and remote schema deployment are distinct operations.
- Production CloudKit schema changes are not a substitute for local migration code.
- Old and new clients can coexist; keep record evolution additive and readable by both during the rollout window.
- Validate SwiftData/Core Data CloudKit model restrictions for the exact SDK and store configuration.
- Test sign-in/out, initial import, remote changes during migration, and a second device still running the previous app version.
- Deploy and validate schema in the intended environment deliberately; development success does not prove production configuration.

Do not introduce a unique/required/relationship change locally and assume CloudKit accepts or enforces the same semantics. Prove it with the configured container.

## 5. Rollback and recovery

Separate four scenarios:

1. **Migration has not started:** disable rollout or feature flag safely.
2. **Local migration failed before replacement:** retain original, report, and use a fixed forward migration.
3. **Local migration succeeded but app has a regression:** an older binary may not open the new store; ship a forward-compatible hotfix or a deliberately built downgrade mapping if proven.
4. **New records/schema reached CloudKit:** restoring one local backup does not revert other clients or the remote schema; use a server/cloud forward-repair plan.

Before release, define:

- Whether backups/exports are available and protected.
- Minimum client version after the migration.
- Telemetry that distinguishes store incompatibility from ordinary load errors without collecting user content.
- A kill switch that prevents new-schema writes when feasible.
- A new migration version for repairs; never silently rewrite a migration already shipped.
