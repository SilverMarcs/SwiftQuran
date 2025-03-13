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
                    Text("\(surah.id)")
                        .foregroundStyle(.secondary)
                        #if !(macOS)
                        .padding(.trailing, 2)
                        #endif
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(surah.transliteration)
                            .font(.headline)
                        Text("\(surah.translation) • \(surah.name)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        if let progress = surah.readingProgress {
                            Text("\(progress.lastReadVerseId)/\(surah.totalVerses)")
                                .font(.subheadline)
                                .foregroundStyle(.tint)
                        } else {
                            Text("\(surah.totalVerses)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
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
