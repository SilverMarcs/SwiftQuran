//
//  PrayerTimesTab.swift
//  SwiftQuran
//
//  Created by Zabir Raihan on 17/07/2025.
//

import SwiftUI

struct PrayerTimesTab: View {
    @State private var prayerTimes: PrayerTimes?
    @State private var isLoading = false
    @State var locationStore = LocationStore()
    
    var body: some View {
        List {
            if let times = prayerTimes {
                PrayerTimeRow(title: "Fajr", time: times.Fajr)
                PrayerTimeRow(title: "Duha", time: times.Duha)
                PrayerTimeRow(title: "Dhuhr", time: times.Dhuhr)
                PrayerTimeRow(title: "Asr", time: times.Asr)
                PrayerTimeRow(title: "Maghrib", time: times.Maghrib)
                PrayerTimeRow(title: "Isha", time: times.Isha)
            } else {
                ContentUnavailableView("No Prayer Times",
                    systemImage: "clock",
                    description: Text("Allow location access to view prayer times"))
            }
        }
        .navigationTitle("Prayer Times")
        .toolbarTitleDisplayMode(.inlineLarge)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    locationStore.requestLocation()
                    if let location = locationStore.getLocation() {
                        Task {
                            await fetchPrayerTimes(latitude: location.latitude, longitude: location.longitude)
                        }
                    }
                } label: {
                    Image(systemName: "location")
                }
            }
        }
        .task {
            if let location = locationStore.getLocation() {
                await fetchPrayerTimes(latitude: location.latitude, longitude: location.longitude)
            }
        }
    }
    
    private func fetchPrayerTimes(latitude: Double, longitude: Double) async {
        isLoading = true
        defer { isLoading = false }
        
        let timezone = TimeZone.current.identifier
        let urlString = "https://www.islamicfinder.us/index.php/api/prayer_times?latitude=\(latitude)&longitude=\(longitude)&timezone=\(timezone)"
        
        guard let url = URL(string: urlString) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(PrayerTimesResponse.self, from: data)
            prayerTimes = response.results
        } catch {
            print("Error fetching prayer times: \(error)")
        }
    }
}
