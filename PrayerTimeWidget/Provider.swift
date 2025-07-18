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
    let locationName: String?
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> PrayerTimesEntry {
        PrayerTimesEntry(date: Date(), prayerTimes: nil, locationName: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (PrayerTimesEntry) -> ()) {
        let prayerData = loadPrayerData()
        let entry = PrayerTimesEntry(
            date: Date(), 
            prayerTimes: prayerData?.prayerTimes,
            locationName: prayerData?.location?.locationName
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PrayerTimesEntry>) -> ()) {
        let prayerData = loadPrayerData()
        let entry = PrayerTimesEntry(
            date: Date(),
            prayerTimes: prayerData?.prayerTimes,
            locationName: prayerData?.location?.locationName
        )
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }

    private func loadPrayerData() -> PersistedPrayerTimes? {
        return PrayerTimesService.shared.loadStoredPrayerData()
    }
}
