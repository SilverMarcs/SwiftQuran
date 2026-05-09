import CoreLocation
import Foundation
import Observation
import WidgetKit

@MainActor
@Observable
final class PrayerTimesService {
    static let shared = PrayerTimesService()

    private let standardDefaults = UserDefaults.standard
    private let appGroupDefaults = UserDefaults(suiteName: "group.com.SilverMarcs.SwiftQuran")
    private let storageKey = "prayer_times"
    private let locationManager = LocationManager()

    private init() {}

    func loadStoredPrayerData() -> PersistedPrayerTimes? {
        guard let data = readStoredData(),
              let persisted = try? JSONDecoder().decode(PersistedPrayerTimes.self, from: data) else {
            return nil
        }
        return persisted
    }

    func shouldFetchNewTimes() -> Bool {
        guard let lastFetched = loadStoredPrayerData()?.lastFetched else { return true }
        return !Calendar.current.isDateInToday(lastFetched)
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
            let prayerTimes = try await PrayerTimesAPI.fetchPrayerTimes(
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
            writeStoredData(encoded)
            PrayerTimesStore.shared.update(with: persisted)
            WidgetCenter.shared.reloadTimelines(ofKind: "IqraWidget")
            return nil
        } catch {
            print("Watch failed to fetch prayer times: \(error)")
            return .networkFailed
        }
    }

    private func readStoredData() -> Data? {
        appGroupDefaults?.data(forKey: storageKey) ?? standardDefaults.data(forKey: storageKey)
    }

    private func writeStoredData(_ data: Data) {
        standardDefaults.set(data, forKey: storageKey)
        appGroupDefaults?.set(data, forKey: storageKey)
    }
}

enum PrayerTimesFetchError: String {
    case locationUnavailable = "Location unavailable"
    case encodingFailed = "Failed to save prayer times"
    case networkFailed = "Network request failed"
}
