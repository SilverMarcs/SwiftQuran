import SwiftUI
import SwiftData

struct SurahListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var readingProgress: [ReadingProgress]
    @Binding var selectedSurah: Surah?
    @State private var searchText = ""
    
    private var recentSurahs: [Surah] {
        let surahsWithProgress = surahs.filter { surah in
            readingProgress.contains { $0.surahId == surah.id }
        }
        
        return surahsWithProgress
            .sorted { surah1, surah2 in
                let progress1 = getProgress(for: surah1.id)
                let progress2 = getProgress(for: surah2.id)
                return (progress1?.lastReadAt ?? .distantPast) > (progress2?.lastReadAt ?? .distantPast)
            }
            .prefix(5)
            .map { $0 }
    }
    
    private var remainingSurahs: [Surah] {
        let recentIds = Set(recentSurahs.map { $0.id })
        return surahs.filter { !recentIds.contains($0.id) }
    }
    
    private var surahs: [Surah] {
        QuranDataManager.shared.surahs
    }
    
    private func getProgress(for surahId: Int) -> ReadingProgress? {
        readingProgress.first { $0.surahId == surahId }
    }
    
    var body: some View {
        List(selection: $selectedSurah) {
            if !recentSurahs.isEmpty {
                Section("Recently Read") {
                    ForEach(recentSurahs.filter { surah in
                        searchText.isEmpty || 
                        surah.translation.localizedCaseInsensitiveContains(searchText) ||
                        surah.transliteration.localizedCaseInsensitiveContains(searchText)
                    }, id: \.id) { surah in
                        NavigationLink(value: surah) {
                            SurahRow(surah: surah, progress: getProgress(for: surah.id))
                        }
                    }
                }
            }
            
            Section("All Surahs") {
                ForEach(remainingSurahs.filter { surah in
                    searchText.isEmpty || 
                    surah.translation.localizedCaseInsensitiveContains(searchText) ||
                    surah.transliteration.localizedCaseInsensitiveContains(searchText)
                }, id: \.id) { surah in
                    NavigationLink(value: surah) {
                        SurahRow(surah: surah, progress: getProgress(for: surah.id))
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

struct SurahRow: View {
    let surah: Surah
    let progress: ReadingProgress?
    
    var body: some View {
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
                if let progress = progress {
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
