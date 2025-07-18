//
//  LocationStore.swift
//  SwiftQuran
//
//  Created by Zabir Raihan on 18/07/2025.
//

import SwiftUI
import CoreLocation
import MapKit

struct LocationData {
    @AppStorage("last_latitude", store: UserDefaults(suiteName: "group.com.temporary.SwiftQuran")) var latitude: Double?
    @AppStorage("last_longitude", store: UserDefaults(suiteName: "group.com.temporary.SwiftQuran")) var longitude: Double?
    @AppStorage("location_name", store: UserDefaults(suiteName: "group.com.temporary.SwiftQuran")) var locationName: String?
}

@Observable class LocationStore: NSObject, CLLocationManagerDelegate {
    var locationData = LocationData()
    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
    }

    var hasStoredLocation: Bool {
        locationData.latitude != nil && locationData.longitude != nil
    }

    func requestLocation() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            print("Location access denied")
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        @unknown default:
            break
        }
    }

    func saveLocation(latitude: Double, longitude: Double) {
        locationData.latitude = latitude
        locationData.longitude = longitude
        Task {
            await reverseGeocode(latitude: latitude, longitude: longitude)
        }
    }

    // MARK: - Reverse Geocoding with MKReverseGeocodingRequest
    func reverseGeocode(latitude: Double, longitude: Double) async {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        guard let request = MKReverseGeocodingRequest(location: location) else {
            print("Failed to create reverse geocoding request")
            return
        }
        do {
            let mapItems = try await request.mapItems
            let mapItem = mapItems.first
            let name = mapItem?.addressRepresentations?.regionName ?? "Unknown Location"
            self.locationData.locationName = name
        } catch {
            print("Error reverse geocoding location: \(error)")
        }
    }

    func getLocation() -> (latitude: Double, longitude: Double, name: String?)? {
        guard let lat = locationData.latitude,
              let lon = locationData.longitude else { return nil }
        return (lat, lon, locationData.locationName)
    }

    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        saveLocation(latitude: location.coordinate.latitude,
                     longitude: location.coordinate.longitude)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
}
