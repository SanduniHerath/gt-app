import Foundation
import SwiftUI
import MapKit
import CoreLocation
import Combine

class NearbyExpertsMapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {

    // MARK: - Published State
    @Published var offices: [AgriculturalOffice] = AgriculturalOffice.samples
    @Published var selectedOffice: AgriculturalOffice? = nil
    @Published var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 7.8731, longitude: 80.7718),
            span: MKCoordinateSpan(latitudeDelta: 3.0, longitudeDelta: 3.0)
        )
    )
    @Published var route: MKRoute? = nil
    @Published var isLoadingRoute: Bool = false
    @Published var routeError: String? = nil
    @Published var showDetailCard: Bool = false

    // MARK: - Constants
    private let nearbyRadiusKm: Double = 200.0

    // MARK: - Private
    private var locationManager: CLLocationManager?
    @Published private(set) var userLocation: CLLocation?

    // MARK: - Computed: Nearby offices sorted by distance
    var nearbyOffices: [AgriculturalOffice] {
        let reference = effectiveLocation
        return offices
            .filter { office in
                let officeLocation = CLLocation(
                    latitude: office.coordinate.latitude,
                    longitude: office.coordinate.longitude
                )
                let distanceKm = reference.distance(from: officeLocation) / 1000
                return distanceKm <= nearbyRadiusKm
            }
            .sorted { a, b in
                let locA = CLLocation(latitude: a.coordinate.latitude, longitude: a.coordinate.longitude)
                let locB = CLLocation(latitude: b.coordinate.latitude, longitude: b.coordinate.longitude)
                return reference.distance(from: locA) < reference.distance(from: locB)
            }
    }

    /// Returns real GPS location if available AND near Sri Lanka, otherwise Colombo fallback
    var effectiveLocation: CLLocation {
        if let loc = userLocation, isNearSriLanka(loc) {
            return loc
        }
        return CLLocation(latitude: 6.9271, longitude: 79.8612) // Colombo city center
    }

    /// True when we're using Colombo as fallback (simulator or location outside Sri Lanka)
    var usingLocationFallback: Bool {
        guard let loc = userLocation else { return true }
        return !isNearSriLanka(loc)
    }

    private func isNearSriLanka(_ location: CLLocation) -> Bool {
        let sriLankaCenter = CLLocation(latitude: 7.8731, longitude: 80.7718)
        return location.distance(from: sriLankaCenter) < 500_000 // 500 km radius
    }

    var nearbyCount: Int { nearbyOffices.count }


    // MARK: - Init
    override init() {
        super.init()
        let manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager = manager
        manager.requestWhenInUseAuthorization()
    }

    // MARK: - CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse ||
           manager.authorizationStatus == .authorizedAlways {
            manager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        // Store location silently for distance/direction calculations only.
        // We do NOT auto-center the map — it always opens on Sri Lanka.
        userLocation = location
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Location error: \(error.localizedDescription)")
    }

    // MARK: - Pin Selection

    func selectOffice(_ office: AgriculturalOffice) {
        if selectedOffice?.id != office.id { route = nil }
        selectedOffice = office
        showDetailCard = true
        withAnimation {
            cameraPosition = .region(MKCoordinateRegion(
                center: office.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
            ))
        }
    }

    func dismissDetailCard() {
        showDetailCard = false
        selectedOffice = nil
        route = nil
    }

    // MARK: - Open in Apple Maps
    func openInAppleMaps(_ office: AgriculturalOffice) {
        let start = effectiveLocation.coordinate
        let destination = office.coordinate
        
        // Use the Apple Maps URL scheme to force a route between two specific points
        let urlString = "http://maps.apple.com/?saddr=\(start.latitude),\(start.longitude)&daddr=\(destination.latitude),\(destination.longitude)&dirflg=d"
        
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }

    // MARK: - Helpers

    func formattedDistance(to office: AgriculturalOffice) -> String? {
        let reference = effectiveLocation
        let meters = reference.distance(from: CLLocation(
            latitude: office.coordinate.latitude,
            longitude: office.coordinate.longitude
        ))
        return meters < 1000
            ? String(format: "%.0f m away", meters)
            : String(format: "%.1f km away", meters / 1000)
    }

    func formattedETA(from route: MKRoute) -> String {
        let mins = Int(route.expectedTravelTime / 60)
        return mins < 60 ? "\(mins) min drive" : "\(mins/60)h \(mins%60)m drive"
    }
}
