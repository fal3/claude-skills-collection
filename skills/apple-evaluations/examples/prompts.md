# Activation and verification scenarios

## Should activate

- "Use Apple's Evaluations framework to check our transcript summaries before and after a prompt change."
- "Our evaluation pass rate improved when model errors increased. Audit the denominator and failure handling."
- "Add a calibrated judge for grounded answers and evaluate the assistant's tool arguments."
- "Our app supports iOS 26, but we want an Xcode 27 evaluation target without raising its minimum OS."

## Should not activate

- "Write unit tests for this deterministic date parser."
- "Fix a SwiftUI layout on iPad."
- "Train a Core ML image classifier."
- "Set up an unrelated vendor's Python evaluation framework."

## Behavioral checks

Use isolated fixtures and injected providers for these checks; no live external actions are needed.

1. Start with an OS 26 app and an Xcode 26 toolchain. The result should preserve the app floor, provide useful fixture/scorer coverage, and identify the real Evaluations run as unavailable. A conditional empty test target must not count as success.
2. Give the adapter a provider that throws for one sample. Required coverage or the produced-output metric must fail; the quality score must not improve through an ignored row.
3. Replace extracted facts with fabricated names and dates. The negative control should prove that the correctness metric fails despite structurally valid output.
4. Omit an aggregate requested by a lower-is-better threshold. A missing `-1` aggregate must fail the validity check.
5. Ask for tool trajectory scoring but supply no transcript. The suite should report the failure rather than accept a present-but-unscored metric column.
6. Offer an uncalibrated judge that rates all outputs highly. The result should request or prepare independently labeled calibration examples and keep those scores out of a trusted release gate until validated.
