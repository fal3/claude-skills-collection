import SwiftData
import SwiftUI

@Model
final class Todo {
    var id: UUID
    var title: String
    var isComplete: Bool

    init(id: UUID = UUID(), title: String, isComplete: Bool = false) {
        self.id = id
        self.title = title
        self.isComplete = isComplete
    }
}

@MainActor
struct TodoListScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Todo.title) private var todos: [Todo]

    @State private var searchText = ""
    @State private var newTitle = ""
    @State private var saveErrorMessage: String?

    private var displayedTodos: [Todo] {
        guard !searchText.isEmpty else { return todos }
        return todos.filter {
            $0.title.localizedStandardContains(searchText)
        }
    }

    var body: some View {
        List {
            Section("Add a task") {
                TextField("Title", text: $newTitle)
                Button("Add") { addTodo() }
                    .disabled(newTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }

            Section("Tasks") {
                ForEach(displayedTodos) { todo in
                    Button {
                        todo.isComplete.toggle()
                        saveOrRollback()
                    } label: {
                        Label(todo.title, systemImage: todo.isComplete ? "checkmark.circle.fill" : "circle")
                    }
                    .buttonStyle(.plain)
                }
                .onDelete(perform: deleteDisplayedTodos)
            }
        }
        .searchable(text: $searchText)
        .alert("Changes were not saved", isPresented: saveErrorIsPresented) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(saveErrorMessage ?? "Try again.")
        }
    }

    private var saveErrorIsPresented: Binding<Bool> {
        Binding(
            get: { saveErrorMessage != nil },
            set: { if !$0 { saveErrorMessage = nil } }
        )
    }

    private func addTodo() {
        let title = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return }
        modelContext.insert(Todo(title: title))
        guard saveOrRollback() else { return }
        newTitle = ""
    }

    private func deleteDisplayedTodos(at offsets: IndexSet) {
        let targets = offsets.compactMap { index in
            displayedTodos.indices.contains(index) ? displayedTodos[index] : nil
        }
        targets.forEach(modelContext.delete)
        saveOrRollback()
    }

    @discardableResult
    private func saveOrRollback() -> Bool {
        do {
            try modelContext.save()
            return true
        } catch {
            modelContext.rollback()
            saveErrorMessage = "Your last change was rolled back."
            return false
        }
    }
}
