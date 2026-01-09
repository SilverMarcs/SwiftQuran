//
//  PrayerTimesWidgetStore.swift
//  SwiftQuranWidget
//
//  Created by Zabir Raihan on 09/01/2026.
//

import Foundation

struct PrayerTimesWidgetStore {
    static let storageKey = "prayer_times"

    static func loadPersistedPrayerTimes() -> PersistedPrayerTimes? {
        guard let data = UserDefaults(suiteName: "group.com.temporary.SwiftQuran")?.data(forKey: storageKey),
              let persisted = try? JSONDecoder().decode(PersistedPrayerTimes.self, from: data) else {
            return nil
        }
        return persisted
    }

    static func nextPrayerSummary(from times: PrayerTimes, now: Date = .now) -> PrayerTimesWidgetSummary? {
        let schedule = prayerSchedule(from: times, on: now)
        guard let first = schedule.first else { return nil }

        if let next = schedule.first(where: { $0.date > now }) {
            return PrayerTimesWidgetSummary(type: next.type, time: next.timeString, date: next.date)
        }

        if let nextDate = calendar.date(byAdding: .day, value: 1, to: now),
           let tomorrowDate = calendar.date(bySettingHour: calendar.component(.hour, from: first.date),
                                            minute: calendar.component(.minute, from: first.date),
                                            second: 0,
                                            of: nextDate) {
            return PrayerTimesWidgetSummary(type: first.type, time: first.timeString, date: tomorrowDate)
        }

        return PrayerTimesWidgetSummary(type: first.type, time: first.timeString, date: first.date)
    }

    private static func prayerSchedule(from times: PrayerTimes, on date: Date) -> [PrayerScheduleItem] {
        PrayerTimeType.allCases.compactMap { type in
            let timeString = times.time(for: type)
            guard let timeDate = timeStringToDate(timeString, on: date) else { return nil }
            return PrayerScheduleItem(type: type, timeString: timeString, date: timeDate)
        }
        .sorted { $0.date < $1.date }
    }

    private static func timeStringToDate(_ time: String, on date: Date) -> Date? {
        let cleaned = time.trimmingCharacters(in: .whitespacesAndNewlines)

        if let parsed = timeFormatter12.date(from: cleaned) {
            return dateFromParsedTime(parsed, on: date)
        }

        if let parsed = timeFormatter24.date(from: cleaned) {
            return dateFromParsedTime(parsed, on: date)
        }

        return nil
    }

    private static func dateFromParsedTime(_ parsed: Date, on date: Date) -> Date? {
        let components = calendar.dateComponents([.hour, .minute], from: parsed)
        guard let hour = components.hour, let minute = components.minute else { return nil }
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: date)
    }

    private static let calendar = Calendar.current

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
