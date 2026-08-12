import SwiftUI

struct Place: Identifiable, Hashable {
    let id: Int
    let name: String
}

struct AdaptiveNavigationExample: View {
    private let places = [
        Place(id: 1, name: "Park"),
        Place(id: 2, name: "Museum"),
        Place(id: 3, name: "Library"),
    ]

    var body: some View {
        #if os(iOS) || os(macOS) || os(visionOS)
        SplitNavigation(places: places)
        #else
        StackNavigation(places: places)
        #endif
    }
}

#if os(iOS) || os(macOS) || os(visionOS)
private struct SplitNavigation: View {
    let places: [Place]
    @State private var selection: Place.ID?

    var body: some View {
        NavigationSplitView {
            List(places, selection: $selection) { place in
                Text(place.name)
                    .tag(place.id)
            }
            .navigationTitle("Places")
        } detail: {
            if let selection,
               let place = places.first(where: { $0.id == selection }) {
                PlaceDetail(place: place)
            } else {
                ContentUnavailableView("Select a place", systemImage: "map")
            }
        }
    }
}
#endif

#if os(watchOS) || os(tvOS)
private struct StackNavigation: View {
    let places: [Place]

    var body: some View {
        NavigationStack {
            List(places) { place in
                NavigationLink(value: place) {
                    Text(place.name)
                }
            }
            .navigationTitle("Places")
            .navigationDestination(for: Place.self) { place in
                PlaceDetail(place: place)
            }
        }
    }
}
#endif

private struct PlaceDetail: View {
    let place: Place

    var body: some View {
        Text("Details for \(place.name)")
            .navigationTitle(place.name)
    }
}
