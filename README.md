# Claude Skills Collection

This repository contains a curated collection of Claude Skills organized by professional domain. Each skill provides specialized expertise to help developers build high-quality applications across different platforms and technologies.

## TL;DR - Get Started in 10 Seconds

### Claude Code Plugin (Recommended)
```bash
# In Claude Code, run:
/plugin marketplace add https://github.com/fal3/claude-skills-collection
/plugin install ios-swift-skills
```

That's it! All 8 iOS/Swift skills are now available automatically.

---

## Installation

### 🔌 Claude Code Plugin (Recommended)

**Install the plugin:**
```bash
# Add the marketplace
/plugin marketplace add https://github.com/fal3/claude-skills-collection

# Install the plugin
/plugin install ios-swift-skills
```

**Benefits:**
- ✅ All skills auto-loaded when relevant
- ✅ No manual copying or pasting
- ✅ Updates automatically when you pull changes
- ✅ Works across all your projects

### 🎯 Alternative: Project-Specific Installation

Clone this repo into your project and Claude Code will auto-detect the skills:

```bash
cd your-project/
git clone https://github.com/fal3/claude-skills-collection.git
```

Then reference in your project's `CLAUDE.md`:
```markdown
Load skills from: ./claude-skills-collection/
```

## Skills Index

All skills are automatically available once you install the plugin. No manual loading required!

### iOS Development (8 Skills)

| Skill | Description | Activation Keywords |
|-------|-------------|---------------------|
| **swiftui-programming-skill** | SwiftUI declarative UI development | SwiftUI, declarative UI, SF Symbols |
| **swift-modern-architecture-skill** | Swift 6/iOS 18 architecture patterns | Swift 6, iOS 18, SwiftData, modern architecture |
| **ios-accessibility-skill** | iOS accessibility best practices | VoiceOver, Dynamic Type, accessibility |
| **swift-performance-optimization-skill** | Performance optimization techniques | performance, Instruments, optimization |
| **cross-platform-app-development-skill** | Multi-platform app strategies | multi-platform, iPad, Mac Catalyst |
| **swift-unit-testing-skill** | XCTest and unit testing patterns | XCTest, unit testing, TDD |
| **ios-animation-graphics-skill** | SwiftUI animations and graphics | animations, Canvas, Lottie |
| **memory-leak-diagnosis-skill** | Memory leak detection and fixing | memory leaks, retain cycles, ARC |

Each skill includes:
- 6 key best practices
- Domain-specific guidelines
- 3-5 complete code examples
- Working Swift code snippets

### Web Development
*Coming soon* - Skills for React, TypeScript, Next.js, and modern web frameworks

### Backend Development
*Coming soon* - Skills for API design, database optimization, and server architecture

### Data Science & ML
*Coming soon* - Skills for data analysis, machine learning, and AI integration

---

## How It Works

Once installed, skills activate automatically based on your queries:

- Ask about **SwiftUI** → `swiftui-programming-skill` loads
- Mention **memory leaks** → `memory-leak-diagnosis-skill` activates
- Discuss **accessibility** → `ios-accessibility-skill` engages
- Talk about **testing** → `swift-unit-testing-skill` helps

No manual loading required. Just ask your question and the relevant skills provide expertise.

### Example Usage

```
You: "How do I add VoiceOver labels to my SwiftUI view?"
Claude: [ios-accessibility-skill activates] Here's how to implement VoiceOver...

You: "My app is using too much memory"
Claude: [memory-leak-diagnosis-skill activates] Let's diagnose potential memory leaks...

You: "I need to create a smooth animation"
Claude: [ios-animation-graphics-skill activates] I'll show you SwiftUI animation techniques...
```

Each skill provides:
- Best practices specific to the domain
- Complete, tested code examples
- Modern Swift/iOS patterns (Swift 6, iOS 18+)
- Apple HIG compliance

## Contributing

We welcome contributions! To add or improve skills:

1. Fork this repository
2. Add your skill in `skills/your-skill-name/SKILL.md`
3. Follow the skill structure defined in `CLAUDE.md`:
   - YAML frontmatter with name, description, version, activation
   - 6 best practices
   - Domain-specific guidelines
   - 3-5 complete code examples
4. Test with Claude Code: `/plugin marketplace add ./your-fork`
5. Submit a pull request

### Guidelines
- Follow Apple's Swift API Design Guidelines
- Use modern Swift (5.9+) and iOS (17+) features
- Include working, tested code examples
- See [CONTRIBUTING.md](CONTRIBUTING.md) for details

### Plugin Structure

This repository is a Claude Code plugin with the following structure:

```
claude-skills-collection/
├── .claude-plugin/
│   ├── plugin.json          # Plugin metadata
│   └── marketplace.json     # Marketplace config
├── skills/                   # All skills here
│   ├── swiftui-programming-skill/
│   │   ├── SKILL.md         # Skill definition
│   │   ├── README.md        # Documentation
│   │   └── examples/        # Code examples
│   └── ...
└── CLAUDE.md               # Repository guidelines
```

### Roadmap

**Upcoming Skills:**
- Core Data and SwiftData patterns
- iOS Widget development
- ARKit and RealityKit
- CloudKit integration
- Web Development (React, TypeScript, Next.js)
- Backend Development (API design, databases)
- Data Science & ML (Python, pandas, model training)

Want to contribute? Open an issue or submit a PR!

---

**Current Focus:** iOS Development (Swift 5.9+, iOS 17+, Xcode 15+)
**License:** MIT
**Maintained by:** [@fal3](https://github.com/fal3)
