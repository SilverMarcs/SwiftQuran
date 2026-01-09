//
//  PrayerTimesService.swift
//  SwiftQuran Watch App
//
//  Created by Zabir Raihan on 09/01/2026.
//

import Foundation
import CoreLocation
import Observation

@MainActor
@Observable
final class PrayerTimesService {
    static let shared = PrayerTimesService()

    private let userDefaults = UserDefaults.standard
    private let storageKey = "prayer_times"
    private let locationManager = LocationManager()

    private init() {}

    func loadStoredPrayerData() -> PersistedPrayerTimes? {
        guard let data = userDefaults.data(forKey: storageKey),
              let persisted = try? JSONDecoder().decode(PersistedPrayerTimes.self, from: data) else {
            return nil
        }
        return persisted
    }

    func shouldFetchNewTimes() -> Bool {
        guard let lastFetched = loadStoredPrayerData()?.lastFetched else { return true }
        let calendar = Calendar.current
        return !calendar.isDateInToday(lastFetched)
    }

    func fetchPrayerTimesForCurrentLocation() async -> PrayerTimesFetchError? {
        guard let location = await locationManager.requestLocation() else {
            return .locationUnavailable
        }

        let locationData = LocationData(
            latitude: location.latitude,
            longitude: location.longitude,
            locationName: "Current Location"
        )

        do {
            let prayerTimes = try await fetchPrayerTimes(
                latitude: location.latitude,
                longitude: location.longitude
            )
            let persisted = PersistedPrayerTimes(
                prayerTimes: prayerTimes,
                lastFetched: Date(),
                location: locationData
            )

            guard let encoded = try? JSONEncoder().encode(persisted) else {
                return .encodingFailed
            }
            userDefaults.set(encoded, forKey: storageKey)
            PrayerTimesStore.shared.update(with: persisted)
            return nil
        } catch {
            print("Watch failed to fetch prayer times: \(error)")
            return .networkFailed
        }
    }

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
        return formatted(from: rawTimes)
    }

    private func formatted(from raw: PrayerTimes) -> PrayerTimes {
        PrayerTimes(
            Fajr: format(raw.Fajr),
            Duha: format(raw.Duha),
            Dhuhr: format(raw.Dhuhr),
            Asr: format(raw.Asr),
            Maghrib: format(raw.Maghrib),
            Isha: format(raw.Isha)
        )
    }

    private func format(_ time: String) -> String {
        let cleaned = time.replacing("%", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        let components = cleaned.split(separator: " ")
        if components.count == 2 {
            let hour = components[0]
            let ampm = components[1].uppercased()
            return "\(hour) \(ampm)"
        }

        if let date = timeFormatter24.date(from: cleaned) {
            return timeFormatter12.string(from: date)
        }

        return cleaned
    }

    private let timeFormatter12: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "h:mm a"
        return formatter
    }()

    private let timeFormatter24: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
}

enum PrayerTimesError: Error {
    case invalidURL
}

enum PrayerTimesFetchError: String {
    case locationUnavailable = "Location unavailable"
    case encodingFailed = "Failed to save prayer times"
    case networkFailed = "Network request failed"
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
