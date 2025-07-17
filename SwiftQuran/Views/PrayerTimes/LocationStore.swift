//
//  LocationStore.swift
//  SwiftQuran
//
//  Created by Zabir Raihan on 18/07/2025.
//

import SwiftUI
import CoreLocation

struct LocationData {
    @AppStorage("last_latitude") var latitude: Double?
    @AppStorage("last_longitude") var longitude: Double?
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
    }
    
    func getLocation() -> (latitude: Double, longitude: Double)? {
        guard let lat = locationData.latitude,
              let lon = locationData.longitude else { return nil }
        return (lat, lon)
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
