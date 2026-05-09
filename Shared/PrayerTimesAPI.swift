import Foundation

enum PrayerTimesAPI {
    static func fetchPrayerTimes(latitude: Double, longitude: Double) async throws -> PrayerTimes {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.aladhan.com"
        components.path = "/v1/timings"
        components.queryItems = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "method", value: "2"),
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
}

enum PrayerTimesError: Error {
    case invalidURL
    case encodingFailed
    case noStoredLocation
    case reverseGeocodingFailed

    var errorDescription: String? {
        switch self {
        case .invalidURL: "Invalid URL for prayer times API"
        case .encodingFailed: "Failed to encode prayer times data"
        case .noStoredLocation: "No stored location data found"
        case .reverseGeocodingFailed: "Failed to reverse geocode location"
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
