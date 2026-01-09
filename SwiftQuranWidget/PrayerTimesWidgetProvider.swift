//
//  PrayerTimesWidgetProvider.swift
//  SwiftQuranWidget
//
//  Created by Zabir Raihan on 09/01/2026.
//

import WidgetKit

struct PrayerTimesWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> PrayerTimesWidgetEntry {
        PrayerTimesWidgetEntry(
            date: .now,
            summary: PrayerTimesWidgetSummary(type: .fajr, time: "5:12 AM", date: .now)
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (PrayerTimesWidgetEntry) -> Void) {
        completion(PrayerTimesWidgetEntry(date: .now, summary: currentSummary()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PrayerTimesWidgetEntry>) -> Void) {
        let entry = PrayerTimesWidgetEntry(date: .now, summary: currentSummary())
        let reloadDate = entry.summary?.date ?? Calendar.current.date(byAdding: .hour, value: 1, to: .now) ?? .now
        completion(Timeline(entries: [entry], policy: .after(reloadDate)))
    }

    private func currentSummary() -> PrayerTimesWidgetSummary? {
        guard let persisted = PrayerTimesWidgetStore.loadPersistedPrayerTimes() else {
            return nil
        }
        return PrayerTimesWidgetStore.nextPrayerSummary(from: persisted.prayerTimes)
    }
}
