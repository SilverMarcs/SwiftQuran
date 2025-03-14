import SwiftUI
import SwiftData

struct SurahListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var readingProgress: [ReadingProgress]
    @Binding var selectedSurah: Surah?
    @State private var searchText = ""
    
    private var surahs: [Surah] {
        QuranDataManager.shared.surahs
    }
    
    private func getProgress(for surahId: Int) -> ReadingProgress? {
        readingProgress.first { $0.surahId == surahId }
    }
    
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
                        if let progress = getProgress(for: surah.id) {
                            Text("\(progress.lastReadVerseId ?? 0)/\(surah.totalVerses)")
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
