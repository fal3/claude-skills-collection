import Foundation

@MainActor
final class PollingModel {
    private var task: Task<Void, Never>?
    private(set) var tickCount = 0

    func start() {
        stop()
        task = Task { [weak self] in
            while !Task.isCancelled {
                do {
                    try await Task.sleep(for: .seconds(1))
                } catch {
                    return
                }

                guard let self else { return }
                tickCount += 1
            }
        }
    }

    func stop() {
        task?.cancel()
        task = nil
    }

    deinit {
        task?.cancel()
    }
}
