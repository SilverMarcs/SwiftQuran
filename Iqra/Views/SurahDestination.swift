import SwiftUI

extension View {
    func surahNavigationDestination(shouldScrollToSavedProgress: Bool = false) -> some View {
        self
            .navigationDestination(for: Surah.self) { surah in
                SurahDetailDestinationView(
                    surah: surah,
                    shouldScrollToSavedProgress: shouldScrollToSavedProgress
                )
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
    let shouldScrollToSavedProgress: Bool

    var body: some View {
        SurahDetailView(
            surah: surah,
            dataManager: dataManager,
            shouldScrollToSavedProgress: shouldScrollToSavedProgress
        )
    }
}
