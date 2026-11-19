import Foundation
import MapKit
import CoreLocation
import Observation

struct NearbyPlace: Identifiable {
    let id = UUID()
    let name: String
    let category: NearbyCategory
    let distanceMeters: Double
    let address: String?

    var distanceLabel: String {
        distanceMeters < 1000
            ? "\(Int(distanceMeters)) m"
            : String(format: "%.1f km", distanceMeters / 1000)
    }
}

// Searches real nearby places (pharmacy, ATM, supermarket, mall, store) around a
// fixed coordinate — the hotel — using Apple's own MapKit, no API key or account
// needed. Queries a plain coordinate, not the device's location, so no location
// permission prompt is triggered.
@MainActor
@Observable
final class NearbyPlacesService {
    private(set) var results: [NearbyPlace] = []
    private(set) var isLoading = false
    private(set) var hasSearched = false

    func search(categories: Set<NearbyCategory>, around coordinate: CLLocationCoordinate2D) async {
        guard !categories.isEmpty else {
            results = []
            hasSearched = false
            return
        }

        isLoading = true
        let origin = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

        let found = await withTaskGroup(of: [NearbyPlace].self) { group -> [NearbyPlace] in
            for category in categories {
                group.addTask {
                    let request = MKLocalSearch.Request()
                    request.naturalLanguageQuery = category.searchTerm
                    request.region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
                    request.resultTypes = .pointOfInterest

                    guard let response = try? await MKLocalSearch(request: request).start() else {
                        return []
                    }
                    return response.mapItems.prefix(3).compactMap { item -> NearbyPlace? in
                        guard let name = item.name else { return nil }
                        let itemLocation = CLLocation(
                            latitude: item.placemark.coordinate.latitude,
                            longitude: item.placemark.coordinate.longitude
                        )
                        return NearbyPlace(
                            name: name,
                            category: category,
                            distanceMeters: origin.distance(from: itemLocation),
                            address: item.placemark.thoroughfare
                        )
                    }
                }
            }
            var all: [NearbyPlace] = []
            for await places in group { all.append(contentsOf: places) }
            return all
        }

        results = found.sorted { $0.distanceMeters < $1.distanceMeters }
        hasSearched = true
        isLoading = false
    }
}
