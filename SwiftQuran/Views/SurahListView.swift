import SwiftUI

struct SurahListView: View {
    @Binding var selectedSurah: Surah?
    @State private var searchText = ""
    
    private var surahs: [Surah] {
        let allSurahs = QuranDataManager.shared.surahs
        
        if searchText.isEmpty {
            return allSurahs
        } else {
            return allSurahs.filter { surah in
                surah.translation.localizedCaseInsensitiveContains(searchText) ||
                surah.transliteration.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        List(selection: $selectedSurah) {
            Section("All Surahs") {
                ForEach(surahs, id: \.id) { surah in
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

#Preview {
    SurahListView(selectedSurah: .constant(Mock.surah))
}
