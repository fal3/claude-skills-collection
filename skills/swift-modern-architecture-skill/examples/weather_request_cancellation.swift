import Foundation
import Observation

struct City: Identifiable, Hashable, Sendable {
    let id: UUID
    let name: String
}

struct Forecast: Equatable, Sendable {
    let summary: String
}

protocol WeatherClient: Sendable {
    func forecast(for city: City) async throws -> Forecast
}

@MainActor
@Observable
final class WeatherFeature {
    private let client: any WeatherClient
    @ObservationIgnored
    private var requestTask: Task<Void, Never>?
    @ObservationIgnored
    private var requestGeneration = 0

    private(set) var selectedCity: City?
    private(set) var forecast: Forecast?
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    init(client: any WeatherClient) {
        self.client = client
    }

    func select(_ city: City) {
        requestGeneration += 1
        let generation = requestGeneration
        requestTask?.cancel()

        selectedCity = city
        forecast = nil
        errorMessage = nil
        isLoading = true

        requestTask = Task { [weak self, client] in
            do {
                let newForecast = try await client.forecast(for: city)
                try Task.checkCancellation()
                guard let self,
                      requestGeneration == generation,
                      selectedCity?.id == city.id else { return }

                forecast = newForecast
                isLoading = false
            } catch is CancellationError {
                guard let self, requestGeneration == generation else { return }
                isLoading = false
            } catch {
                guard let self,
                      requestGeneration == generation,
                      selectedCity?.id == city.id else { return }

                errorMessage = "The forecast could not be loaded."
                isLoading = false
            }
        }
    }

    func cancel() {
        requestGeneration += 1
        requestTask?.cancel()
        requestTask = nil
        isLoading = false
    }

    deinit {
        requestTask?.cancel()
    }
}
