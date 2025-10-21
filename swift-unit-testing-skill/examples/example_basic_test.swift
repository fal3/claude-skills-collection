import XCTest
@testable import MyApp

class CalculatorTests: XCTestCase {
    
    var calculator: Calculator!
    
    override func setUp() {
        super.setUp()
        calculator = Calculator()
    }
    
    override func tearDown() {
        calculator = nil
        super.tearDown()
    }
    
    func testAddition() {
        // Given
        let a = 5
        let b = 3
        
        // When
        let result = calculator.add(a, b)
        
        // Then
        XCTAssertEqual(result, 8, "Addition should return the sum of two numbers")
    }
    
    func testAdditionWithNegativeNumbers() {
        // Given
        let a = 5
        let b = -3
        
        // When
        let result = calculator.add(a, b)
        
        // Then
        XCTAssertEqual(result, 2, "Addition should work with negative numbers")
    }
    
    func testDivisionByZero() {
        // Given
        let a = 10
        let b = 0
        
        // When & Then
        XCTAssertThrowsError(try calculator.divide(a, b)) { error in
            XCTAssertEqual(error as? CalculatorError, CalculatorError.divisionByZero)
        }
    }
}

// Production code
class Calculator {
    func add(_ a: Int, _ b: Int) -> Int {
        return a + b
    }
    
    func divide(_ a: Int, _ b: Int) throws -> Int {
        guard b != 0 else {
            throw CalculatorError.divisionByZero
        }
        return a / b
    }
}

enum CalculatorError: Error {
    case divisionByZero
}