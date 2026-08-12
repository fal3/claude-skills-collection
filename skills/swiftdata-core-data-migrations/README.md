# SwiftData and Core Data Migrations

Use this skill to evolve Apple persistence schemas while preserving real user stores. It supports both SwiftData and Core Data and selects between them from deployment, model, migration-control, and installed-base requirements.

## Coverage

- Complete immutable `VersionedSchema` snapshots and `SchemaMigrationPlan` stages
- Correct old-schema `willMigrate` and new-schema `didMigrate` boundaries
- Core Data inferred lightweight and explicit mapping-model migrations
- Core Data/SwiftData coexistence with clear store ownership
- CloudKit rollout compatibility, rollback limits, and forward recovery
- Fresh-store, every-upgrade, and copied-production-store testing

Core Data is a supported, mature choice; this skill never treats it as obsolete. OS 27-cycle APIs are beta relative to stable Xcode 26.6 and require an explicit beta toolchain, gates, and a stable fallback.

## Contents

- [Skill guidance](SKILL.md)
- [Requirements and planning](references/decision-framework.md)
- [CloudKit, rollback, and tests](references/testing-cloudkit-rollback.md)
- [SwiftData migration example](examples/SwiftDataMigration.swift)
- [Core Data migration example](examples/CoreDataMigrationConfiguration.swift)
- [Prompt scenarios](examples/prompts.md)

## Validation expectation

Compile examples against the declared minimum SDK, then open on-disk fixture stores from every supported release. Reopen and validate the migrated store, and run a sanitized production-representative copy before shipping.
