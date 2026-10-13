# Apple Evaluations

Build measurable regression coverage for generative features using Apple's Evaluations framework. This skill covers dataset design, production-service adapters, metrics, Swift Testing gates, calibrated model judges, and agent tool trajectories.

Requires **Xcode 27 and an OS 27 evaluation runtime**. Applications can retain older deployment targets by isolating the evaluation target. The examples use Swift 6 language mode with Xcode 27's compiler. Ordinary unit tests remain the fallback on older SDKs.

## Contents

- [Skill instructions](SKILL.md)
- [API and compatibility notes](references/api-and-compatibility.md)
- [Datasets, judges, and tools](references/datasets-judges-and-tools.md)
- [Transcript fact extraction example](examples/TranscriptFactsEvaluation.swift)
- [Example requests and verification scenarios](examples/prompts.md)

The iOS/macOS Swift example includes a small live Foundation Models extractor and two negative controls. Its exact field comparisons suit constrained extraction; use other criteria for free-form summaries. Integration should call the app's real service instead of copying this teaching extractor into an independent test-only prompt. The example excludes other platforms; framework availability alone does not establish availability of the default on-device model.

## Validation status

API references were checked against Apple's live documentation on 2026-09-18. The authoring machine has Xcode 26.6 (Swift 6.3.3), which has no Evaluations module. The example is syntax-checked here; compilation and execution of the Evaluations path require Xcode 27 and remain unverified. The repository checker reports that distinction explicitly.

With an appropriate Xcode selected, run `REQUIRE_EVALUATIONS=1 bash scripts/typecheck_examples.sh` from the repository root. The environment flag makes a missing Evaluations SDK fail validation instead of accepting syntax-only coverage. To execute the example, add it to an OS 27 Swift Testing target with developer framework search paths enabled, and run that target on a model-capable destination. Keep the live test distinct from the negative controls when recording results.

See [repository installation guidance](../../docs/agent-compatibility.md) for supported hosts and installation. No host-specific tooling is required by the skill itself.
