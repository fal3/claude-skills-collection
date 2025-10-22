import XCTest
@testable import MyApp

class NetworkServiceTests: XCTestCase {
    
    var networkService: NetworkService!
    var mockURLSession: MockURLSession!
    
    override func setUp() {
        super.setUp()
        mockURLSession = MockURLSession()
        networkService = NetworkService(session: mockURLSession)
    }
    
    override func tearDown() {
        networkService = nil
        mockURLSession = nil
        super.tearDown()
    }
    
    func testFetchDataSuccess() {
        // Given
        let expectation = expectation(description: "Fetch data completes")
        let expectedData = "Hello, World!".data(using: .utf8)!
        mockURLSession.data = expectedData
        mockURLSession.response = HTTPURLResponse(url: URL(string: "https://example.com")!,
                                                 statusCode: 200,
                                                 httpVersion: nil,
                                                 headerFields: nil)
        
        // When
        networkService.fetchData(from: URL(string: "https://example.com")!) { result in
            // Then
            switch result {
            case .success(let data):
                XCTAssertEqual(data, expectedData)
            case .failure:
                XCTFail("Expected success but got failure")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchDataFailure() {
        // Given
        let expectation = expectation(description: "Fetch data fails")
        let expectedError = URLError(.notConnectedToInternet)
        mockURLSession.error = expectedError
        
        // When
        networkService.fetchData(from: URL(string: "https://example.com")!) { result in
            // Then
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                XCTAssertEqual((error as? URLError)?.code, .notConnectedToInternet)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}

// Mock classes
class MockURLSession: URLSession {
    var data: Data?
    var response: URLResponse?
    var error: Error?
    
    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let task = MockURLSessionDataTask()
        task.completionHandler = {
            completionHandler(self.data, self.response, self.error)
        }
        return task
    }
}

class MockURLSessionDataTask: URLSessionDataTask {
    var completionHandler: (() -> Void)?
    
    override func resume() {
        completionHandler?()
    }
}

// Production code
class NetworkService {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetchData(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                completion(.success(data))
            }
        }.resume()
    }
}