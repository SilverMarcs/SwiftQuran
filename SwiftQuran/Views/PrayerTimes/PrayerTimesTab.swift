//
//  PrayerTimesTab.swift
//  SwiftQuran
//
//  Created by Zabir Raihan on 17/07/2025.
//

import SwiftUI

struct PrayerTimesTab: View {
    @AppStorage("prayer_times", store: UserDefaults(suiteName: "group.com.temporary.SwiftQuran")) private var storedPrayerTimes: Data?
    @State private var prayerTimes: PrayerTimes? = nil
    @State private var lastFetched: Date? = nil
    @State private var isLoading = false
    @State var locationStore = LocationStore()
    
    var body: some View {
          List {
              if let times = prayerTimes {
                  Section("Times") {
                      PrayerTimeRow(type: .fajr, time: times.Fajr)
                      PrayerTimeRow(type: .duha, time: times.Duha)
                      PrayerTimeRow(type: .dhuhr, time: times.Dhuhr)
                      PrayerTimeRow(type: .asr, time: times.Asr)
                      PrayerTimeRow(type: .maghrib, time: times.Maghrib)
                      PrayerTimeRow(type: .isha, time: times.Isha)
                  }
                  
                  Section("Calculation Info") {
                      if let location = locationStore.getLocation() {
                          Label {
                              if let locationName = location.name {
                                  Text(locationName)
                              } else {
                                  unsafe Text(String(format: "%.4f°N, %.4f°E", location.latitude, location.longitude))
                              }
                          } icon: {
                              Image(systemName: "location.fill")
                          }
                          
                          Label {
                              Text("Muslim World League Method")
                          } icon: {
                              Image(systemName: "sum")
                          }
                      }
                  }
                  
              } else {
                  ContentUnavailableView("No Prayer Times",
                      systemImage: "clock",
                      description: Text("Allow location access to view prayer times"))
              }
          }
          .navigationTitle("Prayer Times")
          .toolbarTitleDisplayMode(.inlineLarge)
          .toolbar {
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
          .task {
              loadStoredPrayerTimes()
              
              if shouldFetchNewTimes() {
                  if let location = locationStore.getLocation() {
                      await fetchPrayerTimes(latitude: location.latitude, longitude: location.longitude)
                  }
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
            let formattedTimes = PrayerTimes.formatted(from: response.results)
            prayerTimes = formattedTimes
            let persisted = PersistedPrayerTimes(prayerTimes: formattedTimes, lastFetched: Date())
            if let encoded = try? JSONEncoder().encode(persisted) {
                storedPrayerTimes = encoded
                lastFetched = persisted.lastFetched
            }
        } catch {
            print("Error fetching prayer times: \(error)")
        }
    }
    
    func loadStoredPrayerTimes() {
        if let data = storedPrayerTimes {
            if let decoded = try? JSONDecoder().decode(PersistedPrayerTimes.self, from: data) {
                prayerTimes = decoded.prayerTimes
                lastFetched = decoded.lastFetched
            }
        }
    }
    
    func shouldFetchNewTimes() -> Bool {
        guard let lastFetched else { return true }
        let calendar = Calendar.current
        return !calendar.isDateInToday(lastFetched)
    }
}
