import SwiftUI

struct SavedVersesList: View {
    var savedVersesManager = SavedVersesManager.shared
    
    @State private var savedVerses: [Verse] = []
    @State private var showSettings = false
    
    private var groupedVerses: [(Surah, [Verse])] {
        let grouped = Dictionary(grouping: savedVerses) { verse in
            verse.surah
        }
        
        return grouped.compactMap { (surah, verses) in
            guard let surah = surah else { return nil }
            let sortedVerses = verses.sorted { $0.verseIndex < $1.verseIndex }
            return (surah, sortedVerses)
        }.sorted { $0.0.id < $1.0.id }
    }
    
    var body: some View {
        List {
            if savedVerses.isEmpty {
                Text("No saved verses")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowSeparator(.hidden)
            } else {
                ForEach(groupedVerses, id: \.0.id) { surah, verses in
                    Section(header: Text(surah.translation)) {
                        ForEach(verses, id: \.id) { verse in
                            NavigationLink(destination: SurahDetailView(surah: surah, initialVerseNumberToScrollTo: verse.verseIndex)) {
                                SavedVerseRow(verse: verse)
                            }
                            .swipeActions(edge: .trailing) {
                                Button("Unfavorite", systemImage: "heart.slash", role: .destructive) {
                                    savedVersesManager.toggleSaved(verse: verse)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Saved")
        .toolbarTitleDisplayMode(.inlineLarge)
        .task(id: savedVersesManager.savedVerses) {
            savedVerses = savedVersesManager.getSavedVersesData()
        }
        #if !os(macOS)
        .toolbar {
            SettingsToolbar(showSettings: $showSettings)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        #endif
    }
}

#Preview {
    SavedVersesList()
}
