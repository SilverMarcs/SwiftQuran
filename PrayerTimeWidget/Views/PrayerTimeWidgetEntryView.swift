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
                
                if let next = nextPrayer {
                    Button {} label: {
                        HStack(spacing: 2) {
                            Text(next.name)
                                .font(.subheadline)
                            Text(next.time)
                                .font(.subheadline)
                                .bold()
                        }
                    }
                    .tint(Color(.accent).tertiary)
                    .buttonStyle(.borderedProminent)
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
    
    var nextPrayer: (name: String, time: String)? {
        guard let times = entry.prayerTimes else { return nil }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let currentTime = formatter.string(from: Date())
        
        // Convert prayer times to comparable format
        let prayers: [(name: String, time: String)] = [
            ("Fajr", times.Fajr),
            ("Dhuhr", times.Dhuhr),
            ("Asr", times.Asr),
            ("Maghrib", times.Maghrib),
            ("Isha", times.Isha)
        ]
        
        // Find next prayer
        for prayer in prayers {
            if let prayerDate = formatter.date(from: prayer.time),
               let currentDate = formatter.date(from: currentTime) {
                if prayerDate > currentDate {
                    return prayer
                }
            }
        }
        
        // If no prayer is found after current time, return first prayer of next day
        return ("Fajr", times.Fajr)
    }
}
