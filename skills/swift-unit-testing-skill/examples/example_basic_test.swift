import Testing

// Standalone teaching fixture. In an app, put this type in the production
// module and replace it here with `@testable import AppModule`.
enum SampleCalculator {
    static func divide(_ numerator: Int, by denominator: Int) throws -> Int {
        guard denominator != 0 else { throw CalculationError.divisionByZero }
        return numerator / denominator
    }

    enum CalculationError: Error, Equatable {
        case divisionByZero
    }
}

@Suite("Integer division")
struct SampleCalculatorTests {
    @Test("Returns the integer quotient", arguments: [
        (numerator: 12, denominator: 3, expected: 4),
        (numerator: 9, denominator: 2, expected: 4),
        (numerator: -8, denominator: 2, expected: -4),
    ])
    func quotient(example: (numerator: Int, denominator: Int, expected: Int)) throws {
        let value = try SampleCalculator.divide(example.numerator, by: example.denominator)
        #expect(value == example.expected)
    }

    @Test("Rejects a zero denominator")
    func zeroDenominator() {
        #expect(throws: SampleCalculator.CalculationError.divisionByZero) {
            try SampleCalculator.divide(1, by: 0)
        }
    }

    @Test("A required optional stops dependent assertions")
    func requireExample() throws {
        let values = [2, 4, 6]
        let first = try #require(values.first)
        #expect(first.isMultiple(of: 2))
    }
}
