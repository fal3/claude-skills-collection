# Claude Skills Collection

This repository contains a curated collection of Claude Skills organized by professional domain. Each skill provides specialized expertise to help developers build high-quality applications across different platforms and technologies.

## TL;DR - Get Started in 30 Seconds

### Option 1: NPM Package (Recommended)
```bash
# Install globally
npm install -g claude-ios-skills

# List all skills
ios-skills list

# Copy any skill to clipboard
ios-skills copy swiftui-programming-skill

# Paste into Claude and start coding!
```

### Option 2: NPX (No Installation)
```bash
# Run directly without installing
npx claude-ios-skills list
npx claude-ios-skills copy swiftui-programming-skill
```

### Option 3: Direct Download
```bash
# Download any skill directly
curl -fsSL https://raw.githubusercontent.com/fal3/claude-skills-collection/main/swiftui-programming-skill/SKILL.md -o ~/.claude/skills/swiftui-programming-skill.md
```

### Option 4: Web Interface
Open `web/index.html` in your browser for a visual interface with one-click installation.

That's it! Now go ask Claude about SwiftUI.

---

## Installation Methods

### 🚀 NPM Package (Recommended)
```bash
# Install globally
npm install -g claude-ios-skills

# Use from anywhere
ios-skills list
ios-skills copy swiftui-programming-skill
ios-skills search "accessibility"
```

### ⚡ NPX (No Installation Required)
```bash
# Run directly without installing
npx claude-ios-skills list
npx claude-ios-skills copy ios-accessibility-skill
npx claude-ios-skills install-all
```

### 🌐 Web Interface
Open `web/index.html` in your browser for a visual interface with:
- One-click skill copying
- Direct downloads
- Interactive skill browser

### 📦 Distribution Script
```bash
# Clone the repo
git clone https://github.com/fal3/claude-skills-collection.git
cd claude-skills-collection

# Use the distribution script
./distribute.sh list
./distribute.sh install swiftui-programming-skill
./distribute.sh copy ios-accessibility-skill
./distribute.sh install-all
```

### 🔗 Direct Download
```bash
# Download any skill directly
mkdir -p ~/.claude/skills
curl -fsSL https://raw.githubusercontent.com/fal3/claude-skills-collection/main/swiftui-programming-skill/SKILL.md -o ~/.claude/skills/swiftui-programming-skill.md
```

## Skills Index

### iOS Development

<details>
<summary><b>swiftui-programming-skill</b> - SwiftUI declarative UI development</summary>

```bash
curl -fsSL https://raw.githubusercontent.com/fal3/claude-skills-collection/main/swiftui-programming-skill/SKILL.md -o ~/.claude/skills/swiftui-programming-skill.md
```
</details>

<details>
<summary><b>swift-modern-architecture-skill</b> - Swift 6/iOS 18 architecture patterns</summary>

```bash
curl -fsSL https://raw.githubusercontent.com/fal3/claude-skills-collection/main/swift-modern-architecture-skill/SKILL.md -o ~/.claude/skills/swift-modern-architecture-skill.md
```
</details>

<details>
<summary><b>ios-accessibility-skill</b> - iOS accessibility best practices</summary>

```bash
curl -fsSL https://raw.githubusercontent.com/fal3/claude-skills-collection/main/ios-accessibility-skill/SKILL.md -o ~/.claude/skills/ios-accessibility-skill.md
```
</details>

<details>
<summary><b>swift-performance-optimization-skill</b> - Performance optimization techniques</summary>

```bash
curl -fsSL https://raw.githubusercontent.com/fal3/claude-skills-collection/main/swift-performance-optimization-skill/SKILL.md -o ~/.claude/skills/swift-performance-optimization-skill.md
```
</details>

<details>
<summary><b>cross-platform-app-development-skill</b> - Multi-platform app strategies</summary>

```bash
curl -fsSL https://raw.githubusercontent.com/fal3/claude-skills-collection/main/cross-platform-app-development-skill/SKILL.md -o ~/.claude/skills/cross-platform-app-development-skill.md
```
</details>

<details>
<summary><b>swift-unit-testing-skill</b> - XCTest and unit testing patterns</summary>

```bash
curl -fsSL https://raw.githubusercontent.com/fal3/claude-skills-collection/main/swift-unit-testing-skill/SKILL.md -o ~/.claude/skills/swift-unit-testing-skill.md
```
</details>

<details>
<summary><b>ios-animation-graphics-skill</b> - SwiftUI animations and graphics</summary>

```bash
curl -fsSL https://raw.githubusercontent.com/fal3/claude-skills-collection/main/ios-animation-graphics-skill/SKILL.md -o ~/.claude/skills/ios-animation-graphics-skill.md
```
</details>

<details>
<summary><b>memory-leak-diagnosis-skill</b> - Memory leak detection and fixing</summary>

```bash
curl -fsSL https://raw.githubusercontent.com/fal3/claude-skills-collection/main/memory-leak-diagnosis-skill/SKILL.md -o ~/.claude/skills/memory-leak-diagnosis-skill.md
```
</details>

### Web Development
*Coming soon* - Skills for React, TypeScript, Next.js, and modern web frameworks

### Backend Development
*Coming soon* - Skills for API design, database optimization, and server architecture

### Data Science & ML
*Coming soon* - Skills for data analysis, machine learning, and AI integration

## Installation & Setup

### How to Use Installed Skills

**After downloading a skill:**

1. Open the file: `~/.claude/skills/<skill-name>.md`
2. Copy the entire content
3. Paste into your Claude conversation
4. Start asking domain-specific questions!

---

### Alternative Methods

<details>
<summary><b>For Claude Code Users</b></summary>

**Auto-load from project:**
```bash
# Clone into your project
git clone https://github.com/fal3/claude-skills-collection.git

# Reference in your CLAUDE.md
echo "Load skills from: ./claude-skills-collection/" >> CLAUDE.md
```

Claude Code will auto-detect and load relevant skills.

</details>

<details>
<summary><b>Using Python CLI Tool</b></summary>

```bash
# List all available skills
python scripts/load-skill.py list

# Copy skill to clipboard
python scripts/load-skill.py copy swiftui-programming-skill

# Search by keyword
python scripts/load-skill.py search "memory"
```

See [scripts/README.md](scripts/README.md) for details.

</details>

### Troubleshooting

**Skill Not Loading?**
- Ensure the full `SKILL.md` content is pasted, including the YAML frontmatter (lines starting with `---`)
- Verify you're asking questions related to the skill's domain
- Check that activation triggers match your query (see "Working with Skills" below)

**Git Issues?**
- Verify Git installation: `git --version`
- Alternative: Browse files directly on GitHub and copy skill content
- For Windows users: Use Git Bash or Windows Terminal

**File Path Issues?**
- Use absolute paths when referencing files
- On Windows, use forward slashes `/` or escaped backslashes `\\`
- Ensure the repository is cloned to a location without spaces in the path

**Version Compatibility:**
- These skills are tested and validated as of October 2025
- All code uses modern Swift 5.9+ features and iOS 17+ APIs
- Check [Anthropic's documentation](https://docs.anthropic.com) for Claude updates
- Report issues via GitHub Issues in this repository

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
- Modern Swift patterns → `swift-modern-architecture-skill`
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
- Found a bug or error in the code examples? Open an issue in this repository
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

**iOS Development:**
- Core Data and SwiftData
- iOS Widget development
- App Clips and extensions
- ARKit and RealityKit
- CloudKit integration

**Web Development:**
- React/Next.js component patterns
- TypeScript best practices
- Web accessibility (WCAG)
- Performance optimization

**Backend Development:**
- RESTful API design
- Database schema optimization
- Microservices architecture
- Authentication & authorization

**Data Science & ML:**
- Data preprocessing and cleaning
- Model training and evaluation
- Python/pandas workflows
- ML deployment patterns

Want to contribute one of these? Start a discussion or submit a PR!

---

**Last Updated:** October 2025
**Current Focus:** iOS Development (Swift 5.9+, iOS 17+, Xcode 15+)
**License:** MIT (see LICENSE file)

Made with ❤️ for the developer community
