//
//  PrayerTimesResponse.swift
//  SwiftQuran
//
//  Created by Zabir Raihan on 17/07/2025.
//

import SwiftUI

// PrayerTimesResponse.swift
struct PrayerTimesResponse: Codable {
    let results: PrayerTimes
    let settings: Settings
    let success: Bool
}

struct PrayerTimes: Codable {
    let Fajr: String
    let Duha: String
    let Dhuhr: String
    let Asr: String
    let Maghrib: String
    let Isha: String
}

struct Settings: Codable {
    let latitude: String
    let longitude: String
    let timezone: String
}

struct PersistedPrayerTimes: Codable {
    let prayerTimes: PrayerTimes
    let lastFetched: Date
}

enum PrayerTimeType: String, CaseIterable, Codable, Identifiable {
    case fajr = "Fajr"
    case duha = "Duha"
    case dhuhr = "Dhuhr"
    case asr = "Asr"
    case maghrib = "Maghrib"
    case isha = "Isha"

    var id: String { rawValue }
    var label: String { rawValue }
    var symbol: String {
        switch self {
        case .fajr: return "sunrise"
        case .duha: return "sun.max"
        case .dhuhr: return "sun.max.fill"
        case .asr: return "sunset"
        case .maghrib: return "moon.stars"
        case .isha: return "moon.fill"
        }
    }
}
