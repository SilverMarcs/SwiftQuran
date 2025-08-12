import SwiftUI

struct SurahList: View {
    var progressManager = ReadingProgressManager.shared
    @State private var showSettings = false
    
    private var filteredSurahs: ([Surah], [Surah]) {
        let allSurahs = QuranDataManager.shared.surahs
        let inProgress = allSurahs.filter { progressManager.getProgress(for: $0.id) != nil }
        let remaining = allSurahs.filter { progressManager.getProgress(for: $0.id) == nil }
        return (inProgress, remaining)
    }

    var body: some View {
        List {
            let (inProgress, remaining) = filteredSurahs

            if !inProgress.isEmpty {
                Section("Continue Reading") {
                    ForEach(inProgress, id: \.id) { surah in
                        NavigationLink(value: surah) {
                            SurahRow(surah: surah)
                        }
                    }
                }
            }

            Section("All Surahs") {
                ForEach(remaining, id: \.id) { surah in
                    NavigationLink(value: surah) {
                        SurahRow(surah: surah)
                    }
                }
            }
        }
        .navigationTitle("Surahs")
        .toolbarTitleDisplayMode(.inlineLarge)
        #if !os(macOS)
        .toolbar {
            SettingsToolbar(showSettings: $showSettings)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        #endif
    }
}
