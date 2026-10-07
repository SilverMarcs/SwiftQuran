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
    @Environment(\.scenePhase) private var scenePhase
    @State private var prayerTimes: PrayerTimes? = nil
    @State private var lastFetched: Date? = nil
    @State private var isLoading = false
    @State private var locationData: LocationData? = nil
    @State private var locationManager = LocationManager()
    @State private var notifications = PrayerNotificationManager.shared
    
    private let prayerTimesService = PrayerTimesService.shared
    
    var body: some View {
          Form {
              if let times = prayerTimes {
                  Section("Times") {
                      ForEach(PrayerTimeType.allCases) { type in
                          PrayerTimeRow(
                              type: type,
                              time: times.time(for: type),
                              notificationsEnabled: notifications.isEnabled(type),
                              isUpdatingNotifications: notifications.isUpdating
                          ) {
                              Task { await notifications.toggle(type, times: times) }
                          }
                      }
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
          .formStyle(.grouped)
          .navigationTitle("Prayers")
          .toolbarTitleDisplayMode(.inlineLarge)
          .alert("Prayer Notifications", isPresented: Binding(
              get: { notifications.errorMessage != nil },
              set: { if !$0 { notifications.errorMessage = nil } }
          )) {
              Button("OK", role: .cancel) { notifications.errorMessage = nil }
          } message: {
              Text(notifications.errorMessage ?? "")
          }
          .toolbar {
              Button {
                  Task {
                      await requestLocationAndFetchPrayerTimes()
                  }
              } label: {
                  if isLoading {
                      ProgressView()
                      #if os(macOS)
                          .controlSize(.small)
                      #endif
                  } else {
                      Image(systemName: "location")
                  }
              }
              .disabled(isLoading)
          }
          .task(id: scenePhase) {
              guard scenePhase == .active else { return }
              loadStoredPrayerTimes()
              await notifications.refresh(times: prayerTimes)
              
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
            await notifications.refresh(times: prayerTimes)
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
