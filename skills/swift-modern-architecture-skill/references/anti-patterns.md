# Common Anti-Patterns to Avoid

This document catalogs outdated patterns that should be avoided in modern Swift/iOS development.

## Concurrency Anti-Patterns

### ❌ Using DispatchQueue
```swift
// DON'T: Manual thread management
DispatchQueue.main.async {
    self.isLoading = false
}

DispatchQueue.global(qos: .background).async {
    // Heavy work
    let result = processData()
    DispatchQueue.main.async {
        self.updateUI(result)
    }
}
```

### ✅ Use async/await and @MainActor
```swift
// DO: Swift concurrency
@MainActor
func updateData() async {
    let result = await Task.detached(priority: .background) {
        processData()
    }.value
    updateUI(result)
}
```

## State Management Anti-Patterns

### ❌ Using @StateObject with ObservableObject
```swift
// DON'T: Old observation pattern
class ViewModel: ObservableObject {
    @Published var items: [Item] = []
}

struct ContentView: View {
    @StateObject var viewModel = ViewModel()
}
```

### ✅ Use @Observable
```swift
// DO: Modern observation
@Observable
final class ViewModel {
    var items: [Item] = []
}

struct ContentView: View {
    let viewModel = ViewModel()
}
```

## Data Persistence Anti-Patterns

### ❌ Using Core Data for New Projects
```swift
// DON'T: Core Data boilerplate
class Book: NSManagedObject {
    @NSManaged var title: String
    @NSManaged var author: String
}

@FetchRequest(sortDescriptors: [])
var books: FetchedResults<Book>
```

### ✅ Use SwiftData
```swift
// DO: SwiftData simplicity
@Model
final class Book {
    var title: String
    var author: String
}

@Query var books: [Book]
```

## Network Anti-Patterns

### ❌ Completion Handler Pyramid
```swift
// DON'T: Callback hell
func fetchUserData(completion: @escaping (Result<User, Error>) -> Void) {
    fetchUserId { result in
        switch result {
        case .success(let id):
            fetchUserProfile(id: id) { result in
                switch result {
                case .success(let profile):
                    fetchUserPreferences(id: id) { result in
                        completion(result)
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        case .failure(let error):
            completion(.failure(error))
        }
    }
}
```

### ✅ Linear async/await Flow
```swift
// DO: Clean async flow
func fetchUserData() async throws -> User {
    let id = try await fetchUserId()
    let profile = try await fetchUserProfile(id: id)
    let preferences = try await fetchUserPreferences(id: id)
    return User(profile: profile, preferences: preferences)
}
```

## UI Anti-Patterns

### ❌ NavigationView with Deprecated Patterns
```swift
// DON'T: Old navigation
NavigationView {
    List {
        NavigationLink(destination: DetailView()) {
            Text("Item")
        }
    }
}
```

### ✅ NavigationStack with Type-Safe Paths
```swift
// DO: Modern navigation
NavigationStack(path: $path) {
    List {
        Button("Item") {
            path.append(item)
        }
    }
    .navigationDestination(for: Item.self) { item in
        DetailView(item: item)
    }
}
```

## Memory Management Anti-Patterns

### ❌ Weak Self Dance in Closures
```swift
// DON'T: Manual weak references
func loadData() {
    apiClient.fetch { [weak self] result in
        guard let self = self else { return }
        self.handleResult(result)
    }
}
```

### ✅ Structured Concurrency (No Weak Self Needed)
```swift
// DO: Task automatically handles cancellation
func loadData() async {
    let result = await apiClient.fetch()
    handleResult(result) // No weak self needed
}
```

## Testing Anti-Patterns

### ❌ XCTestCase with Manual Assertions
```swift
// DON'T: Verbose XCTest
class AuthTests: XCTestCase {
    func testAuthentication() {
        let expectation = expectation(description: "Auth completes")
        authService.authenticate { result in
            XCTAssertTrue(result.isSuccess)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5)
    }
}
```

### ✅ Swift Testing with Modern Syntax
```swift
// DO: Concise Swift Testing
@Test("Authentication succeeds with valid credentials")
func authentication() async throws {
    let result = try await authService.authenticate()
    #expect(result.isSuccess)
}
```

## Architecture Anti-Patterns

### ❌ Massive View Controllers
```swift
// DON'T: God object with mixed concerns
class ProfileViewController: UIViewController {
    // 500+ lines of networking, business logic, and UI code
}
```

### ✅ Separated Concerns with MVVM
```swift
// DO: Clear separation
@Observable
final class ProfileViewModel {
    // Business logic only
}

struct ProfileView: View {
    let viewModel: ProfileViewModel
    // UI only
}
```

## Singleton Anti-Patterns

### ❌ Global Mutable State
```swift
// DON'T: Shared mutable singleton
class AppState {
    static let shared = AppState()
    var currentUser: User?
    var settings: Settings?
}
```

### ✅ Dependency Injection with Environment
```swift
// DO: Injected dependencies
@Observable
final class AppState {
    var currentUser: User?
    var settings: Settings
}

extension EnvironmentValues {
    @Entry var appState = AppState()
}
```

## Error Handling Anti-Patterns

### ❌ Force Unwrapping and Try!
```swift
// DON'T: Crash-prone code
let user = try! decoder.decode(User.self, from: data)
let name = user.profile!.name!
```

### ✅ Proper Error Handling
```swift
// DO: Safe unwrapping and error propagation
func decodeUser(from data: Data) throws -> User {
    let user = try decoder.decode(User.self, from: data)
    guard let profile = user.profile,
          let name = profile.name else {
        throw DecodingError.missingRequiredField
    }
    return user
}
```

## SwiftUI Anti-Patterns

### ❌ Excessive @State in Views
```swift
// DON'T: State explosion
struct ContentView: View {
    @State private var items: [Item] = []
    @State private var isLoading = false
    @State private var error: Error?
    @State private var selectedItem: Item?
    @State private var filterText = ""
    @State private var sortOrder: SortOrder = .ascending
}
```

### ✅ View Model for Complex State
```swift
// DO: Encapsulated state management
@Observable
final class ContentViewModel {
    var items: [Item] = []
    var isLoading = false
    var error: Error?
    var selectedItem: Item?
    var filterText = ""
    var sortOrder: SortOrder = .ascending
}

struct ContentView: View {
    let viewModel: ContentViewModel
}
```

## Performance Anti-Patterns

### ❌ Synchronous Blocking Operations
```swift
// DON'T: Block main thread
func loadImage(url: URL) -> UIImage {
    let data = try! Data(contentsOf: url) // Blocks!
    return UIImage(data: data)!
}
```

### ✅ Asynchronous Operations
```swift
// DO: Non-blocking async
func loadImage(url: URL) async throws -> UIImage {
    let (data, _) = try await URLSession.shared.data(from: url)
    guard let image = UIImage(data: data) else {
        throw ImageError.invalidData
    }
    return image
}
```

## Type Safety Anti-Patterns

### ❌ Stringly-Typed Code
```swift
// DON'T: String identifiers everywhere
func loadScreen(_ screen: String) {
    switch screen {
    case "home": // Typo-prone
        showHome()
    case "profile":
        showProfile()
    default:
        break
    }
}
```

### ✅ Type-Safe Enumerations
```swift
// DO: Compile-time safety
enum Screen {
    case home
    case profile
    case settings
}

func loadScreen(_ screen: Screen) {
    switch screen {
    case .home:
        showHome()
    case .profile:
        showProfile()
    case .settings:
        showSettings()
    }
}
```
