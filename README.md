# Claude Skills Collection

A curated collection of Claude Code skills for Swift and iOS development. Each skill provides specialized expertise to help developers build high-quality applications.

## Installation

### Option 1: Clone into your project (Recommended)

```bash
cd your-project/
git clone https://github.com/fal3/claude-skills-collection.git
```

Then add this line to your project's `CLAUDE.md`:

```markdown
Load skills from: ./claude-skills-collection/
```

### Option 2: Copy individual skills

Copy the skill folders you need into your project's `skills/` directory:

```bash
cp -r claude-skills-collection/skills/swiftui-programming-skill ./skills/
```

Then reference in your `CLAUDE.md`:

```markdown
Load skills from: ./skills/
```

## Available Skills

### iOS / Swift Development

| Skill | Description |
|-------|-------------|
| **swiftui-programming-skill** | SwiftUI declarative UI development, SF Symbols, state management |
| **swift-modern-architecture-skill** | Swift 6/iOS 18 architecture, SwiftData, Observation framework |
| **ios-accessibility-skill** | VoiceOver, Dynamic Type, HIG compliance |
| **swift-performance-optimization-skill** | Performance profiling, Instruments, memory efficiency |
| **cross-platform-app-development-skill** | Multi-platform app strategies across Apple ecosystem |
| **swift-unit-testing-skill** | XCTest, TDD, mocking patterns |
| **ios-animation-graphics-skill** | SwiftUI Canvas, animations, Lottie integration |
| **memory-leak-diagnosis-skill** | ARC, retain cycles, Instruments Leaks tool |
| **swift-SpeechAnalyzer-Framework-Expert** | Apple Speech framework (macOS 26+/iOS 26+) |

### AI / Multi-Model

| Skill | Description |
|-------|-------------|
| **multi-llm-orchestrator** | Orchestrate Claude Code, Gemini CLI, Codex, and Grok together |
| **gemini-cli-helper** | Delegate large codebase analysis to Gemini CLI |

## How It Works

Skills activate automatically based on your queries. Ask about SwiftUI and the SwiftUI skill provides expertise. Mention memory leaks and the diagnosis skill engages. No manual loading required.

Each skill includes:
- Best practices specific to the domain
- Complete, working Swift code examples
- Modern patterns (Swift 6, iOS 18+)

## Contributing

1. Fork this repository
2. Add your skill in `skills/your-skill-name/SKILL.md`
3. Follow the skill structure: YAML frontmatter (`name`, `description`), best practices, guidelines, and code examples
4. Submit a pull request

See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

---

**Current Focus:** iOS Development (Swift 6, iOS 18+, Xcode 16+)  
**License:** MIT  
**Maintained by:** [@fal3](https://github.com/fal3)
