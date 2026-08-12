import Foundation

struct ImportRecord: Sendable, Equatable {
    let value: String
}

enum ImportState: Sendable, Equatable {
    case idle
    case running
    case finished(count: Int)
    case failed(message: String)
}

enum ImportFailure: Error, Sendable {
    case invalidUTF8
}

actor ImportStore {
    private var records: [ImportRecord] = []

    func replace(with newRecords: [ImportRecord]) {
        records = newRecords
    }

    func snapshot() -> [ImportRecord] {
        records
    }
}

@concurrent
func decodeRecords(from data: Data) async throws -> [ImportRecord] {
    guard let text = String(data: data, encoding: .utf8) else {
        throw ImportFailure.invalidUTF8
    }

    var records: [ImportRecord] = []
    for (index, line) in text.split(whereSeparator: \.isNewline).enumerated() {
        if index.isMultiple(of: 100) {
            try Task.checkCancellation()
            await Task.yield()
        }
        records.append(ImportRecord(value: String(line)))
    }
    return records
}

@MainActor
final class ImportModel {
    private let store: ImportStore
    private var importTask: Task<Void, Never>?
    private var importGeneration = 0

    private(set) var state: ImportState = .idle

    init(store: ImportStore) {
        self.store = store
    }

    func start(data: Data) {
        importTask?.cancel()
        importGeneration += 1
        let generation = importGeneration
        state = .running

        importTask = Task { [weak self, store] in
            do {
                let records = try await decodeRecords(from: data)
                try Task.checkCancellation()
                guard let self, importGeneration == generation else { return }
                await store.replace(with: records)
                try Task.checkCancellation()
                guard importGeneration == generation else { return }
                state = .finished(count: records.count)
                importTask = nil
            } catch is CancellationError {
                guard let self, importGeneration == generation else { return }
                state = .idle
                importTask = nil
            } catch {
                guard let self, importGeneration == generation else { return }
                state = .failed(message: String(describing: error))
                importTask = nil
            }
        }
    }

    func cancel() {
        importGeneration += 1
        importTask?.cancel()
        importTask = nil
        state = .idle
    }

    deinit {
        importTask?.cancel()
    }
}
