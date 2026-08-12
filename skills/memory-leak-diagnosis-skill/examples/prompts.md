# Example prompts

## Should activate

- "This view model's `deinit` never runs after dismissal. Trace the ownership graph."
- "Memory rises each time I present this screen; design an Allocations generation test."
- "Explain whether this Task is a leak or only temporary retention."
- "Fix this delegate cycle and state why weak is safe here."
- "Review this unowned capture and prove whether its lifetime invariant holds."
- "Find the producer cleanup missing from this AsyncStream."
- "Distinguish a bounded image cache from an unbounded memory defect."
- "Interpret this Memory Graph root path and propose a verification run."
- "Investigate a jetsam report where Leaks reports nothing."

## Should not activate

- "Debug a use-after-free crash with no evidence of retained objects."
- "Explain stack versus heap allocation in general Swift syntax."
- "Reduce the size of a bounded cache that is behaving as designed."
