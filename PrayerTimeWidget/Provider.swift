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
        let currentDate = Date()
        
        // Create current entry
        let currentEntry = PrayerTimesEntry(
            date: currentDate,
            prayerTimes: prayerData?.prayerTimes,
            locationName: prayerData?.location?.locationName
        )
        
        // Create timeline entries for updates
        let entries = [currentEntry]
        let calendar = Calendar.current
        
        // Determine refresh policy based on data freshness
        let refreshPolicy: TimelineReloadPolicy
        
        if let lastFetched = prayerData?.lastFetched,
           calendar.isDateInToday(lastFetched) {
            // Data is fresh, schedule next update for tomorrow at midnight
            if let tomorrowMidnight = calendar.dateInterval(of: .day, for: currentDate)?.end {
                refreshPolicy = .after(tomorrowMidnight)
            } else {
                // Fallback: update in 24 hours
                let tomorrow = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
                refreshPolicy = .after(tomorrow)
            }
        } else {
            // Data is stale or missing, try to refresh sooner
            // But with large intervals
            let refreshDate = calendar.date(byAdding: .hour, value: 6, to: currentDate) ?? currentDate
            refreshPolicy = .after(refreshDate)
        }
        
        let timeline = Timeline(entries: entries, policy: refreshPolicy)
        completion(timeline)
    }

    private func loadPrayerData() -> PersistedPrayerTimes? {
        return PrayerTimesService.shared.loadStoredPrayerData()
    }
}
