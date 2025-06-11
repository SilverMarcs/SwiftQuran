import SwiftUI

struct SavedVersesListView: View {
    @ObservedObject var savedVersesManager = SavedVersesManager.shared
    @State private var savedVersesData: [(verse: Verse, surahName: String, surahNumber: Int, verseNumber: Int)] = []
    
    var body: some View {
        List {
            if savedVersesData.isEmpty {
                Text("No saved verses")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowSeparator(.hidden)
            } else {
                ForEach(savedVersesData, id: \.verse.id) { item in
                    if let surah = QuranDataManager.shared.surahs.first(where: { $0.id == item.surahNumber }) {
                        NavigationLink(destination: SurahDetailView(surah: surah, initialVerseNumberToScrollTo: item.verseNumber)) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(item.surahName)
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                                
                                SavedVerseRow(
                                    verse: item.verse,
                                    surahNumber: item.surahNumber,
                                    verseNumber: item.verseNumber
                                )
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Saved Verses")
        .toolbarTitleDisplayMode(.inlineLarge)
        .onAppear {
            loadSavedVersesData()
        }
        .onChange(of: savedVersesManager.savedVerses) {
            loadSavedVersesData()
        }
    }
    
    private func loadSavedVersesData() {
        let savedVerses = savedVersesManager.getSavedVerses()
        let quranData = QuranDataManager.shared
        
        savedVersesData = savedVerses.compactMap { savedVerse in
            guard let surah = quranData.surahs.first(where: { $0.id == savedVerse.surahNumber }),
                  savedVerse.verseNumber > 0 && savedVerse.verseNumber <= surah.verses.count else {
                return nil
            }
            
            let verse = surah.verses[savedVerse.verseNumber - 1]
            return (
                verse: verse,
                surahName: surah.translation,
                surahNumber: savedVerse.surahNumber,
                verseNumber: savedVerse.verseNumber
            )
        }
    }
}

#Preview {
    SavedVersesListView()
}
