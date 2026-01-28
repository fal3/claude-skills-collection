---
name: Gemini CLI Helper
description: Delegate large codebase analysis to Gemini CLI's 1M token context window. Use when analyzing entire codebases, comparing multiple large files, understanding project-wide patterns, or when current context is insufficient.
---

# Gemini CLI Helper

Use Gemini CLI as a complementary large-context analysis tool when the task requires analyzing more code than fits in the current context window.

## Best Practices

1. **Use non-interactive mode with `-p` flag** for single-response analysis that integrates seamlessly into automated workflows.

2. **Reference files with `@` syntax** to include specific files, directories, or glob patterns in the analysis context.

3. **Be specific with prompts** - Ask targeted questions rather than vague ones to get actionable results from Gemini's large context.

4. **Verify critical findings** - Gemini excels at broad analysis; always verify important findings before acting on them.

5. **Combine strengths** - Use Gemini for read-only analysis at scale, then use Claude for precise edits and implementation.

6. **Use glob patterns for targeted analysis** - `@**/*.swift` is more efficient than `@src/` when you only need specific file types.

7. **Break down complex analyses** - For very large codebases, analyze by module or layer rather than everything at once.

8. **Capture and parse output** - Store Gemini's response for further processing or to inform subsequent actions.

## Guidelines

### When to Delegate to Gemini CLI

- Analyzing entire codebases or projects exceeding 100KB of relevant code
- Comparing implementations across multiple large files
- Searching for patterns, anti-patterns, or security issues project-wide
- Understanding unfamiliar codebase architecture quickly
- Verifying consistency across the entire codebase
- Generating comprehensive dependency maps

### When NOT to Use Gemini CLI

- Simple file reads or searches that fit in current context
- Making actual code changes (Gemini is read-only analysis)
- Tasks requiring real-time interaction or clarification
- When you already have sufficient context loaded

### File Reference Syntax

```bash
# Single file
gemini -p "Analyze: @path/to/file.swift"

# Multiple specific files
gemini -p "Compare: @src/auth.swift @src/legacy_auth.swift"

# Entire directory (recursive)
gemini -p "Review architecture: @src/"

# Glob patterns for file types
gemini -p "Find issues in: @**/*.swift"

# Multiple globs
gemini -p "Compare tests to implementation: @Sources/**/*.swift @Tests/**/*.swift"
```

### Output Handling

```bash
# Capture output to variable
ANALYSIS=$(gemini -p "Summarize @src/")

# Save to file for later reference
gemini -p "Full audit of @src/" > analysis_report.md

# Pipe to other tools
gemini -p "List all TODOs in @**/*.swift" | grep -i "security"
```

## Examples

### Example 1: Codebase Architecture Analysis

**User Prompt:**
> Analyze this unfamiliar codebase and explain its architecture

**Expected Output:**

```bash
gemini -p "Analyze the architecture of @Sources/ and provide:
1. Main components and their responsibilities
2. How data flows through the system
3. Key design patterns used
4. Entry points and public APIs

Format as a structured summary I can use for documentation."
```

### Example 2: Security Audit at Scale

**User Prompt:**
> Check this Swift project for security vulnerabilities

**Expected Output:**

```bash
gemini -p "Perform a security audit of @**/*.swift looking for:
1. Hardcoded secrets, API keys, or credentials
2. SQL injection or NoSQL injection risks
3. Improper input validation
4. Insecure data storage patterns
5. Force unwrapping that could cause crashes
6. Improper error handling exposing internals

List each finding with file path, line context, and severity."
```

### Example 3: Test Coverage Gap Analysis

**User Prompt:**
> Find which parts of my code lack tests

**Expected Output:**

```bash
gemini -p "Compare @Sources/ with @Tests/ and identify:
1. Public functions/methods without corresponding tests
2. Edge cases that appear unhandled in tests
3. Complex logic paths that need more coverage

Prioritize by risk - which untested code is most likely to cause bugs?"
```

### Example 4: Migration Planning

**User Prompt:**
> Help me plan migrating from UIKit to SwiftUI

**Expected Output:**

```bash
gemini -p "Analyze @**/*.swift and create a UIKit to SwiftUI migration plan:
1. List all UIKit view controllers and views
2. Identify dependencies between components
3. Suggest migration order (leaf nodes first)
4. Flag components that will be complex to migrate
5. Estimate relative effort for each component

Output as a checklist I can track progress against."
```

### Example 5: Dependency and Import Analysis

**User Prompt:**
> Map out the dependencies in this project

**Expected Output:**

```bash
gemini -p "Map all import dependencies in @Sources/:
1. Create a dependency graph showing which files import which
2. Identify any circular dependencies
3. Find tightly coupled modules that should be decoupled
4. List external framework dependencies by module

Format as both a summary and detailed breakdown."
```

## Workflow Integration

### Standard Analysis Workflow

1. **Identify scope** - Determine if the task exceeds manageable context (~100KB)
2. **Formulate query** - Write a specific, actionable prompt for Gemini
3. **Execute analysis** - Run `gemini -p "..." ` with appropriate file references
4. **Parse results** - Extract actionable items from the response
5. **Verify critical items** - Spot-check important findings
6. **Act on results** - Use Claude to implement changes based on analysis

### Combining with Claude

```
User: "Refactor this large codebase to use async/await"

Workflow:
1. gemini -p "Find all completion handler patterns in @**/*.swift"
   → Get comprehensive list of locations
2. Claude reviews the list and prioritizes
3. Claude implements changes file by file with full context
4. gemini -p "Verify no completion handlers remain in @**/*.swift"
   → Confirm migration complete
```

## Notes

- Paths are relative to the current working directory when invoking Gemini
- No special flags needed for read-only analysis
- Results may need verification for complex logic or nuanced findings
- For very large projects, consider analyzing by module to get more focused results
- Gemini's 1M token context can handle approximately 700K-800K words of code
