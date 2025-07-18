//
//  PrayerTimeWidget.swift
//  PrayerTimeWidget
//
//  Created by Zabir Raihan on 18/07/2025.
//

import WidgetKit
import SwiftUI

struct PrayerTimeWidgetEntryView: View {
    var entry: PrayerTimesEntry
    
    var body: some View {
        VStack(spacing: 12) {
            // Top row with location and date
            HStack {
                Text("New York") // Placeholder location
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("July 18") // Placeholder date
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            // Prayer times row
            if let times = entry.prayerTimes {
                HStack(spacing: 8) {
                    ForEach(PrayerTimeType.allCases, id: \.self) { type in
                        PrayerTimeColumn(type: type, time: formatTime(timeString(for: type, from: times)))
                    }
                }
            } else {
                Text("No Prayer Times")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .containerBackground(for: .widget) {
            Color.clear
        }
    }
    
    private func timeString(for type: PrayerTimeType, from times: PrayerTimes) -> String {
        switch type {
        case .fajr: return times.Fajr
        case .duha: return times.Duha
        case .dhuhr: return times.Dhuhr
        case .asr: return times.Asr
        case .maghrib: return times.Maghrib
        case .isha: return times.Isha
        }
    }
    
    private func formatTime(_ time: String) -> (hour: String, ampm: String) {
        let cleaned = time.replacingOccurrences(of: "%", with: "")
        let components = cleaned.split(separator: " ")
        guard components.count == 2 else { return (cleaned, "") }
        return (String(components[0]), components[1].uppercased())
    }
}

struct PrayerTimeColumn: View {
    let type: PrayerTimeType
    let time: (hour: String, ampm: String)
    
    var body: some View {
        VStack(spacing: 4) {
            Text(type.label)
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
            
            Image(systemName: type.symbol)
                .foregroundStyle(type.color)
                .font(.system(size: 14))
            
            Text(time.hour)
                .font(.system(size: 12, weight: .medium))
                .contentTransition(.numericText())
            
            Text(time.ampm)
                .font(.system(size: 8))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct PrayerTimeWidget: Widget {
    let kind: String = "PrayerTimeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            PrayerTimeWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Prayer Times")
        .supportedFamilies([.systemMedium])
        .description("Shows the latest fetched prayer times.")
    }
}

#Preview(as: .systemSmall) {
    PrayerTimeWidget()
} timeline: {
    PrayerTimesEntry(date: .now, prayerTimes: nil)
}
