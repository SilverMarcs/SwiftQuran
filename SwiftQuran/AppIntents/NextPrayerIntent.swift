//
//  NextPrayerIntent.swift
//  SwiftQuran
//
//  Created by Zabir Raihan on 09/01/2026.
//

import AppIntents
import SwiftUI

@MainActor
struct NextPrayerIntent: @preconcurrency AppIntent {
    static var title: LocalizedStringResource = "Next Prayer Time"
    static var description = IntentDescription("Tells you the next prayer time.")
    static var suggestedInvocationPhrase: String? = "When is the next prayer in SwiftQuran"

    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        let persisted = await MainActor.run {
            PrayerTimesService.shared.loadStoredPrayerData()
        }

        guard let prayerTimes = persisted?.prayerTimes,
              let summary = NextPrayerCalculator.nextPrayer(from: prayerTimes) else {
            return .result(
                dialog: IntentDialog("I don’t have a saved location yet. Open the app to set your location first.")
            ) {
                NextPrayerSnippetView(summary: nil)
            }
        }

        let dialog = IntentDialog("The next prayer is \(summary.type.label) at \(summary.time).")
        return .result(dialog: dialog) {
            NextPrayerSnippetView(summary: summary)
        }
    }
}

private struct NextPrayerSnippetView: View {
    let summary: PrayerTimeSummary?

    var body: some View {
        if let summary {
            VStack(alignment: .leading) {
                Text("Next Prayer")
                    .foregroundStyle(.secondary)
                HStack {
                    Image(systemName: summary.type.symbol)
                        .foregroundStyle(summary.type.color)
                    Text(summary.type.label)
                        .bold()
                    Spacer()
                    Text(summary.time)
                        .bold()
                }
            }
            .background(summary.type.color.opacity(0.2), in: .rect(cornerRadius: 12))
        } else {
            VStack(alignment: .leading) {
                Text("No Location Saved")
                    .bold()
                Text("Open the app to set your location.")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct PrayerTimeSummary {
    let type: PrayerTimeType
    let time: String
    let date: Date
}

private enum NextPrayerCalculator {
    static func nextPrayer(from times: PrayerTimes, now: Date = .now) -> PrayerTimeSummary? {
        let schedule = prayerSchedule(from: times, on: now)
        guard let first = schedule.first else { return nil }

        if let next = schedule.first(where: { $0.date > now }) {
            return PrayerTimeSummary(type: next.type, time: next.timeString, date: next.date)
        }

        if let nextDate = calendar.date(byAdding: .day, value: 1, to: now),
           let tomorrowDate = calendar.date(bySettingHour: calendar.component(.hour, from: first.date),
                                            minute: calendar.component(.minute, from: first.date),
                                            second: 0,
                                            of: nextDate) {
            return PrayerTimeSummary(type: first.type, time: first.timeString, date: tomorrowDate)
        }

        return PrayerTimeSummary(type: first.type, time: first.timeString, date: first.date)
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

private struct PrayerScheduleItem {
    let type: PrayerTimeType
    let timeString: String
    let date: Date
}
