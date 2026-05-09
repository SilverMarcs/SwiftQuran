//
//  PrayerTimeWidgetContentView.swift
//  SwiftQuran
//
//  Created by Zabir Raihan on 18/07/2025.
//

import SwiftUI

struct PrayerTimeWidgetContentView: View {
    let entry: PrayerTimesEntry
    let now: Date

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
                    .tint(Color.accentColor.opacity(0.7))
                    .buttonStyle(.borderedProminent)
                }
            }

            if let times = entry.prayerTimes {
                HStack(spacing: 8) {
                    PrayerTimeColumn(type: .fajr, time: times.Fajr, isCurrent: currentPrayerType == .fajr)
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
        return PrayerTimeWidgetRemainingTimeFormatter.formattedRemainingTime(from: now, to: next.date)
    }

    private var currentPrayerType: PrayerTimeType? {
        guard let times = entry.prayerTimes else { return nil }
        return PrayerTimeWidgetScheduleBuilder.currentPrayerType(from: times, now: now)
    }

    private var nextPrayer: PrayerScheduleItem? {
        guard let times = entry.prayerTimes else { return nil }
        return PrayerTimeWidgetScheduleBuilder.nextPrayer(from: times, now: now)
    }
}
