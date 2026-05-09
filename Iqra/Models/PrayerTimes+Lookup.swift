//
//  PrayerTimes+Lookup.swift
//  SwiftQuran
//
//  Created by Zabir Raihan on 09/01/2026.
//

import Foundation

extension PrayerTimes {
    func time(for type: PrayerTimeType) -> String {
        switch type {
        case .fajr:
            return Fajr
        case .duha:
            return Duha
        case .dhuhr:
            return Dhuhr
        case .asr:
            return Asr
        case .maghrib:
            return Maghrib
        case .isha:
            return Isha
        }
    }
}
