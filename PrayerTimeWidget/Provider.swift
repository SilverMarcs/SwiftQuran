//
//  PrayerTimesEntry.swift
//  SwiftQuran
//
//  Created by Zabir Raihan on 18/07/2025.
//

import WidgetKit

struct PrayerTimesEntry: TimelineEntry {
    let date: Date
    let prayerTimes: PrayerTimes?
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> PrayerTimesEntry {
        PrayerTimesEntry(date: Date(), prayerTimes: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (PrayerTimesEntry) -> ()) {
        let entry = PrayerTimesEntry(date: Date(), prayerTimes: loadPrayerTimes())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PrayerTimesEntry>) -> ()) {
        let prayerTimes = loadPrayerTimes()
        let entry = PrayerTimesEntry(date: Date(), prayerTimes: prayerTimes)
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }

    private func loadPrayerTimes() -> PrayerTimes? {
        let defaults = UserDefaults(suiteName: "group.com.temporary.SwiftQuran")
        if let data = defaults?.data(forKey: "prayer_times"),
           let persisted = try? JSONDecoder().decode(PersistedPrayerTimes.self, from: data) {
            return persisted.prayerTimes
        }
        return nil
    }
}
