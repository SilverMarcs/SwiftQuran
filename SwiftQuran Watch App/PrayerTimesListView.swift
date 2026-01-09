//
//  PrayerTimesListView.swift
//  SwiftQuran Watch App
//
//  Created by Zabir Raihan on 09/01/2026.
//

import SwiftUI

struct PrayerTimesListView: View {
    @State private var store = PrayerTimesStore.shared
    @State private var prayerTimesService = PrayerTimesService.shared
    @State private var isFetching = false
    @State private var fetchError: String?

    var body: some View {
        NavigationStack {
            List {
                if let prayerTimes = store.prayerTimes {
                    ForEach(PrayerTimeType.allCases) { type in
                        PrayerTimeListRow(
                            type: type,
                            time: prayerTimes.time(for: type),
                            isCurrent: type == store.currentPrayerType
                        )
                    }
                } else if let fetchError {
                    ContentUnavailableView(
                        "Unable to Load Prayer Times",
                        systemImage: "exclamationmark.triangle",
                        description: Text(fetchError)
                    )
                } else {
                    ContentUnavailableView(
                        "No Prayer Times",
                        systemImage: "clock",
                        description: Text("Open the iPhone app to sync today's times.")
                    )
                }
            }
            .listStyle(.carousel)
            .navigationTitle("Prayers")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            await refreshPrayerTimes()
                        }
                    } label: {
                        if isFetching {
                            ProgressView()
                        } else {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                }
            }
        }
        .task {
            await refreshPrayerTimesIfNeeded()
        }
    }

    private func refreshPrayerTimesIfNeeded() async {
        store.load()
        if prayerTimesService.shouldFetchNewTimes() {
            await refreshPrayerTimes()
        } else {
            store.refreshCurrentPrayer()
        }
    }

    private func refreshPrayerTimes() async {
        isFetching = true
        defer { isFetching = false }
        fetchError = (await prayerTimesService.fetchPrayerTimesForCurrentLocation())?.rawValue
        store.load()
    }
}
