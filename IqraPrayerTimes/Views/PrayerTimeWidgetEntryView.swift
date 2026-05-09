//
//  PrayerTimeWidgetEntryView.swift
//  SwiftQuran
//
//  Created by Zabir Raihan on 18/07/2025.
//

import SwiftUI

struct PrayerTimeWidgetEntryView: View {
    var entry: PrayerTimesEntry
    
    var body: some View {
        TimelineView(.periodic(from: .now, by: 60)) { context in
            PrayerTimeWidgetContentView(entry: entry, now: context.date)
        }
    }
}
