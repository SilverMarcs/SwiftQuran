import Foundation
import CoreLocation
@unsafe @preconcurrency import MapKit
import WidgetKit

@MainActor
@Observable
class PrayerTimesService {
    static let shared = PrayerTimesService()

    private let userDefaults = UserDefaults(suiteName: "group.com.SilverMarcs.SwiftQuran")
    private let storageKey = "prayer_times"

    private init() {}

    func loadStoredPrayerData() -> PersistedPrayerTimes? {
        guard let data = userDefaults?.data(forKey: storageKey),
              let persisted = try? JSONDecoder().decode(PersistedPrayerTimes.self, from: data) else {
            return nil
        }
        return persisted
    }

    func loadStoredPrayerTimes() -> PrayerTimes? {
        loadStoredPrayerData()?.prayerTimes
    }

    func loadStoredLocationData() -> LocationData? {
        loadStoredPrayerData()?.location
    }

    func fetchAndStorePrayerTimes(for locationData: LocationData) async throws {
        let prayerTimes = try await PrayerTimesAPI.fetchPrayerTimes(
            latitude: locationData.latitude,
            longitude: locationData.longitude
        )
        let persisted = PersistedPrayerTimes(prayerTimes: prayerTimes, lastFetched: Date(), location: locationData)

        guard let encoded = try? JSONEncoder().encode(persisted) else {
            throw PrayerTimesError.encodingFailed
        }

        userDefaults?.set(encoded, forKey: storageKey)
        reloadWidgetTimelines()
    }

    func fetchPrayerTimesForStoredLocation() async throws {
        guard let locationData = loadStoredLocationData() else {
            throw PrayerTimesError.noStoredLocation
        }
        try await fetchAndStorePrayerTimes(for: locationData)
    }

    func reloadWidgetTimelines() {
        if loadStoredPrayerTimes() != nil {
            WidgetCenter.shared.reloadTimelines(ofKind: "IqraPrayerTimes")
        }
    }

    static func reloadWidgets() {
        shared.reloadWidgetTimelines()
    }

    func reverseGeocode(latitude: Double, longitude: Double) async throws -> String {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        guard let request = MKReverseGeocodingRequest(location: location) else {
            throw PrayerTimesError.reverseGeocodingFailed
        }

        let mapItems = try await request.mapItems
        let mapItem = mapItems.first

        if let address = mapItem?.address {
            return address.fullAddress
        } else {
            return mapItem?.addressRepresentations?.cityWithContext ?? "Unknown Location"
        }
    }

    func shouldFetchNewTimes() -> Bool {
        guard let lastFetched = loadStoredPrayerData()?.lastFetched else { return true }
        return !Calendar.current.isDateInToday(lastFetched)
    }
}
