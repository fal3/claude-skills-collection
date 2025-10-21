# Using Instruments to Detect Memory Leaks

## Setup
1. Open Instruments: In Xcode, go to Product > Profile (⌘I)
2. Choose Leaks Instrument: Select the "Leaks" template
3. Configure Recording:
   - Target your app
   - Make sure "Record reference counts" is enabled
   - Start recording

## Usage
4. Use Your App: Navigate through the screens where you suspect leaks
5. Analyze Results:
   - Look for red bars in the Leaks track - these indicate memory leaks
   - The Detail pane shows leaked objects and their allocation backtraces
   - Use the "Cycles & Roots" view to see retain cycles

## Example Output
```
Leaks detected: 5
- Leaked Object: ViewController (0x7f9b8c0a5e00)
  - Responsible Library: UIKit
  - Allocation: -[UIViewController initWithNibName:bundle:]
  - Backtrace shows it was created in viewDidLoad of parent VC
  - Never deallocated because of retain cycle with timer

- Leaked Object: Timer (0x7f9b8c0a6120)
  - Responsible Library: Foundation
  - Allocation: +[NSTimer scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:]
  - Strong reference to target (ViewController) prevents deallocation
```

## Common Leak Patterns

### Timer Retain Cycles
```swift
// BAD
class MyViewController: UIViewController {
    var timer: Timer?
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(update), userInfo: nil, repeats: true)
    }
    
    @objc func update() {
        // Update UI
    }
}

// GOOD
class MyViewController: UIViewController {
    var timer: Timer?
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.update()
        }
    }
    
    func update() {
        // Update UI
    }
    
    deinit {
        timer?.invalidate()
    }
}
```

### Closure Capture Issues
```swift
// BAD
var completion: (() -> Void)?
completion = {
    self.doSomething() // Creates retain cycle
}

// GOOD  
completion = { [weak self] in
    self?.doSomething() // Breaks the cycle
}
```

### Delegate Strong References
```swift
// BAD
class MyObject {
    var delegate: MyDelegate? // Strong reference
}

// GOOD
class MyObject {
    weak var delegate: MyDelegate? // Weak reference
}
```