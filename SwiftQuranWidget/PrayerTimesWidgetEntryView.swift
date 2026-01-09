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
            HStack {
                VStack(alignment: .leading) {
                    Label {
                        Text(summary.type.label)
                            .bold()
                    } icon: {
                        Image(systemName: summary.type.symbol)
                            .foregroundStyle(summary.type.color)
                    }
                    
                    Text(summary.time)
                        .font(.system(size: 26))
                        .fontWeight(.semibold)
                        .minimumScaleFactor(1.0)
                }
                
                Spacer()
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
