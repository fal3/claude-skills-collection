import Foundation
import Testing

struct HTTPResponse: Equatable, Sendable {
    let data: Data
    let statusCode: Int
}

protocol HTTPTransport: Sendable {
    func response(for request: URLRequest) async throws -> HTTPResponse
}

struct URLSessionTransport: HTTPTransport {
    let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func response(for request: URLRequest) async throws -> HTTPResponse {
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkService.Error.invalidResponse
        }
        return HTTPResponse(data: data, statusCode: httpResponse.statusCode)
    }
}

struct StubHTTPTransport: HTTPTransport {
    let handler: @Sendable (URLRequest) async throws -> HTTPResponse

    func response(for request: URLRequest) async throws -> HTTPResponse {
        try await handler(request)
    }
}

struct NetworkService: Sendable {
    enum Error: Swift.Error, Equatable {
        case invalidResponse
        case unacceptableStatus(Int)
    }

    private let transport: any HTTPTransport

    init(transport: any HTTPTransport = URLSessionTransport()) {
        self.transport = transport
    }

    func fetchMessage(from url: URL) async throws -> String {
        let response = try await transport.response(for: URLRequest(url: url))
        guard 200..<300 ~= response.statusCode else {
            throw Error.unacceptableStatus(response.statusCode)
        }
        return String(decoding: response.data, as: UTF8.self)
    }
}

@Suite("Network service")
struct NetworkServiceTests {
    private let endpoint = URL(string: "https://example.invalid/message")!

    @Test("Decodes a successful response")
    func success() async throws {
        let transport = StubHTTPTransport { request in
            #expect(request.url?.host == "example.invalid")
            return HTTPResponse(data: Data("Hello".utf8), statusCode: 200)
        }
        let service = NetworkService(transport: transport)

        let message = try await service.fetchMessage(from: endpoint)

        #expect(message == "Hello")
    }

    @Test("Rejects an unsuccessful status")
    func badStatus() async {
        let transport = StubHTTPTransport { _ in
            HTTPResponse(data: Data(), statusCode: 503)
        }
        let service = NetworkService(transport: transport)

        await #expect(throws: NetworkService.Error.unacceptableStatus(503)) {
            try await service.fetchMessage(from: endpoint)
        }
    }
}
