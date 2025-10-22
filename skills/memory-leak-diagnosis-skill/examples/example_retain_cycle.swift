// PROBLEMATIC CODE - Retain Cycle
class NetworkManagerBad {
    var completionHandler: (() -> Void)?
    
    func fetchData() {
        // This creates a retain cycle: self -> completionHandler -> self
        self.completionHandler = {
            print("Data fetched")
            self.processData() // 'self' is strongly captured
        }
        
        // Simulate async operation
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            self.completionHandler?()
        }
    }
    
    func processData() {
        print("Processing data")
    }
    
    deinit {
        print("NetworkManagerBad deallocated")
    }
}

// FIXED CODE - Using weak self
class NetworkManagerGood {
    var completionHandler: (() -> Void)?
    
    func fetchData() {
        // Use [weak self] to break the retain cycle
        self.completionHandler = { [weak self] in
            print("Data fetched")
            self?.processData() // 'self' is now weakly captured
        }
        
        // Simulate async operation
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            self.completionHandler?()
        }
    }
    
    func processData() {
        print("Processing data")
    }
    
    deinit {
        print("NetworkManagerGood deallocated") // This will now print!
    }
}

// Usage example
func testMemoryLeak() {
    print("Creating NetworkManagerBad...")
    var managerBad: NetworkManagerBad? = NetworkManagerBad()
    managerBad?.fetchData()
    managerBad = nil // Won't deallocate due to retain cycle
    
    print("Creating NetworkManagerGood...")
    var managerGood: NetworkManagerGood? = NetworkManagerGood()
    managerGood?.fetchData()
    managerGood = nil // Will deallocate properly
    
    // Give time for async operations
    RunLoop.current.run(until: Date(timeIntervalSinceNow: 2))
}