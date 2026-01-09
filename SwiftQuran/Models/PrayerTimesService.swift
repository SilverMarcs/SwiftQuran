//
//  PrayerTimesService.swift
//  SwiftQuran
//
//  Created by Zabir Raihan on 18/07/2025.
//

import Foundation
import CoreLocation
@unsafe @preconcurrency import MapKit
import WidgetKit

@MainActor
@Observable
class PrayerTimesService {
    static let shared = PrayerTimesService()
    
    private let userDefaults = UserDefaults(suiteName: "group.com.temporary.SwiftQuran")
    private let storageKey = "prayer_times"
    
    private init() {}
    
    // MARK: - Data Loading
    
    func loadStoredPrayerData() -> PersistedPrayerTimes? {
        guard let data = userDefaults?.data(forKey: storageKey),
              let persisted = try? JSONDecoder().decode(PersistedPrayerTimes.self, from: data) else {
            return nil
        }
        return persisted
    }
    
    func loadStoredPrayerTimes() -> PrayerTimes? {
        return loadStoredPrayerData()?.prayerTimes
    }
    
    func loadStoredLocationData() -> LocationData? {
        return loadStoredPrayerData()?.location
    }
    
    // MARK: - Prayer Times Fetching
    
    func fetchPrayerTimes(latitude: Double, longitude: Double) async throws -> PrayerTimes {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.aladhan.com"
        components.path = "/v1/timings"
        components.queryItems = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "method", value: "2")
        ]

        guard let url = components.url else {
            throw PrayerTimesError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(AlAdhanResponse.self, from: data)
        let timings = response.data.timings
        let rawTimes = PrayerTimes(
            Fajr: timings.Fajr,
            Duha: timings.Sunrise ?? timings.Fajr,
            Dhuhr: timings.Dhuhr,
            Asr: timings.Asr,
            Maghrib: timings.Maghrib,
            Isha: timings.Isha
        )
        return PrayerTimes.formatted(from: rawTimes)
    }
    
    func fetchAndStorePrayerTimes(for locationData: LocationData) async throws {
        let prayerTimes = try await fetchPrayerTimes(latitude: locationData.latitude, longitude: locationData.longitude)
        let persisted = PersistedPrayerTimes(prayerTimes: prayerTimes, lastFetched: Date(), location: locationData)
        
        guard let encoded = try? JSONEncoder().encode(persisted) else {
            throw PrayerTimesError.encodingFailed
        }
        
        userDefaults?.set(encoded, forKey: storageKey)
        
        // Reload widget timelines after storing new prayer times
        reloadWidgetTimelines()
    }
    
    func fetchPrayerTimesForStoredLocation() async throws {
        guard let locationData = loadStoredLocationData() else {
            throw PrayerTimesError.noStoredLocation
        }
        try await fetchAndStorePrayerTimes(for: locationData)
    }
    
    // MARK: - Widget Management
    
    func reloadWidgetTimelines() {
        // Only reload if we have prayer times data to show
        if loadStoredPrayerTimes() != nil {
            WidgetCenter.shared.reloadTimelines(ofKind: "PrayerTimeWidget")
        }
    }
    
    // Convenience method to reload widgets from anywhere in the app
    static func reloadWidgets() {
        shared.reloadWidgetTimelines()
    }
    
    // MARK: - Location Services
    
    func reverseGeocode(latitude: Double, longitude: Double) async throws -> String {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        guard let request = MKReverseGeocodingRequest(location: location) else {
            throw PrayerTimesError.reverseGeocodingFailed
        }
        
        let mapItems = try await request.mapItems
        let mapItem = mapItems.first
        
        if let address = mapItem?.address {
            // ths seems to be running usually
            return address.fullAddress
        } else {
            return mapItem?.addressRepresentations?.cityWithContext ?? "Unknown Location"
        }
    }
    
    // MARK: - Utilities
    
    func shouldFetchNewTimes() -> Bool {
        guard let lastFetched = loadStoredPrayerData()?.lastFetched else { return true }
        let calendar = Calendar.current
        return !calendar.isDateInToday(lastFetched)
    }
}

// MARK: - Errors

enum PrayerTimesError: Error {
    case invalidURL
    case encodingFailed
    case noStoredLocation
    case reverseGeocodingFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL for prayer times API"
        case .encodingFailed:
            return "Failed to encode prayer times data"
        case .noStoredLocation:
            return "No stored location data found"
        case .reverseGeocodingFailed:
            return "Failed to reverse geocode location"
        }
    }
}

private struct AlAdhanResponse: Decodable {
    let data: AlAdhanData
}

private struct AlAdhanData: Decodable {
    let timings: AlAdhanTimings
}

private struct AlAdhanTimings: Decodable {
    let Fajr: String
    let Sunrise: String?
    let Dhuhr: String
    let Asr: String
    let Maghrib: String
    let Isha: String
}
