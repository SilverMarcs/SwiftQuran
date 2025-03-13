import SwiftUI
import SwiftData

struct SurahListView: View {
    @Query(sort: \Surah.id) private var surahs: [Surah]
    @Binding var selectedSurah: Surah?
    @State private var searchText = ""
    
    var filteredSurahs: [Surah] {
        if searchText.isEmpty {
            return surahs
        }
        return surahs.filter { surah in
            surah.translation.localizedCaseInsensitiveContains(searchText) ||
            surah.transliteration.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        List(filteredSurahs, id: \.id, selection: $selectedSurah) { surah in
            NavigationLink(value: surah) {
                HStack(alignment: .center) {
                    VStack {
                        Text("\(surah.id)")
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(surah.transliteration)
                            .font(.headline)
                        Text("\(surah.translation) • \(surah.name)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Text("\(surah.totalVerses)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
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
