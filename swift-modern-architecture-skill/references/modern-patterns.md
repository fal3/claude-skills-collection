# Modern Swift & iOS Architecture Patterns (2025)

This reference guide covers modern patterns for Swift 6 and iOS 18+ development.

## Swift 6 Concurrency

### Strict Concurrency Checking
- Use `@MainActor` for UI-bound types
- Avoid `@unchecked Sendable` - use proper `Sendable` conformance
- Use `sending` parameter for transferring data between isolation domains
- Use structured concurrency (`async let`, `TaskGroup`) over unstructured (`Task {}`)

### Modern Async Patterns
```swift
// ✅ Modern: Structured concurrency with TaskGroup
func fetchMultipleResources() async throws -> [Resource] {
    try await withThrowingTaskGroup(of: Resource.self) { group in
        for id in resourceIDs {
            group.addTask { try await fetchResource(id) }
        }
        return try await group.reduce(into: []) { $0.append($1) }
    }
}

// ❌ Outdated: Unstructured tasks
func fetchMultipleResources() async throws -> [Resource] {
    let tasks = resourceIDs.map { id in
        Task { try await fetchResource(id) }
    }
    return try await tasks.asyncMap { try await $0.value }
}
```

## SwiftData (Not Core Data)

### Model Definition
```swift
// ✅ Modern: SwiftData with @Model
import SwiftData

@Model
final class Book {
    var title: String
    var author: String
    var publishedDate: Date
    @Relationship(deleteRule: .cascade) var chapters: [Chapter]
    
    init(title: String, author: String, publishedDate: Date) {
        self.title = title
        self.author = author
        self.publishedDate = publishedDate
        self.chapters = []
    }
}

// ❌ Outdated: Core Data with NSManagedObject
```

### Data Access
```swift
// ✅ Modern: @Query with sorting and filtering
struct BookListView: View {
    @Query(sort: \Book.publishedDate, order: .reverse) 
    private var books: [Book]
    
    var body: some View {
        List(books) { book in
            BookRow(book: book)
        }
    }
}
```

## Observation Framework (Not Combine)

### Observable Objects
```swift
// ✅ Modern: @Observable macro
import Observation

@Observable
final class AuthViewModel {
    var isAuthenticated = false
    var user: User?
    
    func signIn(email: String, password: String) async throws {
        // Authentication logic
        isAuthenticated = true
    }
}

// ❌ Outdated: ObservableObject with @Published
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var user: User?
}
```

### View Integration
```swift
// ✅ Modern: Direct property access, @Bindable for two-way binding
struct ProfileView: View {
    @Bindable var viewModel: ProfileViewModel
    
    var body: some View {
        TextField("Name", text: $viewModel.name)
        Text(viewModel.email) // No $ needed for read-only
    }
}

// ❌ Outdated: @StateObject, @ObservedObject, @EnvironmentObject
```

## Modern API Client Patterns

### URLSession with async/await
```swift
// ✅ Modern: async/await with proper error handling
actor APIClient {
    private let session: URLSession
    private let decoder: JSONDecoder
    
    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }
    
    func fetch<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let (data, response) = try await session.data(for: endpoint.urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }
        
        return try decoder.decode(T.self, from: data)
    }
}

// ❌ Outdated: Completion handlers, DispatchQueue.main.async
```

## View Architecture

### Navigation
```swift
// ✅ Modern: NavigationStack with NavigationPath
struct AppView: View {
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            ContentView()
                .navigationDestination(for: Book.self) { book in
                    BookDetailView(book: book)
                }
                .navigationDestination(for: Author.self) { author in
                    AuthorDetailView(author: author)
                }
        }
    }
}

// ❌ Outdated: NavigationView with NavigationLink(destination:)
```

### Environment Integration
```swift
// ✅ Modern: Environment with @Entry and @Observable
extension EnvironmentValues {
    @Entry var theme: AppTheme = .default
}

struct ContentView: View {
    @Environment(\.theme) private var theme
    
    var body: some View {
        Text("Hello")
            .foregroundStyle(theme.primaryColor)
    }
}

// ❌ Outdated: Custom EnvironmentKey with preference
```

## Swift 6 Features

### Typed Throws (SE-0413)
```swift
// ✅ Modern: Typed throws for specific error types
enum ValidationError: Error {
    case invalidEmail
    case passwordTooShort
}

func validateCredentials(_ email: String, _ password: String) throws(ValidationError) {
    guard email.contains("@") else {
        throw .invalidEmail
    }
    guard password.count >= 8 else {
        throw .passwordTooShort
    }
}

// Usage with specific error handling
do {
    try validateCredentials(email, password)
} catch let error: ValidationError {
    // Only catches ValidationError
    handleError(error)
}
```

### Non-copyable Types (SE-0390)
```swift
// ✅ Modern: Non-copyable for resource management
struct FileHandle: ~Copyable {
    private let descriptor: Int32
    
    init(path: String) throws {
        self.descriptor = open(path, O_RDONLY)
        guard descriptor >= 0 else {
            throw FileError.cannotOpen
        }
    }
    
    deinit {
        close(descriptor)
    }
}
```

### Embedded Swift
```swift
// ✅ For resource-constrained environments
@_expose(wasm)
public func processData(_ input: UnsafeBufferPointer<UInt8>) -> Int32 {
    // Embedded Swift without runtime overhead
    return input.reduce(0, +)
}
```

## Testing Patterns

### Swift Testing Framework (Not XCTest)
```swift
// ✅ Modern: Swift Testing with @Test macro
import Testing

@Test("User authentication succeeds with valid credentials")
func testAuthentication() async throws {
    let service = AuthService()
    let result = try await service.authenticate(
        email: "test@example.com",
        password: "ValidPass123"
    )
    #expect(result.isAuthenticated)
}

@Test("Validation fails with invalid email", arguments: [
    "notanemail",
    "missing@domain",
    "@nodomain.com"
])
func testEmailValidation(invalidEmail: String) throws {
    #expect(throws: ValidationError.self) {
        try validateEmail(invalidEmail)
    }
}

// ❌ Outdated: XCTestCase with XCTAssert
```

## Performance & Memory

### Prefer Value Types
```swift
// ✅ Modern: Value semantics with struct
struct UserProfile: Sendable {
    let id: UUID
    let name: String
    let email: String
    var preferences: UserPreferences
}

// ❌ Outdated: Reference semantics for simple data
class UserProfile {
    let id: UUID
    var name: String
    var email: String
}
```

### Lazy Collections
```swift
// ✅ Modern: Lazy evaluation for large sequences
let results = data
    .lazy
    .filter { $0.isValid }
    .map { $0.transform() }
    .prefix(10)

// ❌ Outdated: Eager evaluation of entire sequence
```

## UI Best Practices

### Prefer Built-in Components
```swift
// ✅ Modern: Use native SwiftUI components
List {
    ForEach(items) { item in
        LabeledContent(item.name) {
            Text(item.value)
        }
    }
}

// ❌ Outdated: Custom implementations of standard patterns
```

### Dynamic Type Support
```swift
// ✅ Modern: Automatic Dynamic Type with .font()
Text("Title")
    .font(.title)
    .dynamicTypeSize(...DynamicTypeSize.xxxLarge)

// ❌ Outdated: Fixed font sizes
Text("Title")
    .font(.system(size: 24))
```

## Architecture Guidelines

### MVVM with @Observable
```swift
// ✅ View Model with business logic
@Observable
final class BookDetailViewModel {
    private let bookService: BookService
    private(set) var book: Book
    private(set) var isLoading = false
    private(set) var error: Error?
    
    init(book: Book, bookService: BookService) {
        self.book = book
        self.bookService = bookService
    }
    
    func refresh() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            book = try await bookService.fetchBook(id: book.id)
        } catch {
            self.error = error
        }
    }
}

// ✅ Lightweight view
struct BookDetailView: View {
    let viewModel: BookDetailViewModel
    
    var body: some View {
        ScrollView {
            content
        }
        .task { await viewModel.refresh() }
    }
    
    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            ProgressView()
        } else {
            VStack(alignment: .leading, spacing: 16) {
                Text(viewModel.book.title)
                    .font(.title)
                Text(viewModel.book.author)
                    .font(.subheadline)
            }
        }
    }
}
```

## Common Migrations

### From Core Data to SwiftData
1. Replace `@NSManaged` with direct properties
2. Replace `@FetchRequest` with `@Query`
3. Replace `NSManagedObjectContext` with `ModelContext`
4. Replace Core Data predicates with native Swift expressions

### From Combine to Observation
1. Replace `ObservableObject` with `@Observable`
2. Remove `@Published` property wrappers
3. Replace `@StateObject` with direct initialization
4. Replace `sink` with direct observation

### From GCD to Swift Concurrency
1. Replace `DispatchQueue.main.async` with `@MainActor`
2. Replace completion handlers with `async/await`
3. Replace dispatch groups with `TaskGroup`
4. Replace dispatch barriers with `actor` isolation
