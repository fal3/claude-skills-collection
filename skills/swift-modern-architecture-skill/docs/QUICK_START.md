# Quick Start Guide - Swift Modern Architecture Skill

## 🎯 What This Skill Solves

**Problem**: Claude often generates iOS code using outdated patterns from 2020-2023:
- `ObservableObject` instead of `@Observable`
- Core Data instead of SwiftData
- `DispatchQueue` instead of `async/await`
- `NavigationView` instead of `NavigationStack`

**Solution**: This skill guides Claude to use **Swift 6 and iOS 18+ best practices**.

## 📦 Installation (30 seconds)

### For Your GitHub Repository
```bash
# Extract and add to your collection
unzip swift-modern-architecture-skill.zip
mv swift-modern-architecture-skill /path/to/claude-skills-collection/
git add swift-modern-architecture-skill/
git commit -m "Add Swift 6 modern architecture skill"
```

### For Claude.ai
1. Extract `swift-modern-architecture-skill.zip`
2. Copy content of `SKILL.md`
3. Paste into Claude conversation (it will recognize the skill format)

### For Claude Code
```bash
# Install for automatic loading
unzip swift-modern-architecture-skill.zip -d ~/.claude/skills/
```

## 🚀 Try It Now

### Test 1: Create a Modern App
```
Prompt: "Create a SwiftUI todo app with persistence"

Expected Output:
✅ Uses SwiftData (@Model, @Query)
✅ Uses @Observable for ViewModel
✅ Uses async/await for operations
✅ Uses NavigationStack
```

### Test 2: Build an API Client
```
Prompt: "Build a weather API client"

Expected Output:
✅ Uses actor for thread safety
✅ Uses async/await (no completion handlers)
✅ Proper error handling
✅ Modern URLSession patterns
```

### Test 3: Modernize Legacy Code
```
Prompt: "Update this code to modern Swift patterns"
[Paste old ObservableObject code]

Expected Output:
✅ Identifies outdated patterns
✅ Suggests @Observable migration
✅ Explains why changes are better
✅ Provides updated code
```

## 📚 Skill Structure

```
swift-modern-architecture-skill/
│
├── SKILL.md (400 lines)
│   ├── Core principles
│   ├── Quick reference patterns
│   ├── Decision trees
│   └── When to load reference files
│
└── references/
    ├── modern-patterns.md (350 lines)
    │   └── Complete Swift 6/iOS 18+ patterns
    │
    ├── anti-patterns.md (250 lines)
    │   └── What NOT to do + why
    │
    └── examples.md (400 lines)
        └── Full app implementations
```

## 🎯 What Gets Generated

### Before (Claude without this skill)
```swift
// ❌ Outdated patterns
class ViewModel: ObservableObject {
    @Published var items: [Item] = []
    
    func loadData(completion: @escaping () -> Void) {
        DispatchQueue.global().async {
            // load data
            DispatchQueue.main.async {
                completion()
            }
        }
    }
}
```

### After (Claude with this skill)
```swift
// ✅ Modern patterns
@Observable
final class ViewModel {
    private(set) var items: [Item] = []
    
    @MainActor
    func loadData() async throws {
        items = try await dataService.fetch()
    }
}
```

## 📖 Reference Files Usage

The skill uses **progressive disclosure** - it only loads what's needed:

| File | When to Load | Size |
|------|-------------|------|
| `SKILL.md` | Always (automatic) | 400 lines |
| `modern-patterns.md` | Complex features | 350 lines |
| `anti-patterns.md` | Code reviews | 250 lines |
| `examples.md` | New projects | 400 lines |

Claude will automatically decide when to load reference files based on your request.

## ✅ Verification Checklist

Your skill is working correctly if Claude:

- [ ] Uses `@Observable` instead of `ObservableObject`
- [ ] Uses `@Query` instead of `@FetchRequest`
- [ ] Uses `actor` for thread-safe shared state
- [ ] Uses `async/await` instead of completion handlers
- [ ] Uses `@MainActor` for UI updates
- [ ] Uses `NavigationStack` instead of `NavigationView`
- [ ] Uses Swift Testing instead of XCTest (when appropriate)
- [ ] Uses `throws(ErrorType)` for typed errors

## 🔧 Troubleshooting

**Issue**: Claude still generates old patterns  
**Fix**: Make your prompt more specific: "Create a [feature] using Swift 6 and iOS 18 patterns"

**Issue**: Skill not loading  
**Fix**: Mention "modern Swift" or "Swift 6" in your prompt to trigger activation

**Issue**: Want more details  
**Fix**: Ask Claude to "read the modern-patterns reference" for comprehensive guidance

## 💡 Pro Tips

1. **Mention Swift 6 or iOS 18** in your initial prompt to ensure skill activation
2. **For large projects**, ask Claude to read the examples.md file first
3. **For code reviews**, ask Claude to check against anti-patterns.md
4. **For learning**, ask "What's the modern way to do X?" to get explanations

## 🎓 Learn More

The skill includes explanations for WHY patterns are better:

```
Ask: "Why should I use @Observable instead of ObservableObject?"

Claude will explain:
- Performance benefits
- Cleaner syntax
- Better SwiftUI integration
- Reduced boilerplate
```

## 📊 Coverage

| Pattern Category | Covered |
|-----------------|---------|
| State Management | ✅ @Observable, @State, @Environment |
| Persistence | ✅ SwiftData, @Model, @Query |
| Concurrency | ✅ async/await, actor, @MainActor |
| Navigation | ✅ NavigationStack, NavigationPath |
| API Clients | ✅ actor-based, async throws |
| Testing | ✅ Swift Testing framework |
| UI Patterns | ✅ Modern SwiftUI APIs |

## 🤝 Integration with Your Skills

Works great with:
- ✅ swiftui-programming-skill (UI patterns)
- ✅ ios-accessibility-skill (accessibility)
- ✅ swift-performance-optimization-skill (performance)
- ✅ memory-leak-diagnosis-skill (debugging)

## 🎉 You're Ready!

Try it now:
```
"Create a SwiftUI app with [your feature] using modern Swift patterns"
```

Happy coding! 🚀
