# Requirements and planning framework

## Contents

1. Discovery worksheet
2. Framework decision
3. Change classification
4. SwiftData planning
5. Core Data planning
6. Gradual adoption

## 1. Discovery worksheet

Answer before writing a migration:

- Which app versions are still in use, and can users skip releases?
- Which schema/model version created each fixture store?
- Is the store local, App Group-shared, CloudKit-backed, or split into configurations?
- How large is the largest representative store?
- Which entities and fields are user-authored or irreplaceable?
- What invariants must hold after migration?
- How much launch time and temporary disk space can migration consume?
- Can a server, sync engine, widget, or older app binary access data during rollout?

Produce a migration map:

| Source | Destination | Transform | Mechanism | Validation | Recovery |
|---|---|---|---|---|---|
| Field/entity | Field/entity | Copy/default/derive/delete | Lightweight/custom/intermediate | Invariant | Forward fix/restore |

## 2. Framework decision

Retain the current framework when it meets requirements. Migration between persistence frameworks is a product migration layered on top of a schema migration and should have an independent justification.

Choose SwiftData when the deployment floor supports it, the model fits its supported features, and its migration controls cover the required evolution. Choose Core Data for an existing Core Data estate, older targets, mapping-model workflows, multiple configurations, or advanced migration control.

Do not characterize Core Data as deprecated or obsolete. Apple continues to ship it, and SwiftData does not erase the operational cost of converting existing stores.

## 3. Change classification

For each field, relationship, and constraint:

- **Additive:** new optional field, compatible default, new entity.
- **Identity-preserving rename:** old persistent name maps to new source name.
- **Value transform:** type conversion, normalization, derived field, encryption format.
- **Structural transform:** entity split/merge, relationship cardinality/inverse change.
- **Constraint transform:** uniqueness or requiredness; clean invalid existing data first.
- **Removal:** determine old-client compatibility, sync implications, and whether physical removal is necessary.

Verify what the installed SDK/framework can infer. Avoid maintaining a folklore list of “always lightweight” changes.

## 4. SwiftData planning

### Snapshot discipline

- Define each released schema as its own namespace.
- Include the complete model graph in every `models` array.
- Preserve historical Swift types and annotations exactly.
- Append new versions and stages; never rewrite a released snapshot.
- Construct the production container with the newest schema and the migration plan.

### Custom stage discipline

`willMigrate` sees the source model types. Use it to validate or prepare source rows. `didMigrate` sees destination model types. Use it for destination-only validation or population that needs the new shape.

When a transform needs source values after the schema switch, introduce an intermediate version:

1. Add temporary destination-compatible fields with a lightweight hop.
2. Populate them in a custom source-side phase.
3. Move to a final schema that retains/renames the populated field and removes obsolete shape only after validation.

Test the exact multi-hop path. Do not invent cross-version casts.

## 5. Core Data planning

### Lightweight path

- Add a destination model version rather than editing the released model.
- Set renaming identifiers for identity-preserving renames.
- Ask Core Data to infer a mapping and prove it by opening a source fixture.
- Keep automatic migration flags scoped to stores for which inference is intended.

### Custom path

- Create an `.xcmappingmodel` for the exact source and destination pair.
- Use mapping expressions for direct transformations.
- Use `NSEntityMigrationPolicy` for procedural creation, association, and relationship work.
- Chain source-to-next-version migrations when direct mapping is unsupported or untested.
- Estimate temporary disk use because explicit migration normally creates a destination store.

Choose an offline mapping-model migration when the destination store cannot represent a valid partially transformed state, when an entity split/merge must create migration-manager associations, or when every reader must observe the new invariant atomically. Choose an additive lightweight hop followed by a resumable post-open backfill when both shapes can safely coexist, the transform can be idempotent and checkpointed in bounded normal-context transactions, launch-time or temporary-disk budgets rule out one blocking pass, or CloudKit must observe ordinary persistent-history changes. Keep compatibility fields and dual-read/write behavior until the backfill and mixed-client window finish. Do not use post-open backfill if the app cannot safely operate on partially converted data, and do not choose offline migration without measuring its time and destination-store disk requirements.

Quiesce the store before backup or replacement. Treat the SQLite file, WAL, and shared-memory state as one store; prefer persistent-store coordinator APIs or a closed/checkpointed store over raw file copying.

## 6. Gradual adoption

For Core Data and SwiftData coexistence:

1. Assign each entity set to exactly one persistent owner.
2. Prefer separate store URLs and configurations.
3. Bridge with stable identifiers and immutable DTOs.
4. Define one-way or two-way synchronization explicitly.
5. Make retry and duplicate handling idempotent.
6. Observe conversion progress and failures without deleting source data.
7. Keep the source readable until the destination has been verified and backed by a release rollback strategy.

If one physical store must be shared, require a separately validated compatibility design; do not infer safety from SwiftData's implementation details.
