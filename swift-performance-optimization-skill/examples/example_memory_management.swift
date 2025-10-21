class NetworkManager {
    var completionHandler: (() -> Void)?
    
    func fetchData() {
        // BAD: Strong reference cycle
        // self.completionHandler = {
        //     self.processData()
        // }
        
        // GOOD: Weak self to avoid retain cycle
        self.completionHandler = { [weak self] in
            self?.processData()
        }
        
        // Simulate network call
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            self.completionHandler?()
        }
    }
    
    func processData() {
        print("Data processed")
    }
}

// Alternative with unowned for non-optional self
class ViewController {
    var timer: Timer?
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [unowned self] timer in
            self.updateUI()
        }
    }
    
    func updateUI() {
        // Update UI
    }
}