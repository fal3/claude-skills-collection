# Package summary

## Purpose

This package provides compatibility-first guidance for Swift 6 app architecture at an iOS/iPadOS 18 or macOS 15 baseline. It focuses on Observation ownership, actor isolation, structured concurrency, persistence correctness, navigation state, dependency seams, testing, and incremental modernization.

## Files

- `SKILL.md`: activation boundary and core rules
- `README.md`: user-facing overview
- `docs/QUICK_START.md`: application workflow
- `docs/IMPACT_COMPARISON.md`: contextual tradeoffs
- `docs/INDEX.md`: navigation
- `references/modern-patterns.md`: design reference
- `references/anti-patterns.md`: failure modes
- `references/examples.md`: example explanations
- `examples/*.swift`: standalone source examples
- `examples/prompts.md`: realistic invocation prompts

## Compatibility policy

The package does not ban Core Data, Combine/`ObservableObject`, Dispatch, operation queues, or XCTest. It explains when newer defaults fit and when supported existing technology should remain or coexist during staged migration.

## Claims policy

The package makes no guarantee about hours saved, defect percentages, coverage, production readiness, or migration success. Those outcomes require project-specific measurement, tests, deployment evidence, and review.

## Artifact policy

The checked-in directory is the package. No ZIP, generated `/mnt/user-data/outputs` artifact, executable installer, or validation certificate is part of it.
