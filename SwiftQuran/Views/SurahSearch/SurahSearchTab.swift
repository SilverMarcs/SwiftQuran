import SwiftUI

struct SurahSearchTab: View {
    @State private var searchText: String = ""
    
    private var surahs: [Surah] {
        let allSurahs = QuranDataManager.shared.surahs
        if searchText.isEmpty { return allSurahs }
        return allSurahs.filter { surah in
            surah.transliteration.localizedCaseInsensitiveContains(searchText) ||
            "\(surah.id)".contains(searchText)
        }
    }

    var body: some View {
        List(surahs, id: \.id) { surah in
            NavigationLink(value: surah) {
                SurahRow(surah: surah)
            }
        }
        .contentMargins(.top, 10)
        .searchable(text: $searchText, prompt: "Search surahs")
        .searchPresentationToolbarBehavior(.avoidHidingContent)
        .navigationTitle("Search")
        .toolbarTitleDisplayMode(.inlineLarge)
    }
}

#Preview {
    SurahSearchTab()
}
