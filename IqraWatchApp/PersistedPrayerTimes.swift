//
//  PersistedPrayerTimes.swift
//  SwiftQuran Watch App
//
//  Created by Zabir Raihan on 09/01/2026.
//

import Foundation

struct PersistedPrayerTimes: Codable {
    let prayerTimes: PrayerTimes
    let lastFetched: Date
    let location: LocationData?
}
