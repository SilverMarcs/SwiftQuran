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
    
    static func formatted(from raw: PrayerTimes) -> PrayerTimes {
        func format(_ time: String) -> String {
            let cleaned = time.replacingOccurrences(of: "%", with: "")
            let components = cleaned.split(separator: " ")
            guard components.count == 2 else { return cleaned }
            let hour = components[0]
            let ampm = components[1].uppercased()
            return "\(hour) \(ampm)"
        }
        
        return PrayerTimes(
            Fajr: format(raw.Fajr),
            Duha: format(raw.Duha),
            Dhuhr: format(raw.Dhuhr),
            Asr: format(raw.Asr),
            Maghrib: format(raw.Maghrib),
            Isha: format(raw.Isha)
        )
    }
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
    
    var color: Color {
         switch self {
         case .fajr: return .indigo // Dawn purple/blue
         case .duha: return .orange // Morning sun
         case .dhuhr: return .yellow // Noon sun
         case .asr: return .orange // Afternoon sun
         case .maghrib: return .pink // Sunset pink
         case .isha: return .blue // Night blue
         }
     }
}
