import SwiftUI

struct SavedVersesListView: View {
    @ObservedObject var savedVersesManager = SavedVersesManager.shared
    @State private var savedVerses: [Verse] = []
    
    var body: some View {
        List {
            if savedVerses.isEmpty {
                Text("No saved verses")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowSeparator(.hidden)
            } else {
                ForEach(savedVerses, id: \.id) { verse in
                    if let surah = verse.surah {
                        NavigationLink(destination: SurahDetailView(surah: surah, initialVerseNumberToScrollTo: verse.verseIndex)) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(surah.translation)
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                                
                                SavedVerseRow(verse: verse)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Saved Verses")
        .toolbarTitleDisplayMode(.inlineLarge)
        .onAppear {
            loadSavedVerses()
        }
        .onChange(of: savedVersesManager.savedVerses) {
            loadSavedVerses()
        }
    }
    
    private func loadSavedVerses() {
        savedVerses = savedVersesManager.getSavedVersesData()
    }
}

#Preview {
    SavedVersesListView()
}
