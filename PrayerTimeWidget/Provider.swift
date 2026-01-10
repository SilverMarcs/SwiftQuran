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
        Task {
            let prayerData = await loadPrayerData()
            let entry = PrayerTimesEntry(
                date: Date(),
                prayerTimes: prayerData?.prayerTimes,
                locationName: prayerData?.location?.locationName
            )
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PrayerTimesEntry>) -> ()) {
        let calendar = Calendar.current
        let currentDate = Date()
        
        // Check if we need to fetch new prayer times
        Task {
            await fetchPrayerTimesIfNeeded()
            
            // Load prayer data after potential fetch
            let prayerData = await loadPrayerData()
            
            // Create current entry
            let currentEntry = PrayerTimesEntry(
                date: currentDate,
                prayerTimes: prayerData?.prayerTimes,
                locationName: prayerData?.location?.locationName
            )
            
            let entries = [currentEntry]

            let nextRefresh = nextRefreshDate(from: prayerData?.prayerTimes, now: currentDate, calendar: calendar)
                ?? calendar.date(byAdding: .hour, value: 1, to: currentDate)
                ?? currentDate.addingTimeInterval(3600)
            
            let timeline = Timeline(entries: entries, policy: .after(nextRefresh))
            completion(timeline)
        }
    }

    private func loadPrayerData() async -> PersistedPrayerTimes? {
        await MainActor.run {
            PrayerTimesService.shared.loadStoredPrayerData()
        }
    }
    
    private func fetchPrayerTimesIfNeeded() async {
        // Check if prayer times need to be refreshed (not from today)
        let shouldFetch = await MainActor.run {
            PrayerTimesService.shared.shouldFetchNewTimes()
        }
        if shouldFetch {
            do {
                try await PrayerTimesService.shared.fetchPrayerTimesForStoredLocation()
            } catch {
                // Silently fail - widget will show last known data
                print("Widget failed to fetch prayer times: \(error)")
            }
        }
    }

    private func nextRefreshDate(from times: PrayerTimes?, now: Date, calendar: Calendar) -> Date? {
        guard let times else {
            return calendar.dateInterval(of: .day, for: now)?.end
        }

        if let nextPrayer = PrayerTimeWidgetScheduleBuilder.nextPrayer(from: times, now: now, calendar: calendar) {
            return nextPrayer.date
        }

        return calendar.dateInterval(of: .day, for: now)?.end
    }
}
