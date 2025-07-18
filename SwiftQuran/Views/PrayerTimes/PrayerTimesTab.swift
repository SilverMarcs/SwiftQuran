//
//  PrayerTimesTab.swift
//  SwiftQuran
//
//  Created by Zabir Raihan on 17/07/2025.
//

import SwiftUI
import CoreLocation
import MapKit

struct PrayerTimesTab: View {
    @State private var prayerTimes: PrayerTimes? = nil
    @State private var lastFetched: Date? = nil
    @State private var isLoading = false
    @State private var locationData: LocationData? = nil
    @State private var locationManager = LocationManager()
    
    private let prayerTimesService = PrayerTimesService.shared
    
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
              
              if prayerTimesService.shouldFetchNewTimes() {
                  await fetchPrayerTimesForStoredLocation()
              }
          }
      }
    
    private func fetchPrayerTimes(latitude: Double, longitude: Double) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Ensure we have location data before saving
            if locationData == nil {
                locationData = LocationData(latitude: latitude, longitude: longitude, locationName: "Unknown Location")
                let locationName = try await prayerTimesService.reverseGeocode(latitude: latitude, longitude: longitude)
                locationData?.locationName = locationName
            }
            
            guard let currentLocationData = locationData else { return }
            try await prayerTimesService.fetchAndStorePrayerTimes(for: currentLocationData)
            
            // Reload local state
            loadStoredPrayerTimes()
        } catch {
            print("Error fetching prayer times: \(error)")
        }
    }
    
    private func requestLocationAndFetchPrayerTimes() async {
        isLoading = true
        defer { isLoading = false }
        
        guard let location = await locationManager.requestLocation() else {
            print("Failed to get location")
            return
        }
        
        locationData = LocationData(latitude: location.latitude, longitude: location.longitude, locationName: "Loading Location")
        
        do {
            let locationName = try await prayerTimesService.reverseGeocode(latitude: location.latitude, longitude: location.longitude)
            locationData?.locationName = locationName
        } catch {
            print("Error reverse geocoding: \(error)")
        }
        
        await fetchPrayerTimes(latitude: location.latitude, longitude: location.longitude)
    }
    
    private func fetchPrayerTimesForStoredLocation() async {
        guard let storedLocation = locationData else { return }
        await fetchPrayerTimes(latitude: storedLocation.latitude, longitude: storedLocation.longitude)
    }
    
    func loadStoredPrayerTimes() {
        if let persistedData = prayerTimesService.loadStoredPrayerData() {
            prayerTimes = persistedData.prayerTimes
            lastFetched = persistedData.lastFetched
            locationData = persistedData.location
        }
    }
}
