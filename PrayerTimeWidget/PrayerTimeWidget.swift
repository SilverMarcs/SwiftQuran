//
//  PrayerTimeWidget.swift
//  PrayerTimeWidget
//
//  Created by Zabir Raihan on 18/07/2025.
//

import WidgetKit
import SwiftUI

struct PrayerTimeWidget: Widget {
    let kind: String = "PrayerTimeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            PrayerTimeWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    Color(.systemBackground)
                }
                .widgetURL(URL(string: "swiftquran://prayers"))
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
