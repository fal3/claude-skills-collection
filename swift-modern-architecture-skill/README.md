# Swift Modern Architecture Skill

🚀 A comprehensive Claude skill for building iOS apps with Swift 6, iOS 18+, SwiftUI, SwiftData, and modern concurrency patterns.

## What This Skill Does

This skill addresses a critical gap in iOS development with Claude: **preventing outdated code patterns**. It actively guides Claude to use modern Swift 6 and iOS 18+ APIs instead of legacy patterns that are commonly generated but now considered anti-patterns.

### Key Features

✅ **Swift 6 Concurrency** – Uses `async/await`, `actor`, and `@MainActor` instead of GCD  
✅ **Observation Framework** – Uses `@Observable` instead of Combine's `ObservableObject`  
✅ **SwiftData** – Uses modern `@Model` and `@Query` instead of Core Data  
✅ **Modern SwiftUI** – Uses `NavigationStack`, `@Entry`, and the latest APIs  
✅ **Type Safety** – Enforces Swift 6 strict concurrency checking  
✅ **Best Practices** – MVVM architecture with clean separation of concerns

## Why This Matters

Based on community feedback and real-world usage, Claude often generates iOS code using outdated patterns like:
- ❌ `ObservableObject` with `@Published` (use `@Observable` instead)
- ❌ Core Data with `NSManagedObject` (use SwiftData instead)
- ❌ `DispatchQueue.main.async` (use `@MainActor` instead)
- ❌ `NavigationView` (use `NavigationStack` instead)
- ❌ Completion handlers (use `async/await` instead)

This skill **prevents these anti-patterns** and ensures generated code uses 2025 best practices.

## Installation

### Option 1: Add to Your Repository
```bash
# From the repository root
cp -r swift-modern-architecture-skill /path/to/your/claude-skills-collection/
```

### Option 2: Upload to Claude
1. Extract the `swift-modern-architecture-skill.zip` file
2. Upload to Claude.ai via Skills (if your Claude account supports it)
3. Or paste the `SKILL.md` content directly into a conversation

### Option 3: Use with Claude Code
```bash
# Place in your home directory for automatic loading
cp -r swift-modern-architecture-skill ~/.claude/skills/
```

## What's Included

```
swift-modern-architecture-skill/
├── SKILL.md                          # Main skill file (concise, ~400 lines)
└── references/
    ├── modern-patterns.md            # Swift 6 & iOS 18+ patterns (350+ lines)
    ├── anti-patterns.md              # What to avoid and why (250+ lines)
    └── examples.md                   # Complete implementations (400+ lines)
```

### Progressive Disclosure Design

The skill uses a three-tier loading approach:
1. **SKILL.md** – Core guidance (always loaded when the skill activates)
2. **modern-patterns.md** – Detailed patterns (load for complex features)
3. **anti-patterns.md** – Legacy pattern migration (load for code reviews)
4. **examples.md** – Complete apps (load for new projects)

## Usage Examples

### Example 1: Creating a Todo App
```
User: "Create a SwiftUI todo app with persistence"

Claude: Reads SKILL.md and references/examples.md
        ✅ Uses @Model for Todo entity
        ✅ Uses @Query for data fetching
        ✅ Uses @Observable for ViewModel
        ✅ Uses NavigationStack for navigation
```

### Example 2: Building an API Client
```
User: "Build a weather API client for my iOS app"

Claude: Reads SKILL.md and references/modern-patterns.md
        ✅ Creates actor-based API client
        ✅ Uses async/await for all operations
        ✅ Provides typed error handling
        ✅ Demonstrates structured concurrency
```

### Example 3: Modernizing Legacy Code
```
User: "Update this code to use modern Swift patterns"
[Pastes code with ObservableObject and Core Data]

Claude: Reads SKILL.md and references/anti-patterns.md
        ✅ Identifies outdated patterns
        ✅ Migrates ObservableObject → @Observable
        ✅ Migrates Core Data → SwiftData
        ✅ Replaces DispatchQueue with async/await
```

## Technical Details

### Skill Metadata
- **Name**: swift-modern-architecture-skill
- **Target**: Swift 6, iOS 18+, Xcode 16+
- **Frameworks**: SwiftUI, SwiftData, Observation, Swift Testing
- **Architecture**: MVVM with modern patterns

### Activation Triggers
The skill automatically activates when:
- Writing Swift or iOS code
- Designing app architecture
- Reviewing Swift code for modernization
- Setting up SwiftUI views, view models, or data models
- Implementing networking, persistence, or async workflows

### Reference File Summary

**references/modern-patterns.md** (350+ lines)  
Swift 6 concurrency patterns, SwiftData usage, Observation framework, modern API clients, Swift Testing, performance guidance.

**references/anti-patterns.md** (250+ lines)  
What not to use and why, side-by-side comparisons, migration paths from legacy patterns.

**references/examples.md** (400+ lines)  
Complete projects: Todo app with SwiftData, weather app with actor-based networking, authentication flow with modern architecture.

## Integration with the Collection

This skill complements the existing repository:

| Existing Skill | Modern Architecture Skill | How They Work Together |
|----------------|---------------------------|------------------------|
| swiftui-programming-skill | Ensures latest SwiftUI APIs | Combine UI expertise with modern architecture |
| ios-accessibility-skill | Accessibility-ready architecture | Build inclusive apps using current patterns |
| swift-performance-optimization-skill | Modern performance techniques | Optimize using Swift 6 features |
| memory-leak-diagnosis-skill | Concurrency-safe patterns | Prevent leaks with actor/async workflows |

Suggested repository structure:
```
claude-skills-collection/
├── swiftui-programming-skill/
├── ios-accessibility-skill/
├── swift-modern-architecture-skill/     ← New
├── swift-performance-optimization-skill/
└── ...
```

## Testing the Skill

Try these prompts to verify the skill is active:

1. **"Create a SwiftUI app with data persistence"** → Should use SwiftData, not Core Data  
2. **"Build an iOS API client using modern Swift"** → Should use actors and async/await  
3. **"Make a view model for authentication"** → Should use @Observable, not ObservableObject  
4. **"How do I handle async operations in SwiftUI?"** → Should mention @MainActor and `.task`  
5. **"Review this ObservableObject code"** → Should flag it as outdated and suggest @Observable

## Version History

- **v1.0** (October 2025) – Initial release covering Swift 6, iOS 18+, SwiftData, modern concurrency, and complete reference material.

## License

MIT License – See repository root `LICENSE` file for details.

---

**Built for the iOS development community** 🍎✨

Perfect for:
- iOS developers learning modern Swift
- Teams modernizing legacy codebases
- Anyone using Claude for Swift development
- Avoiding outdated, deprecated patterns in generated code

Questions? Open an issue or start a discussion!
