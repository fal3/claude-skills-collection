---
name: Multi-LLM Orchestrator
description: Leverage multiple AI coding assistants (Claude Code, OpenAI Codex, Google Gemini CLI, Grok CLI) together on complex problems. Each LLM has unique strengths - orchestrate them for comprehensive analysis, diverse perspectives, and robust solutions. Use when solving complex problems that benefit from multiple perspectives, when one LLM's strengths complement another's weaknesses, for high-stakes code reviews, architecture decisions, security audits, or when consensus-building across AI systems adds value.
---

# Multi-LLM Orchestrator

Orchestrate multiple AI coding assistants to tackle complex problems from different angles, leverage each model's unique strengths, and build consensus on critical decisions.

## The Four Horsemen of AI Coding

| Tool | Context Window | Strengths | Best For |
|------|----------------|-----------|----------|
| **Claude Code** | 200K tokens | Deep reasoning, nuanced analysis, careful implementation | Complex refactoring, architecture, precise edits |
| **Gemini CLI** | 1M tokens | Massive context, broad codebase analysis | Project-wide analysis, pattern detection |
| **OpenAI Codex** | 128K tokens | Fast iteration, multimodal, GPT-5 reasoning | Quick prototyping, visual-to-code, rapid fixes |
| **Grok CLI** | 1M tokens | Speed (4,500+ tok/s), direct style, real-time data | Fast code generation, honest critiques |

## Best Practices

1. **Match model to task** - Use Gemini/Grok for broad analysis, Claude for deep reasoning, Codex for rapid iteration.

2. **Use consensus for critical decisions** - Run the same question through multiple models and synthesize answers for architecture or security decisions.

3. **Chain complementary strengths** - Gemini scans the codebase → Claude designs the solution → Codex rapidly prototypes → Grok reviews critically.

4. **Parallelize independent analyses** - Run security audit on Gemini while Claude analyzes architecture while Grok checks performance.

5. **Use disagreement productively** - When models disagree, investigate why - often reveals edge cases or trade-offs you hadn't considered.

6. **Verify across models** - Have one model verify another's output for high-stakes changes.

7. **Leverage unique capabilities** - Codex for screenshots/diagrams, Gemini for 1M context, Grok for brutally honest feedback, Claude for nuanced reasoning.

8. **Document model consensus** - When multiple models agree on an approach, that's a strong signal. When they disagree, document the trade-offs.

## CLI Quick Reference

### Claude Code
```bash
# Interactive mode
claude

# Single prompt (non-interactive)
claude -p "analyze this code for security issues"

# Continue previous conversation
claude -c

# With specific model
claude --model opus-4
```

### Gemini CLI
```bash
# Interactive mode
gemini

# Single prompt with file reference
gemini -p "analyze architecture: @src/"

# With glob patterns
gemini -p "find security issues in @**/*.swift"
```

### OpenAI Codex
```bash
# Interactive mode
codex

# Single prompt
codex -p "implement a rate limiter"

# With specific model
codex -m o3

# With image input
codex -p "convert this wireframe to SwiftUI" --image wireframe.png
```

### Grok CLI
```bash
# Interactive mode
grok

# Single prompt
grok -p "review this code brutally honestly"

# Fast code model
grok --model grok-code-fast-1 -p "optimize this function"
```

## Orchestration Patterns

### Pattern 1: Consensus Building

When making critical decisions, get multiple perspectives:

```bash
# Ask the same architecture question to all four
QUESTION="Should we use actors or locks for thread safety in this audio processing pipeline? Consider: @Sources/Audio/"

claude -p "$QUESTION" > claude_opinion.md
gemini -p "$QUESTION" > gemini_opinion.md
codex -p "$QUESTION" > codex_opinion.md
grok -p "$QUESTION" > grok_opinion.md

# Synthesize with Claude (best at nuanced analysis)
claude -p "Synthesize these four opinions on thread safety and recommend the best approach:
@claude_opinion.md @gemini_opinion.md @codex_opinion.md @grok_opinion.md"
```

### Pattern 2: Breadth-First Analysis → Depth-First Implementation

```bash
# Step 1: Gemini scans entire codebase (1M context)
gemini -p "Analyze @Sources/ and identify all places that need async/await migration" > migration_targets.md

# Step 2: Claude designs migration strategy
claude -p "Review @migration_targets.md and create a detailed migration plan with proper ordering"

# Step 3: Claude implements each change carefully
claude  # Interactive mode for careful implementation

# Step 4: Grok does brutal code review
grok -p "Review these changes critically. Be harsh. Find every issue: @Sources/"
```

### Pattern 3: Parallel Security Audit

```bash
# Run all audits in parallel (use & for background)
gemini -p "Security audit @**/*.swift for OWASP top 10" > gemini_security.md &
claude -p "Deep security analysis of authentication flow in this codebase" > claude_security.md &
grok -p "Find security vulnerabilities, be thorough and direct: @Sources/" > grok_security.md &
codex -p "Check for injection vulnerabilities and input validation issues" > codex_security.md &

wait  # Wait for all to complete

# Consolidate findings
claude -p "Consolidate these security audit findings, remove duplicates, prioritize by severity:
@gemini_security.md @claude_security.md @grok_security.md @codex_security.md"
```

### Pattern 4: Red Team / Blue Team

```bash
# Grok attacks (known for direct, unfiltered feedback)
grok -p "You are a code reviewer who hates bad code. Tear apart @Sources/PaymentProcessor.swift - find every flaw, bad pattern, and potential bug. Be ruthless." > red_team.md

# Claude defends and addresses
claude -p "Review these criticisms of PaymentProcessor.swift and:
1. Acknowledge valid concerns
2. Refute unfair criticisms with reasoning
3. Propose fixes for real issues
@red_team.md"
```

### Pattern 5: Multimodal Prototyping Pipeline

```bash
# Codex: Convert design to code (has vision capabilities)
codex -p "Convert this Figma screenshot to SwiftUI" --image design.png > prototype.swift

# Claude: Refine and add proper architecture
claude -p "Refactor this prototype to follow MVVM and add proper state management: @prototype.swift"

# Gemini: Ensure consistency with existing codebase
gemini -p "Compare @prototype.swift with @Sources/Views/ - ensure consistent styling and patterns"

# Grok: Final honest assessment
grok -p "Is this production-ready? What's missing? @prototype.swift"
```

### Pattern 6: Test Generation Ensemble

```bash
# Each model generates tests with different perspectives
claude -p "Generate comprehensive unit tests for @Sources/AuthService.swift focusing on edge cases" > claude_tests.swift
gemini -p "Generate integration tests for @Sources/AuthService.swift considering all callers in @Sources/" > gemini_tests.swift
grok -p "Generate adversarial tests that try to break @Sources/AuthService.swift" > grok_tests.swift
codex -p "Generate property-based tests for @Sources/AuthService.swift" > codex_tests.swift

# Merge into comprehensive test suite
claude -p "Combine these test files into a single comprehensive test suite, remove duplicates, organize logically:
@claude_tests.swift @gemini_tests.swift @grok_tests.swift @codex_tests.swift"
```

## Examples

### Example 1: Architecture Decision Record

**User Prompt:**
> Help me decide between Core Data and SwiftData for my new app

**Expected Output:**

```bash
# Get each model's perspective
claude -p "Compare Core Data vs SwiftData for a new iOS 18+ app. Consider: learning curve, features, migration path, community support. Be thorough."

gemini -p "Analyze @**/*.swift in popular open source iOS apps - what's the trend for Core Data vs SwiftData adoption in 2025?"

grok -p "Core Data or SwiftData for a new app in 2025? Give me your honest, direct opinion. No hedging."

codex -p "Show me example implementations of the same data model in both Core Data and SwiftData. Highlight the differences."

# Document the decision
claude -p "Create an Architecture Decision Record (ADR) synthesizing the above perspectives on Core Data vs SwiftData"
```

### Example 2: Complex Bug Investigation

**User Prompt:**
> There's a race condition somewhere causing intermittent crashes

**Expected Output:**

```bash
# Gemini: Find all concurrency code (needs large context)
gemini -p "Search @Sources/ for all concurrent code: async/await, actors, DispatchQueue, locks, atomics. List every location." > concurrency_map.md

# Claude: Deep analysis of the patterns
claude -p "Analyze these concurrency patterns for potential race conditions: @concurrency_map.md @Sources/"

# Grok: Quick identification of obvious issues
grok -p "Find race conditions in @Sources/ - look for shared mutable state, missing locks, actor isolation violations"

# Codex: Generate thread sanitizer tests
codex -p "Generate a test that would expose race conditions in the code paths identified in @concurrency_map.md"
```

### Example 3: Performance Optimization

**User Prompt:**
> The app is slow, help me find and fix bottlenecks

**Expected Output:**

```bash
# Parallel analysis with different focus areas
gemini -p "Analyze @Sources/ for performance anti-patterns: N+1 queries, unnecessary allocations, blocking main thread" > perf_issues.md &
grok -p "Find the slowest, most inefficient code in @Sources/ - what would you optimize first?" > grok_perf.md &
claude -p "Analyze the algorithmic complexity of key functions in the codebase" > complexity.md &
wait

# Synthesize and prioritize
claude -p "Create a prioritized performance optimization plan based on:
@perf_issues.md @grok_perf.md @complexity.md

Consider: impact, effort, risk. Recommend top 5 optimizations."
```

### Example 4: Code Review Ensemble

**User Prompt:**
> Review this PR thoroughly before merging to main

**Expected Output:**

```bash
# Get diverse review perspectives
git diff main..feature-branch > pr_diff.txt

claude -p "Senior engineer code review. Check architecture, maintainability, edge cases: @pr_diff.txt" > claude_review.md
gemini -p "Review @pr_diff.txt in context of the full codebase @Sources/ - any inconsistencies or patterns violated?" > gemini_review.md
grok -p "Brutal code review. What's wrong with this? @pr_diff.txt" > grok_review.md
codex -p "Check for bugs, typos, and logic errors: @pr_diff.txt" > codex_review.md

# Consolidated review
claude -p "Synthesize these code reviews into actionable feedback for the PR author:
@claude_review.md @gemini_review.md @grok_review.md @codex_review.md

Format as: Critical (must fix), Important (should fix), Minor (nice to have)"
```

## Model Selection Guide

| Task | Recommended Model(s) | Why |
|------|---------------------|-----|
| Architecture decisions | Claude + Grok | Deep reasoning + honest critique |
| Codebase-wide search | Gemini | 1M token context |
| Rapid prototyping | Codex | Fast iteration, multimodal |
| Security audit | All four | Different perspectives catch more |
| Bug investigation | Claude + Gemini | Reasoning + full context |
| Performance optimization | Grok + Gemini | Fast analysis + broad view |
| Code review | All four (ensemble) | Comprehensive coverage |
| Quick fixes | Codex or Grok | Speed |
| Complex refactoring | Claude | Careful, precise edits |
| Design-to-code | Codex | Vision capabilities |

## Notes

- All CLI tools require separate authentication/API keys
- Costs vary: Gemini has generous free tier, others require paid plans
- Context windows are model-dependent (check current limits)
- For truly critical decisions, human review should follow AI consensus
- Models can hallucinate - verify important claims, especially about external APIs or libraries
