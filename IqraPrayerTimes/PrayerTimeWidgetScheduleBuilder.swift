//
//  PrayerTimeWidgetScheduleBuilder.swift
//  SwiftQuran
//
//  Created by Zabir Raihan on 18/07/2025.
//

import Foundation

struct PrayerTimeWidgetScheduleBuilder {
    static func schedule(from times: PrayerTimes, on date: Date, calendar: Calendar = .current) -> [PrayerScheduleItem] {
        let items: [(PrayerTimeType, String)] = [
            (.fajr, times.Fajr),
            (.dhuhr, times.Dhuhr),
            (.asr, times.Asr),
            (.maghrib, times.Maghrib),
            (.isha, times.Isha)
        ]

        return items.compactMap { type, time in
            guard let date = timeStringToDate(time, on: date, calendar: calendar) else { return nil }
            return PrayerScheduleItem(type: type, time: time, date: date)
        }
        .sorted { $0.date < $1.date }
    }

    static func nextPrayer(from times: PrayerTimes, now: Date, calendar: Calendar = .current) -> PrayerScheduleItem? {
        let schedule = schedule(from: times, on: now, calendar: calendar)
        guard let first = schedule.first else { return nil }

        if let next = schedule.first(where: { $0.date > now }) {
            return next
        }

        let hour = calendar.component(.hour, from: first.date)
        let minute = calendar.component(.minute, from: first.date)
        if let nextDate = calendar.date(byAdding: .day, value: 1, to: now),
           let tomorrow = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: nextDate) {
            return PrayerScheduleItem(type: first.type, time: first.time, date: tomorrow)
        }

        return first
    }

    static func currentPrayerType(from times: PrayerTimes, now: Date, calendar: Calendar = .current) -> PrayerTimeType? {
        let schedule = schedule(from: times, on: now, calendar: calendar)
        if let current = schedule.last(where: { $0.date <= now }) {
            return current.type
        }
        return schedule.last?.type
    }

    private static func timeStringToDate(_ time: String, on date: Date, calendar: Calendar) -> Date? {
        let cleaned = time.trimmingCharacters(in: .whitespacesAndNewlines)

        if let parsed = timeFormatter12.date(from: cleaned) {
            return dateFromParsedTime(parsed, on: date, calendar: calendar)
        }

        if let parsed = timeFormatter24.date(from: cleaned) {
            return dateFromParsedTime(parsed, on: date, calendar: calendar)
        }

        return nil
    }

    private static func dateFromParsedTime(_ parsed: Date, on date: Date, calendar: Calendar) -> Date? {
        let components = calendar.dateComponents([.hour, .minute], from: parsed)
        guard let hour = components.hour, let minute = components.minute else { return nil }
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: date)
    }

    private static let timeFormatter12: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "h:mm a"
        return formatter
    }()

    private static let timeFormatter24: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
}
