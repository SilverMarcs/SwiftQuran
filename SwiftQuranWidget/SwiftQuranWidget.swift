//
//  SwiftQuranWidget.swift
//  SwiftQuranWidget
//
//  Created by Zabir Raihan on 09/01/2026.
//

import SwiftUI
import WidgetKit

struct SwiftQuranWidget: Widget {
    let kind: String = "SwiftQuranWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PrayerTimesWidgetProvider()) { entry in
            PrayerTimesWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Next Prayer")
        .description("Shows the next prayer time.")
        .supportedFamilies([.accessoryRectangular])
    }
}

#Preview(as: .accessoryRectangular) {
    SwiftQuranWidget()
} timeline: {
    PrayerTimesWidgetEntry(
        date: .now,
        summary: PrayerTimesWidgetSummary(type: .maghrib, time: "6:41 PM", date: .now)
    )
}
