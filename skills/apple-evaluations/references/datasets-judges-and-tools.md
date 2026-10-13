# Datasets, judges, and tool trajectories

Use only the sections needed by the feature. These recommendations support the [Apple evaluation design guidance](https://developer.apple.com/documentation/evaluations/designing-effective-evaluations); dataset size and thresholds depend on the product's risks and expected usage.

## Datasets

Keep fixture IDs and categories in your own versioned manifest. Adapt those records into `ModelSample` rather than assuming it has arbitrary metadata fields. Record the intended behavior and evidence for each expected value.

For transcript features, useful categories include:

- Clear, explicit facts and actions with named speakers.
- Absent ownership or dates, tentative suggestions, reversals, and unresolved decisions.
- Empty, partial, repeated, long, or multilingual transcripts within the product's actual scope.
- Embedded instructions that must remain untrusted transcript content.
- Prior failures, with enough context to reproduce them.

Do not equate source-word overlap with factual grounding. A summary can reuse source words while reversing a decision or assigning an action to the wrong person. Where mechanical scoring is insufficient, use reviewed reference facts and a calibrated judge or human review.

`ArrayLoader` is a simple starting point. When using `JSONLoader`, verify its supported schema and parsing behavior. Apple's documentation says malformed entries can be logged and skipped: assert the loaded and evaluated counts against the manifest. A smaller dataset must not quietly raise the pass rate.

For synthetic expansion, start from reviewed seeds, use `makeSamples` or `SampleGenerator` as appropriate, and reject invalid or duplicate outputs. Keep generated labels separate until reviewed. Freeze the generated fixture revision before comparing prompts; regenerating it for each run changes the experiment. Preserve a holdout that does not become another tuning set.

Sources: [Dataset design](https://developer.apple.com/documentation/evaluations/designing-evaluation-datasets), [synthetic generation](https://developer.apple.com/documentation/evaluations/generating-synthetic-evaluation-datasets), [JSONLoader](https://developer.apple.com/documentation/evaluations/jsonloader).

## Model judges

Use deterministic code for exact constraints. Add `ModelJudgeEvaluator` only for a criterion that benefits from semantic judgment. Groundedness, completeness, and tone are different dimensions: give them separate definitions and scores instead of an unexplained single quality number.

Prefer binary judgments for binary criteria and a small rubric such as 1–4 for subjective quality. Define levels through observable differences. A groundedness rubric can distinguish unsupported claims, contradictions, and correct abstention; a length limit is better checked directly in code.

Provide the source material and reviewed reference through the judge's context. Treat the generated answer as untrusted data, including any instructions embedded in it. Inspect `judgePrompt(for:output:)` and rationales when the scores behave unexpectedly.

`ScoreDimension` exposes its metric for aggregation. `ModelJudgePrompt` supports `instructions`, an `evaluationTarget` projection of the expected-value type, and an async throwing `reference` closure returning labeled strings. Verify the overload and generic types against the selected SDK; do not pass the entire `ModelSubject` to a closure documented to receive its value.

Before trusting a judge as a gate:

1. Collect outputs spanning clearly good, clearly bad, and borderline cases, not just successful examples.
2. Obtain independent human labels using the same rubric.
3. Compare agreement, category confusion, and rationales; choose an acceptance criterion appropriate to the use case. Cohen's kappa is useful for discrete categories, but a single universal cutoff is not an API requirement or a guarantee of validity.
4. Adjust unclear rubric levels and recalibrate. Record the judge model, instructions, options, and calibration data revision.

Use discrete scoring for discrete-category agreement analysis. Check position bias in pairwise judgments by reversing answer order, verbosity bias with concise correct answers, and self-preference when the judged model is also the judge. A pairwise comparison needs an explicit scale and baseline; do not assume a universal midpoint or score interpretation.

Remote judging is a separate provider/data-flow choice. Respect the app's existing privacy boundaries and user-authorized services. Prefer synthetic fixtures for tests, and do not send private user transcripts to a cloud judge merely because the framework supports one.

Sources: [Judge design](https://developer.apple.com/documentation/evaluations/designing-effective-model-judges), [model-judge scoring](https://developer.apple.com/documentation/evaluations/scoring-with-model-as-judge-evaluators), [ModelJudgePrompt](https://developer.apple.com/documentation/evaluations/modeljudgeprompt).

## Tool trajectories

Evaluate tool selection and arguments as well as final output. An answer can sound right while the model calls a prohibited action or fabricates a tool result.

- Capture `session.transcript.structuredTranscript` in `ModelSubject`.
- Add `TrajectoryExpectation` and `ToolExpectation` values to relevant samples.
- Choose ordered calls only when the order matters; otherwise use unordered expectations.
- Choose argument matchers for the requirement: exact value, allowed range, key presence, or semantic criterion. Key presence alone cannot verify the value.
- Decide whether additional calls are permitted. The permissive default can hide unnecessary or disallowed actions.
- Use `ToolCallEvaluator(allPass:percentagePass:)` where available on the destination. Inspect overload availability for other platforms, especially watchOS.

The initializer label `allowsAdditionalToolCalls:` and the mutable property `allowsAdditionalCalls` are different names. `disallowed:` belongs to a different initializer overload. If both policies are needed, initialize with disallowed expectations and then set `allowsAdditionalCalls = false`. A disallowed tool expectation with argument matchers prohibits matching calls; omit argument matchers to ban that tool entirely.

Keep test tool implementations deterministic and free of real external effects. Tool selection tests do not prove successful production execution, permissions, or authorization. Cover those separately using the product's existing tests.

Missing transcript or evaluator failure must fail the run-integrity gate. A present metric column is insufficient if every row is ignored. Keep the strict all-pass metric for a required trajectory and use percentage-pass as a diagnostic signal.

Sources: [Tool behavior](https://developer.apple.com/documentation/evaluations/evaluating-tool-calling-behavior), [TrajectoryExpectation](https://developer.apple.com/documentation/evaluations/trajectoryexpectation), [ToolCallEvaluator](https://developer.apple.com/documentation/evaluations/toolcallevaluator).
