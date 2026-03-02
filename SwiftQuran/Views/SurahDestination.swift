import SwiftUI

extension View {
    func surahNavigationDestination() -> some View {
        self
            .navigationDestination(for: Surah.self) { surah in
                SurahDetailDestinationView(surah: surah)
                    .id(surah.id)
            }
            .navigationDestination(for: Verse.self) { verse in
                VerseReferenceView(verse: verse)
            }
    }
}

private struct SurahDetailDestinationView: View {
    @Environment(QuranDataManager.self) private var dataManager

    let surah: Surah

    var body: some View {
        SurahDetailView(surah: surah, dataManager: dataManager)
    }
}
