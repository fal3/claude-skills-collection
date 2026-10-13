---
name: apple-evaluations
description: Build, review, and debug generative AI quality regression suites with Apple's Evaluations framework, including Evaluation, datasets, metrics, Swift Testing integration, calibrated model judges, and tool-call trajectories. Use when measuring an Apple-platform intelligence feature, comparing prompts or models, or diagnosing misleading evaluation results. Do not use for ordinary deterministic unit tests, UI automation, performance profiling alone, model training, or an unrelated vendor's evaluation framework.
---

# Apple Evaluations

Measure the feature users receive through its real service boundary. Define quality criteria before changing a prompt, and make missing coverage fail visibly.

## Establish compatibility first

Inspect the selected Xcode, Swift compiler, SDK, app deployment targets, test targets, and model availability. Apple's documentation lists **Xcode 27.0+ and iOS, iPadOS, Mac Catalyst, macOS, visionOS, and watchOS 27.0+** for Evaluations; it does not list tvOS. The example uses Swift 6 language mode with the compiler bundled with Xcode 27. Do not infer a standalone Swift compiler minimum from the OS number.

- Keep `import Evaluations` in a development/test target. Locate the framework in the selected Xcode's developer framework search paths if the test target cannot import it.
- An app targeting OS 26 can keep that deployment floor while a separate evaluation target runs on OS 27. Gate shared declarations with `@available(iOS 27.0, macOS 27.0, *)` as appropriate to the actual targets, and gate invocation with `if #available` where needed.
- Availability attributes do not make a missing SDK module importable. Exclude evaluation sources from the older-toolchain build, or use a deliberate `#if canImport(Evaluations)` boundary. Report that path as excluded, never as a successful evaluation.
- Preserve ordinary Swift Testing/XCTest checks of fixtures, scorers, and injected failures on older toolchains. They are useful fallback coverage, not proof of live model quality.
- An OS 27 run does not establish quality of the model used on OS 26. When models differ across supported OS releases, measure the production OS/model combinations separately with a compatible inference harness; keep those results distinct from the Evaluations runner's results.
- Separate framework availability from model readiness. Apple Intelligence settings, hardware, assets, locale, and the chosen provider may prevent inference even on a supported OS. Private Cloud Compute or another remote judge also changes data handling and execution requirements.

Read [API and compatibility notes](references/api-and-compatibility.md) for the current API surface and version-sensitive behavior. Recheck Apple documentation and the installed SDK before using an unfamiliar signature.

## Choose a bounded evaluation

Find one high-value intelligence feature, its production entry point, its model/provider selection, and its existing tests. Start with two or three meaningful metrics. Do not introduce a second implementation of the production prompt just for evaluation.

| Quality question | Measurement |
|---|---|
| Did generation return a usable result? | Produced-output and error counts |
| Did structured extraction preserve explicit source facts? | Field-level comparison against reviewed labels |
| Did it invent facts or actions? | Negative examples, evidence checks, and calibrated semantic review |
| Is an open-ended answer helpful or grounded? | Reference-guided model judge, calibrated against human labels |
| Did an agent select the right tools and arguments? | Trajectory checks alongside final-answer quality |
| Did a prompt or model change help? | Same fixtures, criteria, environment, and baseline comparison |

Exact string equality is appropriate for constrained labels and canonical fields. It is usually a poor proxy for free-form summary quality. Length, nonempty output, valid JSON, and schema conformance are guardrails, not standalone proof of correctness.

## Build reviewed datasets

Start with a small, versioned fixture set representing normal input, ambiguity, empty or truncated input, adversarial content, and known failures. Use synthetic or appropriately de-identified source material. Assign stable IDs, categories, expected behavior, and the source evidence supporting labels in the fixture format you own; do not invent extra `ModelSample` initializer arguments.

Make refusal or abstention an explicit expected outcome when appropriate. For extraction, include examples where no owner, date, decision, or action exists. Evaluate prompt-like text inside a transcript as data. Keep a holdout set separate from prompt tuning; do not silently relabel failures to improve a score.

Synthetic expansion is optional. Review generated labels and category balance before freezing the dataset. Generating labels with the same model being tested does not establish independent ground truth. See [dataset, judge, and tool guidance](references/datasets-judges-and-tools.md).

## Implement the evaluation contract

1. Conform to `Evaluation` with a `dataset`, `subject(from:)`, `evaluators`, and `aggregateMetrics(using:)`.
2. Adapt fixtures using `ModelSample` and a loader such as `ArrayLoader(samples:)`. Supply an explicit `expected:` value, including a typed `nil` when no reference is available.
3. Invoke the production service in `subject(from:)`, using injection only at genuine provider or side-effect boundaries. Return a `ModelSubject` and capture the structured session transcript when evaluating tools.
4. Declare named `Metric` values once and reuse those names in evaluators, aggregation, and assertions. Return `.passing()`, `.failing(rationale:)`, or `.scoring(_:rationale:)` from each evaluator.
5. Reserve `.ignore()` for explicitly inapplicable scoring. A failed generation, missing label on a required fixture, or evaluator failure must not silently disappear from a quality gate's denominator.
6. Represent expected user-visible failure/refusal outcomes explicitly when useful, and score them. Also inspect framework run errors to catch failures that escape your adapter. Preserve cancellation semantics.

The [transcript fact extraction example](examples/TranscriptFactsEvaluation.swift) demonstrates an injectable service boundary, coverage assertions, a live-model test, and negative controls for fabricated output and failed inference. It is a standalone teaching feature; replace its extractor with the app's actual service when integrating it.

## Make results a gate

Run with Swift Testing's `.evaluates(...)` trait or `evaluation.run(info:)`. Read `EvaluationContext.current.result` only inside the evaluation test scope. The trait records report attachments; the test body must assert the intended quality criteria.

Before trusting an aggregate, require:

- A nonempty fixture set and exactly the expected number of result rows.
- `result.errors.anyInferenceProduced`, zero inference/evaluator failures, and no `metricsNotFound` on a run intended to exercise all samples successfully.
- A scored value for every required sample/metric, or an explicit, checked coverage policy for metrics with legitimate exclusions.
- A produced-output or expected-outcome metric, since an adapter can catch a model error and return a subject without producing useful content.
- Finite aggregates in their valid domain before applying thresholds. `aggregateValue(_:)` returns **-1 when an operation is missing**; a test like `error <= 0.1` alone can accept that sentinel.

Set thresholds from the feature's requirements and baseline. Keep critical factual/privacy/tool constraints separate from average quality scores so a strong average cannot hide a serious failure. Inspect category results and per-sample rationales, not only the headline mean.

Prove that the gate detects a deliberately wrong output and a provider failure. Distinguish a negative-control harness test from live inference. Model unavailability may disable an optional local test, but it must leave explicit incomplete coverage and cannot satisfy a required release quality gate.

## Compare and report honestly

Record dataset and prompt revisions, app revision, provider/model identity, generation options, OS/SDK/device, locale, and judge configuration in run metadata or adjacent artifacts. Use greedy generation when the provider supports it and it matches the experiment; do not change production behavior just to improve test repeatability. A fixed seed or greedy mode does not promise identical results across model or OS updates.

Change one meaningful variable per experiment. Re-run the full relevant suite, examine regressions by category, and use held-out data at milestones. Keep evaluator and model changes separate so score movement has an interpretable cause.

Use the in-memory result for typed inspection and Xcode's evaluation report/Compare view for run review. Verify persistence round trips on the exact SDK before relying on reloaded typed columns. Reports and transcripts may contain private input: use safe fixtures and explicitly choose what to persist.

Hand off the fixtures, service adapter, criteria/threshold rationale, runnable target/command, and evidence. State separately what was syntax-checked, compiled, run with fakes, run with a real model, or blocked by toolchain/hardware. Do not claim evaluation quality from an empty conditional build or a skipped test.

## Resources

- [API and compatibility notes](references/api-and-compatibility.md)
- [Datasets, calibrated judges, and tool trajectories](references/datasets-judges-and-tools.md)
- [Swift evaluation example](examples/TranscriptFactsEvaluation.swift)
- [Activation and verification scenarios](examples/prompts.md)
- [Apple Evaluations documentation](https://developer.apple.com/documentation/evaluations)
