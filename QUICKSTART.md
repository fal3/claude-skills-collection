# Quick Start Guide

Get up and running with Claude Skills Collection in 5 minutes!

## 🚀 Quick Start (30 seconds)

```bash
# Clone the repository
git clone https://github.com/fal3/claude-skills-collection.git
cd claude-skills-collection

# List available skills
python3 scripts/load-skill.py list

# Copy a skill to clipboard
python3 scripts/load-skill.py copy swiftui-programming-skill

# Paste into Claude and start coding!
```

## 📋 What You Get

**8 Expert Skills for iOS/Swift Development:**
- 🎨 SwiftUI Programming
- 🏛 Swift Modern Architecture
- ♿ iOS Accessibility
- ⚡ Performance Optimization
- 🌐 Cross-Platform Development
- 🧪 Unit Testing
- 🎬 Animation & Graphics
- 🔍 Memory Leak Diagnosis

Each skill includes:
- ✅ 6 best practices
- ✅ Domain-specific guidelines
- ✅ 3-5 complete code examples
- ✅ Real-world use cases

## 🎯 Choose Your Path

### Path 1: Claude Code (Automated) ⭐ Recommended

```bash
# Clone and you're done!
git clone https://github.com/fal3/claude-skills-collection.git
cd claude-skills-collection

# Skills activate automatically based on your queries
# No configuration needed
```

**Example:**
```
You: "Help me create a SwiftUI toolbar"
Claude: [Activates swiftui-programming-skill automatically]
        [Provides expert guidance with examples]
```

### Path 2: Direct Claude (Copy & Paste)

```bash
# Option A: Use automation script
python3 scripts/load-skill.py copy ios-accessibility-skill
# Then paste into Claude

# Option B: Manual copy
cat ios-accessibility-skill/SKILL.md | pbcopy  # macOS
# Then paste into Claude
```

## 💡 Example Workflows

### Scenario 1: "I need to add VoiceOver support"

**With Claude Code:**
```
You: "Help me implement VoiceOver for this SwiftUI view"
Claude: [Automatically uses ios-accessibility-skill]
```

**With Direct Claude:**
```bash
python3 scripts/load-skill.py copy ios-accessibility-skill
# Paste into Claude, then ask: "Help me implement VoiceOver"
```

### Scenario 2: "My app has a memory leak"

**With Claude Code:**
```
You: "I have a memory leak in my view controller"
Claude: [Automatically uses memory-leak-diagnosis-skill]
```

**With Direct Claude:**
```bash
python3 scripts/load-skill.py copy memory-leak-diagnosis-skill
# Paste into Claude, then describe your memory leak issue
```

### Scenario 3: "Create a custom animation"

**With Claude Code:**
```
You: "Create a spring animation for this button"
Claude: [Automatically uses ios-animation-graphics-skill]
```

**With Direct Claude:**
```bash
python3 scripts/load-skill.py copy ios-animation-graphics-skill
# Paste into Claude, then describe your animation needs
```

## 🔍 Finding the Right Skill

**Quick Reference:**
```bash
python3 scripts/load-skill.py search "your topic"
```

**Keyword Mapping:**
- UI, SwiftUI, views → `swiftui-programming-skill`
- Modern, architecture, SwiftData, Observation → `swift-modern-architecture-skill`
- VoiceOver, accessibility → `ios-accessibility-skill`
- Slow, performance, optimize → `swift-performance-optimization-skill`
- iPad, Mac, multi-platform → `cross-platform-app-development-skill`
- Tests, XCTest, TDD → `swift-unit-testing-skill`
- Animation, graphics, canvas → `ios-animation-graphics-skill`
- Memory leak, retain cycle → `memory-leak-diagnosis-skill`

## ⚡ Power User Tips

### Create Shell Alias
```bash
# Add to ~/.zshrc or ~/.bashrc
alias skill='python3 /path/to/claude-skills-collection/scripts/load-skill.py'

# Then use:
skill list
skill search "animation"
skill copy swiftui-programming-skill
```

### VS Code Integration
```json
// Add to .vscode/tasks.json
{
  "label": "Load Skill",
  "type": "shell",
  "command": "python3 scripts/load-skill.py copy ${input:skillName}",
  "inputs": [
    {
      "id": "skillName",
      "type": "pickString",
      "description": "Select skill",
      "options": [
        "swiftui-programming-skill",
        "swift-modern-architecture-skill",
        "ios-accessibility-skill",
        "swift-performance-optimization-skill",
        "cross-platform-app-development-skill",
        "swift-unit-testing-skill",
        "ios-animation-graphics-skill",
        "memory-leak-diagnosis-skill"
      ]
    }
  ]
}
```

### Combine Skills
You can use multiple skills in one conversation:
```bash
# Copy both accessibility and SwiftUI skills
python3 scripts/load-skill.py copy ios-accessibility-skill
python3 scripts/load-skill.py copy swiftui-programming-skill
# Paste both into Claude for combined expertise
```

## 🎓 Learning Path

### Day 1: Master the Basics
1. Start with `swiftui-programming-skill`
2. Build a simple app using the examples
3. Explore the best practices section

### Week 1: Enhance Your App
1. Add accessibility with `ios-accessibility-skill`
2. Write tests using `swift-unit-testing-skill`
3. Profile performance with `swift-performance-optimization-skill`

### Month 1: Advanced Topics
1. Create animations with `ios-animation-graphics-skill`
2. Build for iPad/Mac with `cross-platform-app-development-skill`
3. Debug memory issues with `memory-leak-diagnosis-skill`

## 📚 Next Steps

1. **Explore Examples** - Browse the `examples/` directory in each skill
2. **Read CONTRIBUTING.md** - Learn how to contribute new skills
3. **Join the Community** - Report issues, share tips, contribute code
4. **Star the Repo** ⭐ - Help others discover these skills

## 🆘 Need Help?

**Common Issues:**
- Skill not loading? → Check YAML frontmatter is included
- Script errors? → Ensure Python 3.6+ is installed
- Clipboard not working? → Install `pbcopy` (macOS), `xclip` (Linux), or `clip` (Windows)

**Get Support:**
- 📖 Read [README.md](README.md) for detailed documentation
- 🐛 [Report bugs](https://github.com/fal3/claude-skills-collection/issues)
- 💬 [Ask questions](https://github.com/fal3/claude-skills-collection/discussions)
- 📧 Contact maintainers

---

**Ready to become an iOS development expert?**
Start with: `python3 scripts/load-skill.py list`

Happy coding! 🚀
