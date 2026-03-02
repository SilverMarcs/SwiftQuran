import SwiftUI

extension View {
    func surahNavigationDestination() -> some View {
        self
            .navigationDestination(for: Surah.self) { surah in
                SurahDetailView(surah: surah)
                    .id(surah.id)
            }
            .navigationDestination(for: Verse.self) { verse in
                VerseReferenceView(verse: verse)
            }
    }
}
