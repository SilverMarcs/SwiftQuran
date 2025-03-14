import SwiftUI

struct SurahListView: View {
    @Binding var selectedSurah: Surah?
    @State private var searchText = ""
    
    private var surahs: [Surah] {
        QuranDataManager.shared.surahs
    }
    
    var body: some View {
        List(selection: $selectedSurah) {
            Section("All Surahs") {
                ForEach(surahs.filter { surah in
                    searchText.isEmpty || 
                    surah.translation.localizedCaseInsensitiveContains(searchText) ||
                    surah.transliteration.localizedCaseInsensitiveContains(searchText)
                }, id: \.id) { surah in
                    NavigationLink(value: surah) {
                        SurahRow(surah: surah)
                    }
                }
            }
        }
        .navigationTitle("Surahs")
        .searchable(text: $searchText, placement: .sidebar, prompt: "Search surahs")
        #if os(macOS)
        .navigationSplitViewColumnWidth(min: 220, ideal: 250)
        #endif
    }
}
