//
//  UpdatePrayerTimesIntent.swift
//  SwiftQuran
//
//  Created by Zabir Raihan on 18/07/2025.
//

import AppIntents
import WidgetKit
import Foundation

struct UpdatePrayerTimesIntent: @preconcurrency AppIntent {
    static var title: LocalizedStringResource = "Update Prayer Times"
    static var description = IntentDescription("Fetch the latest prayer times")
    
    func perform() async throws -> some IntentResult {
        // Get stored location data
        let locationData = LocationData()
        
        guard let latitude = locationData.latitude,
              let longitude = locationData.longitude else {
            // If no location is stored, return without updating
            return .result()
        }
        
        // Fetch updated prayer times
        await fetchPrayerTimes(latitude: latitude, longitude: longitude)
        
        // Reload widget timelines
        WidgetCenter.shared.reloadTimelines(ofKind: "PrayerTimeWidget")
        
        return .result()
    }
    
    private func fetchPrayerTimes(latitude: Double, longitude: Double) async {
        let timezone = TimeZone.current.identifier
        let urlString = "https://www.islamicfinder.us/index.php/api/prayer_times?latitude=\(latitude)&longitude=\(longitude)&timezone=\(timezone)"
        
        guard let url = URL(string: urlString) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(PrayerTimesResponse.self, from: data)
            let formattedTimes = PrayerTimes.formatted(from: response.results)
            
            // Save to UserDefaults
            let persisted = PersistedPrayerTimes(prayerTimes: formattedTimes, lastFetched: Date())
            if let encoded = try? JSONEncoder().encode(persisted) {
                let userDefaults = UserDefaults(suiteName: "group.com.temporary.SwiftQuran")
                userDefaults?.set(encoded, forKey: "prayer_times")
            }
        } catch {
            print("Error fetching prayer times in intent: \(error)")
        }
    }
}
