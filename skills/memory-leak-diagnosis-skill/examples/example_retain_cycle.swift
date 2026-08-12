import Foundation

// MARK: - Stored closures

final class CallbackOwner {
    private var callback: (() -> Void)?
    private(set) var invocationCount = 0

    func installLeakingCallback() {
        // Cycle: self -> callback -> self.
        callback = {
            self.invocationCount += 1
        }
    }

    func installNonLeakingCallback() {
        callback = { [weak self] in
            self?.invocationCount += 1
        }
    }

    func invoke() {
        callback?()
    }

    func stop() {
        // Explicitly clearing a one-shot or canceled callback also breaks ownership.
        callback = nil
    }
}

// MARK: - Delegate ownership

@MainActor
protocol DataManagerDelegate: AnyObject {
    func dataManagerDidUpdate()
}

@MainActor
final class StrongDelegateManager {
    var delegate: (any DataManagerDelegate)?
}

@MainActor
final class StrongDelegateOwner: DataManagerDelegate {
    let manager = StrongDelegateManager()

    init() {
        // Cycle: owner -> manager -> delegate -> owner.
        manager.delegate = self
    }

    func dataManagerDidUpdate() {}
}

@MainActor
final class WeakDelegateManager {
    weak var delegate: (any DataManagerDelegate)?
}

@MainActor
final class WeakDelegateOwner: DataManagerDelegate {
    let manager = WeakDelegateManager()

    init() {
        // No delegate cycle because the reverse link is weak.
        manager.delegate = self
    }

    func dataManagerDidUpdate() {}
}

// MARK: - Bidirectional ownership

final class PersonWithStrongCar {
    var car: StrongCar?
}

final class StrongCar {
    var owner: PersonWithStrongCar?
}

final class PersonWithWeakCarOwner {
    var car: WeakOwnerCar?
}

final class WeakOwnerCar {
    weak var owner: PersonWithWeakCarOwner?
}

// MARK: - Value containers can participate in cycles

struct CallbackBox {
    var onEvent: (() -> Void)?
}

final class ValueContainerOwner {
    private var callbacks = CallbackBox()

    func installLeakingCallback() {
        // self -> struct property -> closure -> self.
        callbacks.onEvent = {
            self.handleEvent()
        }
    }

    func stop() {
        callbacks.onEvent = nil
    }

    private func handleEvent() {}
}

// MARK: - Indefinite task lifetime

@available(iOS 16.0, macOS 13.0, *)
@MainActor
final class PollingModel {
    private var pollingTask: Task<Void, Never>?
    private(set) var pollCount = 0

    func start() {
        stop()
        pollingTask = Task { [weak self] in
            while !Task.isCancelled {
                do {
                    try await Task.sleep(for: .milliseconds(100))
                } catch {
                    return
                }
                // The optional access retains self only for this synchronous call.
                self?.recordPoll()
            }
        }
    }

    func stop() {
        pollingTask?.cancel()
        pollingTask = nil
    }

    private func recordPoll() {
        pollCount += 1
    }

    deinit {
        pollingTask?.cancel()
    }
}
