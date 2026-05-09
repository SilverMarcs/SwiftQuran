//
//  PrayerTimeWidget.swift
//  PrayerTimeWidget
//
//  Created by Zabir Raihan on 18/07/2025.
//

import WidgetKit
import SwiftUI

struct IqraPrayerTimes: Widget {
    let kind: String = "IqraPrayerTimes"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            PrayerTimeWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    Color(.systemBackground)
                }
                .widgetURL(URL(string: "iqra://prayers"))
        }
        .configurationDisplayName("Prayer Times")
        .supportedFamilies([.systemMedium])
        .description("Shows the latest fetched prayer times.")
    }
}

#Preview(as: .systemSmall) {
    IqraPrayerTimes()
} timeline: {
    PrayerTimesEntry(date: .now, prayerTimes: nil, locationName: "Cupertino")
}
