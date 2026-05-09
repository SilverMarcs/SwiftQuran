//
//  PrayerTimeType.swift
//  SwiftQuran Watch App
//
//  Created by Zabir Raihan on 09/01/2026.
//

import SwiftUI

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
        case .fajr: return .indigo
        case .duha: return .orange
        case .dhuhr: return .yellow
        case .asr: return .orange
        case .maghrib: return .pink
        case .isha: return .blue
        }
    }
}
