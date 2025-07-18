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
    @AppStorage("last_latitude") var latitude: Double?
    @AppStorage("last_longitude") var longitude: Double?
    @AppStorage("location_name") var locationName: String?
}

@Observable class LocationStore: NSObject, CLLocationManagerDelegate {
    var locationData = LocationData()
    private let locationManager = CLLocationManager()
    private var lastGeocodeTime: Date?
    
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
        
        // Only geocode if sufficient time has passed since last geocode
        let currentTime = Date()
        if let lastTime = lastGeocodeTime,
           currentTime.timeIntervalSince(lastTime) < 60 {
            return
        }
        
        lastGeocodeTime = currentTime
        
        // Reverse geocode using MKLocalSearch
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let searchRequest = MKLocalSearch.Request()
        searchRequest.region = MKCoordinateRegion(center: location.coordinate,
                                                latitudinalMeters: 1000,
                                                longitudinalMeters: 1000)
        
        let search = MKLocalSearch(request: searchRequest)
        search.start { [weak self] (response, error) in
            guard let self = self,
                  let response = response,
                  let item = response.mapItems.first else { return }
            
            // Create a friendly location string
            var locationComponents: [String] = []
            
            if let name = item.name {
                locationComponents.append(name)
            }
            
//            if let locality = item.placemark.locality {
//                locationComponents.append(locality)
//            }
//            if let administrativeArea = item.placemark.administrativeArea {
//                locationComponents.append(administrativeArea)
//            }
//            if let country = item.placemark.country {
//                locationComponents.append(country)
//            }
            
            let locationString = locationComponents.joined(separator: ", ")
            self.locationData.locationName = locationString
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
