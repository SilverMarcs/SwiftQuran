import SwiftUI

struct SurahList: View {
    @Environment(QuranDataManager.self) var dataManager
    @Environment(ReadingProgressManager.self) var progressManager
    #if os(macOS)
    @Environment(\.openWindow) private var openWindow
    #endif

    private var filteredSurahs: ([Surah], [Surah]) {
        let allSurahs = dataManager.surahs
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
        .settingsSheet()
        #if os(macOS)
        .toolbar {
            ToolbarItem {
                Button {
                    openWindow(id: "prayer-times")
                } label: {
                    Label("Prayer Times", systemImage: "clock")
                }
            }
        }
        #endif
    }
}
