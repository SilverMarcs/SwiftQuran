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
