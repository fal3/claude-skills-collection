# Claude Skills Collection: Swift/iOS Development

This repository contains a collection of Claude Skills tailored for Swift and iOS app development. Each skill focuses on a specific area to help developers build high-quality iOS applications.

## Skills Index

| Skill | Description |
|-------|-------------|
| [swiftui-programming-skill](swiftui-programming-skill/) | Expertise in SwiftUI for building declarative user interfaces. |
| [ios-accessibility-skill](ios-accessibility-skill/) | Best practices for implementing accessibility features in iOS apps. |
| [swift-performance-optimization-skill](swift-performance-optimization-skill/) | Techniques for optimizing Swift code performance, memory usage, and rendering. |
| [cross-platform-app-development-skill](cross-platform-app-development-skill/) | Strategies for developing apps that work across multiple platforms. |
| [swift-unit-testing-skill](swift-unit-testing-skill/) | Guidelines and templates for writing effective unit tests with XCTest. |
| [ios-animation-graphics-skill](ios-animation-graphics-skill/) | Creating animations and graphics using SwiftUI Canvas and Lottie. |
| [memory-leak-diagnosis-skill](memory-leak-diagnosis-skill/) | Detecting and fixing memory leaks and retain cycles in Swift apps. |

## Installation & Setup

### Prerequisites
- A Claude account (create one at [claude.ai](https://claude.ai))
- Git installed for cloning (download from [git-scm.com](https://git-scm.com) if needed)
- Optional: Claude Code for enhanced integration with development workflows

### For Claude Code Users

1. **Clone this repository:**
   ```bash
   git clone https://github.com/yourusername/claude-skills-collection.git
   cd claude-skills-collection
   ```

2. **Configure Claude Code:**
   - The `CLAUDE.md` file in the repository root provides guidance to Claude Code
   - Skills will load automatically based on query topics (see activation triggers below)
   - No additional configuration required

3. **Test a Skill:**
   - Example: "Create a SwiftUI toolbar" → activates `swiftui-programming-skill`
   - Example: "Help me implement VoiceOver support" → activates `ios-accessibility-skill`
   - Example: "Fix this memory leak" → activates `memory-leak-diagnosis-skill`

### For Direct Claude Usage

#### Option 1: Manual Copy (Recommended for Beginners)

1. **Download or Copy Skill Content:**
   - Visit the repository at [github.com/yourusername/claude-skills-collection](https://github.com/yourusername/claude-skills-collection)
   - Download the ZIP or navigate to a skill directory (e.g., `swiftui-programming-skill/`)
   - Copy the content of `SKILL.md`

2. **Paste into Claude:**
   - Open a new Claude conversation at [claude.ai](https://claude.ai)
   - Paste the complete `SKILL.md` content (including YAML frontmatter)
   - Ask a related question (e.g., "Design a macOS toolbar with SF Symbols")

3. **Use Examples:**
   - Refer to the `examples/` directory for code snippets
   - Copy and modify examples for your specific use case
   - All examples are tested and follow Apple's guidelines

#### Option 2: Automated Script (Advanced Users)

Use our Python CLI tool for faster skill access:

```bash
# List all available skills
python scripts/load-skill.py list

# Copy skill directly to clipboard
python scripts/load-skill.py copy swiftui-programming-skill

# Search for skills by keyword
python scripts/load-skill.py search "memory"
```

See [scripts/README.md](scripts/README.md) for full documentation and setup instructions.

### Troubleshooting

**Skill Not Loading?**
- Ensure the full `SKILL.md` content is pasted, including the YAML frontmatter (lines starting with `---`)
- Verify you're asking questions related to the skill's domain
- Check that activation triggers match your query (see "Working with Skills" below)

**Git Issues?**
- Verify Git installation: `git --version`
- Alternative: Download the ZIP manually from the GitHub repository page
- For Windows users: Use Git Bash or Windows Terminal

**File Path Issues?**
- Use absolute paths when referencing files
- On Windows, use forward slashes `/` or escaped backslashes `\\`
- Ensure the repository is cloned to a location without spaces in the path

**Version Compatibility:**
- These skills are tested and validated as of October 2025
- All code uses modern Swift 5.9+ features and iOS 17+ APIs
- Check [Anthropic's documentation](https://docs.anthropic.com) for Claude updates
- Report issues via [GitHub Issues](https://github.com/yourusername/claude-skills-collection/issues)

## Usage Guidelines

### Getting Started

1. **Browse available skills** - Review the Skills Index above to find relevant expertise
2. **Read SKILL.md** - Each skill's SKILL.md contains:
   - Activation triggers (when to use this skill)
   - Best practices (6 key principles)
   - Domain-specific guidelines
   - 3-5 complete code examples
3. **Explore examples** - Check the `examples/` directory for:
   - `prompts.md` - Example questions and expected responses
   - `*.swift` - Working code snippets you can use

### Working with Skills

**Activation Triggers:**
Each skill activates based on specific keywords or topics:
- SwiftUI → `swiftui-programming-skill`
- Accessibility → `ios-accessibility-skill`
- Performance → `swift-performance-optimization-skill`
- Memory Issues → `memory-leak-diagnosis-skill`
- Testing → `swift-unit-testing-skill`
- Cross-Platform → `cross-platform-app-development-skill`
- Animations → `ios-animation-graphics-skill`

**Best Practices:**
- Start with the skill's best practices section for quick reference
- Use the examples as templates for your own code
- All code follows Apple's Swift API Design Guidelines
- Examples use modern Swift features (async/await, SwiftUI, etc.)

### Example Workflows

**Scenario 1: Adding VoiceOver Support**
```
1. Open ios-accessibility-skill/SKILL.md
2. Review "Best Practices" section
3. Check Example 1: "VoiceOver Labels in SwiftUI"
4. Copy and adapt the code to your project
```

**Scenario 2: Debugging Memory Leak**
```
1. Consult memory-leak-diagnosis-skill/SKILL.md
2. Review "Memory Management Guidelines"
3. Use Example 3: "Instruments Leaks Detection"
4. Follow the step-by-step process
```

**Scenario 3: Creating Animations**
```
1. Reference ios-animation-graphics-skill/SKILL.md
2. Choose appropriate technique (SwiftUI, Canvas, or Lottie)
3. Copy relevant example code
4. Customize for your animation needs
```

## Contributing & Community

We welcome contributions to improve and expand the Claude Skills Collection! Here's how you can help:

### Report Issues
- Found a bug or error in the code examples? [Open an issue](https://github.com/yourusername/claude-skills-collection/issues)
- Skill not activating as expected? Let us know!
- Have suggestions for new skills? We'd love to hear them!

### Contribute Skills
1. Fork this repository
2. Create a new skill following the structure in `CLAUDE.md`
3. Ensure your skill includes:
   - Proper YAML frontmatter
   - 6 best practices
   - Domain-specific guidelines
   - 3-5 complete, tested code examples
4. Submit a pull request with a clear description

### Improve Documentation
- Add visual aids (screenshots, diagrams) to help guide users
- Translate skills to other languages
- Create video tutorials demonstrating skill usage
- Share your success stories and use cases

### Guidelines
- All code must follow Apple's Swift API Design Guidelines
- Test your examples on actual devices/simulators
- Use modern Swift features (Swift 5.9+, iOS 17+)
- Ensure accessibility best practices are followed
- See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines

### Community Resources
- **GitHub Discussions**: Ask questions and share tips
- **Issues**: Report bugs and request features
- **Pull Requests**: Contribute improvements
- **Star the repo**: Show your support and help others discover these skills

### Roadmap & Future Skills
We're planning to add skills for:
- Core Data and SwiftData
- Combine and async/await patterns
- iOS Widget development
- App Clips and extensions
- ARKit and RealityKit
- CloudKit integration

Want to contribute one of these? Start a discussion or submit a PR!

---

**Last Updated:** October 2025
**Validated for:** Swift 5.9+, iOS 17+, Xcode 15+
**License:** MIT (see LICENSE file)

Made with ❤️ for the iOS development community