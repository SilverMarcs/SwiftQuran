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
//                Label {
//                    Text(entry.locationName ?? "Unknown Location")
//                } icon: {
//                    Image(systemName: "location")
//                }
                Text(entry.locationName ?? "Loading Location")
                    .lineLimit(1)
                    .font(.headline)
                    .opacity(0.8)
                    .padding(.leading, 10)

                Spacer()

                // doesnt seem to work. fix pls
                Button(intent: UpdatePrayerTimesIntent()) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundStyle(.teal)
                        .fontWeight(.semibold)
                }
            }
            
            // Prayer times row
            if let times = entry.prayerTimes {
                HStack(spacing: 8) {
                    PrayerTimeColumn(type: .fajr, time: times.Fajr)
//                    PrayerTimeColumn(type: .duha, time: times.Duha)
                    PrayerTimeColumn(type: .dhuhr, time: times.Dhuhr)
                    PrayerTimeColumn(type: .asr, time: times.Asr)
                    PrayerTimeColumn(type: .maghrib, time: times.Maghrib)
                    PrayerTimeColumn(type: .isha, time: times.Isha)
                }
            } else {
                Text("No Prayer Times")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
