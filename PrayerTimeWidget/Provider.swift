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
            
            // Schedule next refresh for tomorrow at midnight
            let refreshPolicy: TimelineReloadPolicy
            if let tomorrowMidnight = calendar.dateInterval(of: .day, for: currentDate)?.end {
                refreshPolicy = .after(tomorrowMidnight)
            } else {
                // Fallback: update in 24 hours
                let tomorrow = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
                refreshPolicy = .after(tomorrow)
            }
            
            let timeline = Timeline(entries: entries, policy: refreshPolicy)
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
}
