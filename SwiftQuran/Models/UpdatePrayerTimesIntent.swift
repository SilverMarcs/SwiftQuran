//
//  UpdatePrayerTimesIntent.swift
//  SwiftQuran
//
//  Created by Zabir Raihan on 18/07/2025.
//

import AppIntents
import WidgetKit

struct UpdatePrayerTimesIntent: AppIntent {
    static var title: LocalizedStringResource = "Update Prayer Times"
    static var description = IntentDescription("Fetch the latest prayer times")
    
    func perform() async throws -> some IntentResult {
        // Get stored location data and fetch updated prayer times for that location
        try await PrayerTimesService.shared.fetchPrayerTimesForStoredLocation()
        
        // Future: Could add option to get fresh location here
        // let locationManager = LocationManager()
        // if let newLocation = await locationManager.requestLocation() {
        //     let locationName = try await PrayerTimesService.shared.reverseGeocode(
        //         latitude: newLocation.latitude, 
        //         longitude: newLocation.longitude
        //     )
        //     let locationData = LocationData(
        //         latitude: newLocation.latitude,
        //         longitude: newLocation.longitude,
        //         locationName: locationName
        //     )
        //     try await PrayerTimesService.shared.fetchAndStorePrayerTimes(for: locationData)
        // }
        
        // Widget timeline reload is handled automatically by PrayerTimesService
        
        return .result()
    }
}
