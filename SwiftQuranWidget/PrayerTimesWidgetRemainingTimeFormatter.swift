//
//  PrayerTimesWidgetRemainingTimeFormatter.swift
//  SwiftQuranWidget
//
//  Created by Zabir Raihan on 09/01/2026.
//

import Foundation

struct PrayerTimesWidgetRemainingTimeFormatter {
    static func formattedRemainingTime(from start: Date, to end: Date, calendar: Calendar = .current) -> String {
        let components = calendar.dateComponents([.hour, .minute], from: start, to: end)
        let hours = max(0, components.hour ?? 0)
        let minutes = max(0, components.minute ?? 0)
        let minuteString = minutes.formatted(.number.precision(.integerLength(2)))
        return "\(hours)H \(minuteString)M"
    }
}
