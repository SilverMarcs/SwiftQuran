//
//  PrayerTimeWidgetEntryView.swift
//  SwiftQuran
//
//  Created by Zabir Raihan on 18/07/2025.
//

import SwiftUI
import WidgetKit
import AppIntents

struct PrayerTimeWidgetEntryView: View {
    var entry: PrayerTimesEntry
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Label {
                    Text((entry.locationName ?? "Loading Location").components(separatedBy: ",").first ?? "")
                } icon: {
                    Image(systemName: "location.fill")
                        .foregroundStyle(.accent)
                }
                .padding(.leading, 5)

                Spacer()
                
                if let remainingTimeText {
                    Button {} label: {
                        Text(remainingTimeText)
                            .font(.subheadline)
                            .bold()
                    }
                    .tint(Color(.accent).secondary)
                    .buttonStyle(.borderedProminent)
                }
            }
            
            // Prayer times row
            if let times = entry.prayerTimes {
                HStack(spacing: 8) {
                    PrayerTimeColumn(type: .fajr, time: times.Fajr, isCurrent: currentPrayerType == .fajr)
//                    PrayerTimeColumn(type: .duha, time: times.Duha)
                    PrayerTimeColumn(type: .dhuhr, time: times.Dhuhr, isCurrent: currentPrayerType == .dhuhr)
                    PrayerTimeColumn(type: .asr, time: times.Asr, isCurrent: currentPrayerType == .asr)
                    PrayerTimeColumn(type: .maghrib, time: times.Maghrib, isCurrent: currentPrayerType == .maghrib)
                    PrayerTimeColumn(type: .isha, time: times.Isha, isCurrent: currentPrayerType == .isha)
                }
            } else {
                Text("No Prayer Times")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private var remainingTimeText: String? {
        guard let next = nextPrayer else { return nil }
        return PrayerTimeWidgetRemainingTimeFormatter.formattedRemainingTime(from: entry.date, to: next.date)
    }

    private var currentPrayerType: PrayerTimeType? {
        let now = entry.date
        if let current = prayerSchedule.last(where: { $0.date <= now }) {
            return current.type
        }
        return prayerSchedule.last?.type
    }

    private var nextPrayer: PrayerScheduleItem? {
        let now = entry.date
        if let next = prayerSchedule.first(where: { $0.date > now }) {
            return next
        }

        guard let first = prayerSchedule.first else { return nil }
        let hour = calendar.component(.hour, from: first.date)
        let minute = calendar.component(.minute, from: first.date)
        if let nextDate = calendar.date(byAdding: .day, value: 1, to: now),
           let tomorrow = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: nextDate) {
            return PrayerScheduleItem(type: first.type, time: first.time, date: tomorrow)
        }

        return first
    }

    private var prayerSchedule: [PrayerScheduleItem] {
        guard let times = entry.prayerTimes else { return [] }
        let now = entry.date
        let items: [(PrayerTimeType, String)] = [
            (.fajr, times.Fajr),
            (.dhuhr, times.Dhuhr),
            (.asr, times.Asr),
            (.maghrib, times.Maghrib),
            (.isha, times.Isha)
        ]
        return items.compactMap { type, time in
            guard let date = date(from: time, on: now) else { return nil }
            return PrayerScheduleItem(type: type, time: time, date: date)
        }
        .sorted { $0.date < $1.date }
    }

    private func date(from time: String, on date: Date) -> Date? {
        let cleaned = time.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let parsed = timeFormatter.date(from: cleaned) else { return nil }
        let components = calendar.dateComponents([.hour, .minute], from: parsed)
        guard let hour = components.hour, let minute = components.minute else { return nil }
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: date)
    }

    private struct PrayerScheduleItem {
        let type: PrayerTimeType
        let time: String
        let date: Date
    }

    private let calendar = Calendar.current

    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
}
