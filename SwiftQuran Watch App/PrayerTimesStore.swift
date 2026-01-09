//
//  PrayerTimesStore.swift
//  SwiftQuran Watch App
//
//  Created by Zabir Raihan on 09/01/2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class PrayerTimesStore {
    static let shared = PrayerTimesStore()

    private let storageKey = "prayer_times"
    private let userDefaults = UserDefaults.standard

    var prayerTimes: PrayerTimes?
    var currentPrayerType: PrayerTimeType?

    private init() {}

    func load() {
        guard let data = userDefaults.data(forKey: storageKey),
              let persisted = try? JSONDecoder().decode(PersistedPrayerTimes.self, from: data) else {
            prayerTimes = nil
            currentPrayerType = nil
            return
        }

        prayerTimes = persisted.prayerTimes
        refreshCurrentPrayer()
    }

    func update(from data: Data) {
        guard let persisted = try? JSONDecoder().decode(PersistedPrayerTimes.self, from: data) else {
            return
        }

        userDefaults.set(data, forKey: storageKey)
        update(with: persisted)
    }

    func update(with persisted: PersistedPrayerTimes) {
        prayerTimes = persisted.prayerTimes
        refreshCurrentPrayer()
    }

    func refreshCurrentPrayer(now: Date = .now) {
        guard let times = prayerTimes else {
            currentPrayerType = nil
            return
        }

        currentPrayerType = Self.currentPrayerType(for: times, now: now)
    }

    private static func currentPrayerType(for times: PrayerTimes, now: Date) -> PrayerTimeType? {
        let calendar = Calendar.current
        let schedule = PrayerTimeType.allCases.compactMap { type -> (PrayerTimeType, Date)? in
            let timeString = times.time(for: type)
            guard let date = timeStringToDate(timeString, on: now, calendar: calendar) else {
                return nil
            }
            return (type, date)
        }

        guard let last = schedule.last else { return nil }
        if let current = schedule.last(where: { $0.1 <= now }) {
            return current.0
        }
        return last.0
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
