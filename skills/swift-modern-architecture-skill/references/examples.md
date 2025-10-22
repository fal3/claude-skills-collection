# Complete Example Implementations

## Example 1: Modern Todo App with SwiftData

### Models
```swift
import SwiftData
import Foundation

@Model
final class Todo {
    var title: String
    var isCompleted: Bool
    var createdAt: Date
    var category: Category?
    
    init(title: String, isCompleted: Bool = false) {
        self.title = title
        self.isCompleted = isCompleted
        self.createdAt = Date()
    }
}

@Model
final class Category {
    var name: String
    var color: String
    @Relationship(deleteRule: .cascade) var todos: [Todo]
    
    init(name: String, color: String) {
        self.name = name
        self.color = color
        self.todos = []
    }
}
```

### View Model
```swift
import Observation
import SwiftData

@Observable
final class TodoListViewModel {
    private let modelContext: ModelContext
    var searchText = ""
    var showCompleted = true
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func addTodo(title: String, category: Category? = nil) {
        let todo = Todo(title: title)
        todo.category = category
        modelContext.insert(todo)
        try? modelContext.save()
    }
    
    func toggleCompletion(_ todo: Todo) {
        todo.isCompleted.toggle()
        try? modelContext.save()
    }
    
    func deleteTodo(_ todo: Todo) {
        modelContext.delete(todo)
        try? modelContext.save()
    }
}
```

### Views
```swift
import SwiftUI
import SwiftData

struct TodoListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Todo.createdAt, order: .reverse) private var todos: [Todo]
    @State private var viewModel: TodoListViewModel?
    @State private var newTodoTitle = ""
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredTodos) { todo in
                    TodoRow(todo: todo, viewModel: viewModel)
                }
                .onDelete(perform: deleteTodos)
            }
            .searchable(text: searchBinding)
            .navigationTitle("Todos")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Add", systemImage: "plus") {
                        showAddTodo()
                    }
                }
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = TodoListViewModel(modelContext: modelContext)
            }
        }
    }
    
    private var filteredTodos: [Todo] {
        guard let viewModel, !viewModel.searchText.isEmpty else {
            return todos
        }
        return todos.filter { 
            $0.title.localizedCaseInsensitiveContains(viewModel.searchText) 
        }
    }
    
    private var searchBinding: Binding<String> {
        Binding(
            get: { viewModel?.searchText ?? "" },
            set: { viewModel?.searchText = $0 }
        )
    }
    
    private func deleteTodos(at offsets: IndexSet) {
        for index in offsets {
            viewModel?.deleteTodo(todos[index])
        }
    }
    
    private func showAddTodo() {
        // Implementation
    }
}

struct TodoRow: View {
    let todo: Todo
    let viewModel: TodoListViewModel?
    
    var body: some View {
        HStack {
            Button {
                viewModel?.toggleCompletion(todo)
            } label: {
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(todo.isCompleted ? .green : .gray)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading) {
                Text(todo.title)
                    .strikethrough(todo.isCompleted)
                if let category = todo.category {
                    Text(category.name)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
```

### App Entry
```swift
import SwiftUI
import SwiftData

@main
struct TodoApp: App {
    var body: some Scene {
        WindowGroup {
            TodoListView()
        }
        .modelContainer(for: [Todo.self, Category.self])
    }
}
```

## Example 2: Weather App with Modern API Client

### Network Layer
```swift
import Foundation

actor WeatherAPIClient {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let baseURL = URL(string: "https://api.weather.com")!
    
    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }
    
    func fetchWeather(for city: String) async throws -> Weather {
        let endpoint = WeatherEndpoint.current(city: city)
        return try await fetch(endpoint)
    }
    
    func fetchForecast(for city: String) async throws -> [WeatherForecast] {
        let endpoint = WeatherEndpoint.forecast(city: city)
        return try await fetch(endpoint)
    }
    
    private func fetch<T: Decodable>(_ endpoint: WeatherEndpoint) async throws -> T {
        let request = endpoint.makeRequest(baseURL: baseURL)
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(httpResponse.statusCode)
        }
        
        return try decoder.decode(T.self, from: data)
    }
}

enum WeatherEndpoint {
    case current(city: String)
    case forecast(city: String)
    
    func makeRequest(baseURL: URL) -> URLRequest {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)!
        
        switch self {
        case .current(let city):
            components.path = "/current"
            components.queryItems = [URLQueryItem(name: "city", value: city)]
        case .forecast(let city):
            components.path = "/forecast"
            components.queryItems = [URLQueryItem(name: "city", value: city)]
        }
        
        return URLRequest(url: components.url!)
    }
}

enum APIError: LocalizedError {
    case invalidResponse
    case httpError(Int)
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            "Invalid server response"
        case .httpError(let code):
            "HTTP error: \(code)"
        case .decodingError:
            "Failed to decode response"
        }
    }
}
```

### Models
```swift
import Foundation

struct Weather: Codable, Identifiable {
    let id: UUID
    let temperature: Double
    let condition: WeatherCondition
    let humidity: Int
    let windSpeed: Double
    let city: String
    let timestamp: Date
}

enum WeatherCondition: String, Codable {
    case sunny, cloudy, rainy, snowy, stormy
    
    var icon: String {
        switch self {
        case .sunny: "sun.max.fill"
        case .cloudy: "cloud.fill"
        case .rainy: "cloud.rain.fill"
        case .snowy: "cloud.snow.fill"
        case .stormy: "cloud.bolt.fill"
        }
    }
}

struct WeatherForecast: Codable, Identifiable {
    let id: UUID
    let date: Date
    let highTemp: Double
    let lowTemp: Double
    let condition: WeatherCondition
}
```

### View Model
```swift
import Observation

@MainActor
@Observable
final class WeatherViewModel {
    private let apiClient: WeatherAPIClient
    
    private(set) var currentWeather: Weather?
    private(set) var forecast: [WeatherForecast] = []
    private(set) var isLoading = false
    private(set) var error: Error?
    
    var selectedCity = "San Francisco" {
        didSet {
            Task {
                await loadWeather()
            }
        }
    }
    
    init(apiClient: WeatherAPIClient = WeatherAPIClient()) {
        self.apiClient = apiClient
    }
    
    func loadWeather() async {
        isLoading = true
        error = nil
        defer { isLoading = false }
        
        do {
            async let weather = apiClient.fetchWeather(for: selectedCity)
            async let forecasts = apiClient.fetchForecast(for: selectedCity)
            
            (currentWeather, forecast) = try await (weather, forecasts)
        } catch {
            self.error = error
        }
    }
}
```

### View
```swift
import SwiftUI

struct WeatherView: View {
    @State private var viewModel = WeatherViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if viewModel.isLoading {
                        ProgressView()
                    } else if let weather = viewModel.currentWeather {
                        currentWeatherView(weather)
                        forecastList
                    } else if let error = viewModel.error {
                        errorView(error)
                    }
                }
                .padding()
            }
            .navigationTitle("Weather")
            .task {
                await viewModel.loadWeather()
            }
            .refreshable {
                await viewModel.loadWeather()
            }
        }
    }
    
    @ViewBuilder
    private func currentWeatherView(_ weather: Weather) -> some View {
        VStack(spacing: 12) {
            Image(systemName: weather.condition.icon)
                .font(.system(size: 60))
                .foregroundStyle(.blue)
            
            Text("\(Int(weather.temperature))°")
                .font(.system(size: 72, weight: .thin))
            
            Text(weather.condition.rawValue.capitalized)
                .font(.title2)
            
            HStack(spacing: 30) {
                weatherDetail("Humidity", value: "\(weather.humidity)%")
                weatherDetail("Wind", value: "\(Int(weather.windSpeed)) mph")
            }
        }
    }
    
    private func weatherDetail(_ label: String, value: String) -> some View {
        VStack {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline)
        }
    }
    
    @ViewBuilder
    private var forecastList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("5-Day Forecast")
                .font(.headline)
            
            ForEach(viewModel.forecast) { day in
                ForecastRow(forecast: day)
            }
        }
    }
    
    @ViewBuilder
    private func errorView(_ error: Error) -> some View {
        ContentUnavailableView {
            Label("Unable to Load Weather", systemImage: "exclamationmark.triangle")
        } description: {
            Text(error.localizedDescription)
        } actions: {
            Button("Try Again") {
                Task { await viewModel.loadWeather() }
            }
        }
    }
}

struct ForecastRow: View {
    let forecast: WeatherForecast
    
    var body: some View {
        HStack {
            Text(forecast.date, style: .date)
                .font(.subheadline)
            
            Spacer()
            
            Image(systemName: forecast.condition.icon)
                .foregroundStyle(.blue)
            
            Text("\(Int(forecast.highTemp))°/\(Int(forecast.lowTemp))°")
                .font(.subheadline)
        }
        .padding()
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}
```

## Example 3: Authentication Flow with Modern Patterns

### Auth Service
```swift
import Foundation

actor AuthenticationService {
    private let apiClient: APIClient
    private var currentSession: UserSession?
    
    init(apiClient: APIClient = APIClient()) {
        self.apiClient = apiClient
    }
    
    func signIn(email: String, password: String) async throws -> UserSession {
        let credentials = Credentials(email: email, password: password)
        let session: UserSession = try await apiClient.post("/auth/signin", body: credentials)
        currentSession = session
        return session
    }
    
    func signUp(email: String, password: String, name: String) async throws -> UserSession {
        let registration = Registration(email: email, password: password, name: name)
        let session: UserSession = try await apiClient.post("/auth/signup", body: registration)
        currentSession = session
        return session
    }
    
    func signOut() async {
        currentSession = nil
        // Clear tokens, etc.
    }
    
    var isAuthenticated: Bool {
        currentSession != nil
    }
}

struct Credentials: Encodable {
    let email: String
    let password: String
}

struct Registration: Encodable {
    let email: String
    let password: String
    let name: String
}

struct UserSession: Codable {
    let token: String
    let user: User
    let expiresAt: Date
}

struct User: Codable, Identifiable {
    let id: UUID
    let email: String
    let name: String
}
```

### View Model
```swift
import Observation

@MainActor
@Observable
final class AuthViewModel {
    private let authService: AuthenticationService
    
    var email = ""
    var password = ""
    var name = ""
    var isLoading = false
    var error: String?
    var isAuthenticated = false
    
    init(authService: AuthenticationService = AuthenticationService()) {
        self.authService = authService
    }
    
    func signIn() async {
        guard validate() else { return }
        
        isLoading = true
        error = nil
        defer { isLoading = false }
        
        do {
            _ = try await authService.signIn(email: email, password: password)
            isAuthenticated = true
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func signUp() async {
        guard validate() else { return }
        
        isLoading = true
        error = nil
        defer { isLoading = false }
        
        do {
            _ = try await authService.signUp(email: email, password: password, name: name)
            isAuthenticated = true
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func signOut() async {
        await authService.signOut()
        isAuthenticated = false
        clearFields()
    }
    
    private func validate() -> Bool {
        error = nil
        
        guard !email.isEmpty else {
            error = "Email is required"
            return false
        }
        
        guard email.contains("@") else {
            error = "Invalid email format"
            return false
        }
        
        guard password.count >= 8 else {
            error = "Password must be at least 8 characters"
            return false
        }
        
        return true
    }
    
    private func clearFields() {
        email = ""
        password = ""
        name = ""
    }
}
```

### Views
```swift
import SwiftUI

struct SignInView: View {
    @Bindable var viewModel: AuthViewModel
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, password
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Sign In")
                .font(.largeTitle)
                .bold()
            
            TextField("Email", text: $viewModel.email)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .focused($focusedField, equals: .email)
                .submitLabel(.next)
                .onSubmit { focusedField = .password }
            
            SecureField("Password", text: $viewModel.password)
                .textContentType(.password)
                .focused($focusedField, equals: .password)
                .submitLabel(.go)
                .onSubmit { Task { await viewModel.signIn() } }
            
            if let error = viewModel.error {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
            
            Button {
                Task { await viewModel.signIn() }
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Sign In")
                        .bold()
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isLoading)
            .frame(maxWidth: .infinity)
        }
        .textFieldStyle(.roundedBorder)
        .padding()
    }
}
```
