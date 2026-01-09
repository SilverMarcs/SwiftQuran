//
//  PrayerTimesWidgetEntryView.swift
//  SwiftQuranWidget
//
//  Created by Zabir Raihan on 09/01/2026.
//

import SwiftUI
import WidgetKit

struct PrayerTimesWidgetEntryView: View {
    let entry: PrayerTimesWidgetEntry

    var body: some View {
        if let summary = entry.summary {
            VStack(alignment: .leading) {
                Text("Next Prayer")
                    .foregroundStyle(.secondary)

                Spacer()
                
                HStack {
                    Image(systemName: summary.type.symbol)
                        .foregroundStyle(summary.type.color)
                    Text(summary.type.label)
                        .bold()
                    Spacer()
                    Text(summary.time)
                        .bold()
                }
                .font(.system(size: 22, weight: .bold))
                .minimumScaleFactor(1.0)

            }
            .containerBackground(summary.type.color.opacity(0.35), for: .widget)
        } else {
            VStack(alignment: .leading) {
                Text("No Prayer Times")
                    .bold()
                Text("Open the watch app to load times.")
                    .foregroundStyle(.secondary)
            }
            .containerBackground(.fill.tertiary, for: .widget)
        }
    }
}
