//
//  PrayerTimeWidgetEntryView.swift
//  SwiftQuran
//
//  Created by Zabir Raihan on 18/07/2025.
//

import SwiftUI
import WidgetKit

struct PrayerTimeWidgetEntryView: View {
    var entry: PrayerTimesEntry
    
    var body: some View {
        VStack(spacing: 12) {
            // Top row with location and date
            HStack {
                Text("Prayer Times")
                    .font(.headline)
                
                Spacer()
                
                Text(Date(), style: .date)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }
            .padding(5)
            
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
