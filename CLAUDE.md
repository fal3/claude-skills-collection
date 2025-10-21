# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a **Claude Skills Collection** repository focused on Swift and iOS development. It contains curated skills that provide specialized expertise across different iOS/Swift domains. Each skill is a self-contained directory with structured documentation and examples.

## Repository Structure

The repository follows a consistent pattern:

```
<skill-name>/
├── SKILL.md              # Skill definition with frontmatter and instructions
├── README.md             # User-facing documentation
├── examples/
│   ├── prompts.md        # Example prompts and responses
│   └── *.swift           # Working code examples
└── references/          # Optional deep-dive guides (modern architecture skill)
```

### Available Skills

1. **swiftui-programming-skill** - SwiftUI declarative UI development, SF Symbols, state management
2. **swift-modern-architecture-skill** - Swift 6 architecture, SwiftData persistence, Observation framework, modern concurrency
3. **ios-accessibility-skill** - VoiceOver, Dynamic Type, HIG compliance
4. **swift-performance-optimization-skill** - Performance profiling, Instruments usage, memory efficiency
5. **cross-platform-app-development-skill** - Multi-platform app strategies
6. **swift-unit-testing-skill** - XCTest framework, TDD, mocking patterns
7. **ios-animation-graphics-skill** - SwiftUI Canvas, Lottie animations
8. **memory-leak-diagnosis-skill** - ARC, retain cycles, Instruments Leaks tool

## Working with Skills

### Skill File Structure

Each `SKILL.md` follows this frontmatter format:
```yaml
---
name: <Skill Name>
description: <Brief description>
version: 1.0
activation: <When to activate this skill>
---
```

The activation field describes when the skill should be invoked based on user queries.

### Creating New Skills

When adding a new skill, follow these requirements:

1. **Frontmatter**: Include YAML frontmatter with name, description, version, and activation
2. **Best Practices Section**: 6-10 numbered best practices specific to the domain
3. **Guidelines Section**: Additional domain-specific guidelines with bullet points
4. **Examples Section**: 3-5 complete examples with:
   - User Prompt showing typical request
   - Expected Output with working Swift code
   - Following Apple's Swift conventions
5. **Code Standards**: All examples must:
   - Follow Swift naming conventions (camelCase, PascalCase for types)
   - Include proper imports
   - Be runnable/compilable where applicable
   - Include explanatory comments where helpful
   - Use modern Swift features (async/await when appropriate)

### Code Quality Standards

All Swift code examples should adhere to:

- **Apple's Swift API Design Guidelines**
- **SwiftUI best practices** for declarative UI code
- **Modern concurrency** patterns (async/await, actors) when applicable
- **Memory safety** patterns (weak/unowned references, avoiding retain cycles)
- **Accessibility-first** design (proper labels, hints, Dynamic Type support)
- **Type safety** and clear error handling

### Testing Examples

When skills include testing patterns:
- Use XCTest framework conventions
- Follow Arrange-Act-Assert structure
- Include both sync and async test examples
- Show proper mocking/dependency injection patterns
- Demonstrate performance testing when relevant

## Contributing

Reference `CONTRIBUTING.md` for contribution guidelines, which include:
- Fork and pull request workflow
- Code must follow Apple's Swift and iOS guidelines
- Update SKILL.md and README.md with changes
- Test all code examples for correctness
- For new skills, include complete directory structure

## Development Notes

### No Build System
This repository contains documentation and example code snippets, not a runnable project. There is no Package.swift, Xcode project, or build system.

### Documentation-Focused
The primary artifacts are `.md` files with embedded Swift code blocks. Code examples are illustrative and designed to be copied into real projects.

### Version Management
Skills use semantic versioning in their frontmatter. Update version when making significant changes to skill content or examples.
