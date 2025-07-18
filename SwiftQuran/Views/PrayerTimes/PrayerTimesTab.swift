//
//  PrayerTimesTab.swift
//  SwiftQuran
//
//  Created by Zabir Raihan on 17/07/2025.
//

import SwiftUI
import MapKit

struct PrayerTimesTab: View {
    @AppStorage("prayer_times", store: UserDefaults(suiteName: "group.com.temporary.SwiftQuran")) private var storedPrayerTimes: Data?
    
    @State private var prayerTimes: PrayerTimes? = nil
    @State private var lastFetched: Date? = nil
    @State private var isLoading = false
    @State private var locationData: LocationData? = nil
    @State private var locationManager = LocationManager()
    
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
                      Label {
                          Text(locationData?.locationName ?? "Unknown Location")
                      } icon: {
                          Image(systemName: "location")
                      }
                      
                      Label {
                          Text("Muslim World League Method")
                      } icon: {
                          Image(systemName: "sum")
                      }
                  }
                  
              } else {
                  ContentUnavailableView("No Prayer Times",
                      systemImage: "clock",
                      description: Text("Allow location access to view prayer times"))
              }
          }
          .navigationTitle("Prayers")
          .toolbarTitleDisplayMode(.inlineLarge)
          .toolbar {
              Button {
                  Task {
                      await requestLocationAndFetchPrayerTimes()
                  }
              } label: {
                  if isLoading {
                      ProgressView()
                  } else {
                      Image(systemName: "location")
                  }
              }
          }
          .task {
              loadStoredPrayerTimes()
              
              if shouldFetchNewTimes {
                  await fetchPrayerTimesForStoredLocation()
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
            
            // Ensure we have location data before saving
            if locationData == nil {
                locationData = LocationData(latitude: latitude, longitude: longitude, locationName: "Unknown Location")
                await reverseGeocode(latitude: latitude, longitude: longitude)
            }
            
            let persisted = PersistedPrayerTimes(prayerTimes: formattedTimes, lastFetched: Date(), location: locationData)
            if let encoded = try? JSONEncoder().encode(persisted) {
                storedPrayerTimes = encoded
                lastFetched = persisted.lastFetched
            }
        } catch {
            print("Error fetching prayer times: \(error)")
        }
    }
    
    private func requestLocationAndFetchPrayerTimes() async {
        guard let location = await locationManager.requestLocation() else {
            print("Failed to get location")
            return
        }
        
        locationData = LocationData(latitude: location.latitude, longitude: location.longitude, locationName: "Unknown Location")
        await reverseGeocode(latitude: location.latitude, longitude: location.longitude)
        await fetchPrayerTimes(latitude: location.latitude, longitude: location.longitude)
    }
    
    private func fetchPrayerTimesForStoredLocation() async {
        guard let storedLocation = locationData else { return }
        await fetchPrayerTimes(latitude: storedLocation.latitude, longitude: storedLocation.longitude)
    }
    
    private func reverseGeocode(latitude: Double, longitude: Double) async {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        guard let request = MKReverseGeocodingRequest(location: location) else {
            print("Failed to create reverse geocoding request")
            return
        }
        do {
            let mapItems = try await request.mapItems
            let mapItem = mapItems.first
            if let address = mapItem?.address {
                locationData?.locationName = address.fullAddress
            } else {
                let name = mapItem?.addressRepresentations?.cityWithContext ?? "Unknown Location"
                locationData?.locationName = name
            }
        } catch {
            print("Error reverse geocoding location: \(error)")
        }
    }
    
    func loadStoredPrayerTimes() {
        if let data = storedPrayerTimes {
            if let decoded = try? JSONDecoder().decode(PersistedPrayerTimes.self, from: data) {
                prayerTimes = decoded.prayerTimes
                lastFetched = decoded.lastFetched
                locationData = decoded.location
            }
        }
    }
    
    var shouldFetchNewTimes: Bool {
        guard let lastFetched else { return true }
        let calendar = Calendar.current
        return !calendar.isDateInToday(lastFetched)
    }
}
