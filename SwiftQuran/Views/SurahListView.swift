import SwiftUI

struct SurahListView: View {
    @Binding var selectedSurah: Surah?
    @State private var searchText = ""
    @ObservedObject var progressManager = ReadingProgressManager.shared
    
    private var filteredSurahs: ([Surah], [Surah]) {
        let allSurahs = QuranDataManager.shared.surahs
        let filteredSurahs = searchText.isEmpty ? allSurahs : allSurahs.filter { surah in
            surah.translation.localizedCaseInsensitiveContains(searchText) ||
            surah.transliteration.localizedCaseInsensitiveContains(searchText)
        }
        
        let inProgress = filteredSurahs.filter { progressManager.getProgress(for: $0.id) != nil }
        let remaining = filteredSurahs.filter { progressManager.getProgress(for: $0.id) == nil }
        
        return (inProgress, remaining)
    }
    
    var body: some View {
        List(selection: $selectedSurah) {
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
        .searchable(text: $searchText, placement: .sidebar, prompt: "Search surahs")
        #if os(macOS)
        .navigationSplitViewColumnWidth(min: 220, ideal: 250)
        .task {
            selectedSurah = filteredSurahs.0.first
        }
        #endif
    }
}

#Preview {
   SurahListView(selectedSurah: .constant(Mock.surah))
}
