# CLAUDE.md

This file provides guidance to Claude Code when working with this repository.

## Repository Overview

A **Claude Skills Collection** focused on Swift and iOS development. Each skill is a self-contained directory with structured documentation and examples.

## Repository Structure

```
skills/
└── <skill-name>/
    ├── SKILL.md              # Skill definition with frontmatter and instructions
    ├── examples/
    │   └── *.swift           # Working code examples
    └── references/           # Optional deep-dive guides
```

### Available Skills

1. **swiftui-programming-skill** - SwiftUI declarative UI, SF Symbols, state management
2. **swift-modern-architecture-skill** - Swift 6, SwiftData, Observation framework, modern concurrency
3. **ios-accessibility-skill** - VoiceOver, Dynamic Type, HIG compliance
4. **swift-performance-optimization-skill** - Performance profiling, Instruments, memory efficiency
5. **cross-platform-app-development-skill** - Multi-platform app strategies
6. **swift-unit-testing-skill** - XCTest, TDD, mocking patterns
7. **ios-animation-graphics-skill** - SwiftUI Canvas, Lottie animations
8. **memory-leak-diagnosis-skill** - ARC, retain cycles, Instruments Leaks tool
9. **swift-SpeechAnalyzer-Framework-Expert** - Apple Speech framework (macOS 26+/iOS 26+)
10. **multi-llm-orchestrator** - Orchestrate multiple AI coding assistants
11. **gemini-cli-helper** - Delegate analysis to Gemini CLI's large context

## Skill File Structure

Each `SKILL.md` uses this frontmatter format:
```yaml
---
name: <Skill Name>
description: <Brief description including when to activate>
---
```

## Creating New Skills

When adding a new skill:

1. **Frontmatter**: YAML frontmatter with `name` and `description` only
2. **Best Practices**: 6-10 numbered best practices specific to the domain
3. **Guidelines**: Additional domain-specific guidelines
4. **Examples**: 3-5 complete examples with user prompt and working code
5. **No extras**: Do NOT create README.md, auxiliary docs, or extraneous files

### Code Standards

All Swift code examples should:
- Follow Apple's Swift API Design Guidelines
- Use modern Swift features (async/await, @Observable, SwiftData)
- Include proper imports and be compilable
- Support accessibility (labels, hints, Dynamic Type)
- Use proper error handling and type safety

## Development Notes

This repository contains documentation and example code snippets, not a runnable project. There is no Package.swift or Xcode project. Code examples are illustrative and designed to be copied into real projects.
