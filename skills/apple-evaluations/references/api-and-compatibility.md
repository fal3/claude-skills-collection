# API and compatibility notes

Verified against Apple's live documentation on **2026-09-18**. These notes describe the documented Xcode 27 API, not a local compilation result. The authoring toolchain is Xcode 26.6 and cannot import Evaluations.

## Environment and isolation

Apple lists Xcode 27.0 and iOS/iPadOS/Mac Catalyst/macOS/visionOS/watchOS 27.0 for [Evaluations](https://developer.apple.com/documentation/evaluations). No tvOS availability is listed. Check the actual destination and selected developer directory; an app's minimum OS and an evaluation runner's OS are separate decisions.

Evaluations is a developer framework. In an Xcode test target, use the testing framework search paths; locate `Evaluations.framework` under the selected platform's `Developer/Library/Frameworks` if necessary. Do not embed it into the shipping application. `ENABLE_TESTING_SEARCH_PATHS = YES` may be needed in a custom development runner; confirm framework and runtime search paths in that runner rather than applying project-wide changes.

The repository's Swift example uses Swift 6 language mode. Its Evaluations declarations are annotated for OS 27. Use an OS 27 test target and Xcode 27 to compile and run it. Older SDKs cannot resolve the import, even when a declaration has an availability attribute. Keep evaluation files out of those builds and keep a separate path for ordinary fixture and scorer tests.

## Core contract

| Symbol | Relevant contract |
|---|---|
| `Evaluation` | `Sendable`; supplies `dataset`, `subject(from:)`, `evaluators`, and `aggregateMetrics(using:)` |
| `ModelSample<ExpectedValue>` | Prompt, optional reference output, optional instructions/schema, optional trajectory expectations |
| `ArrayLoader(samples:)` | In-memory samples with an explicit, auditable count |
| `ModelSubject(value:transcript:)` | Output plus optional structured conversation transcript |
| `Evaluator` | Async throwing closure receiving input and subject, returning one `Metric` |
| `Metric` | Named pass, fail, numeric score, or ignored value; `.doubleValue` is optional |
| `MetricsAggregator` | Explicitly request aggregates, such as `computeMean(of:)` |
| `.evaluates(_:info:)` | Swift Testing trait that runs the evaluation and records attachments |
| `EvaluationContext.current.result` | Read only in the corresponding evaluation test scope |
| `evaluation.run(info:)` | Direct async throwing execution, returning `EvaluationResult` |

See [Evaluation](https://developer.apple.com/documentation/evaluations/evaluation) and [the introductory walkthrough](https://developer.apple.com/documentation/evaluations/evaluating-language-model-responses). Do not infer a `run(on:)` overload from an overview snippet when the actual symbol documentation only exposes `run(info:)`.

Use explicit `Sample` and `Subject` typealiases when type inference around `Evaluators` and typed result columns is ambiguous. Keep builder entries simple and put per-sample branching inside an evaluator closure. Do not assume a result builder supports arbitrary loops or conditionals without checking the installed SDK.

For non-String output without a reference, write the generic and nil explicitly, for example `ModelSample<MyOutcome>(prompt: "…", expected: nil)`. Inspect current initializer defaults instead of assuming omission works for every generic value type.

## Run integrity before quality

The current [EvaluationResult](https://developer.apple.com/documentation/evaluations/evaluationresult) exposes `errors: EvaluationRunErrors`. The documented [run-error summary](https://developer.apple.com/documentation/evaluations/evaluationrunerrors) includes:

- `anyInferenceProduced: Bool`
- `inferenceFailureCount: Int`
- `evaluatorFailureCount: Int`
- `failingEvaluatorTypes: Set<String>`
- `metricsNotFound: [String]`
- `hasFailures: Bool`

These describe framework execution failures, not whether the generated answer is correct. An outcome wrapper can intentionally catch an inference error and return a subject; a separate outcome metric must fail that case when success was expected.

For each required metric, inspect `result.detailed[metric: metric]`. Require the fixture count to match the row count and require every expected row to contain a scored value. The framework excludes ignored metrics from aggregates. An optional-reference metric may intentionally score fewer rows, but record and assert its expected coverage explicitly.

[`aggregateValue(_:)`](https://developer.apple.com/documentation/evaluations/evaluationresult/aggregatevalue(_:)) returns `-1` when the aggregate is absent. Require a finite value within the metric's domain before applying a threshold. In particular, `-1 <= maximumError` is not a valid success condition. For a metric where -1 is legitimate, verify the summary operation and coverage directly instead of treating the numeric value alone as a missing-value test.

Older prerelease SDKs may lack the summarized error API. Inspect the exact SDK interface and per-row inference/evaluator errors when supporting one of those builds. Do not present old error-column names or old builder defects as permanent API contracts.

## Results and persistence

Use `summary` for aggregate values, `detailed` for per-sample analysis, and `groupedSummary` for presentation. Typed descriptors include `evaluation.inputColumn`, `responseColumn`, and `expectedColumn`. Add run identifiers through `info: [String: String]`; at minimum identify the dataset, prompt, and provider.

The current save signature is `saveJSON(to:includeReportMetadata:includeTranscripts:)`. The URL is an output directory and the return value is the saved file URL. `includeTranscripts` defaults to false; choose it deliberately because transcripts can contain sensitive input and tool data. Do not assume this option removes private material from all other result fields or test attachments.

Persisted results may cross SDK versions or lose type information. Test the exact save/load/typed-access round trip before implementing a comparison pipeline; use the in-memory result for assertions and Xcode's report/Compare view for initial analysis. A loaded result defaulting to a clean error summary is not evidence that an old run had full coverage.

## Sources

- [Model samples](https://developer.apple.com/documentation/evaluations/modelsample)
- [JSONLoader](https://developer.apple.com/documentation/evaluations/jsonloader)
- [Metric](https://developer.apple.com/documentation/evaluations/metric)
- [Evaluation result persistence](https://developer.apple.com/documentation/evaluations/evaluationresult)
- [Swift Testing integration](https://developer.apple.com/documentation/evaluations/evaluationtrait)
