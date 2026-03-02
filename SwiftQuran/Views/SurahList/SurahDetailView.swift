import SwiftUI

struct SurahDetailView: View {
    @Environment(QuranDataManager.self) var dataManager
    @Environment(ReadingProgressManager.self) var progressManager

    let surah: Surah
    let initialVerseNumberToScrollTo: Int?

    @State private var verses: [Verse] = []
    @State private var scrollPosition = ScrollPosition(idType: String.self)

    init(surah: Surah, initialVerseNumberToScrollTo: Int? = nil) {
        self.surah = surah
        self.initialVerseNumberToScrollTo = initialVerseNumberToScrollTo
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(verses, id: \.id) { verse in
                    VerseRow(verse: verse, surahTitle: surah.translation)
                        .padding(10)
                        .id(scrollIdentifier(for: verse))

                    Divider()
                }
            }
            .scrollTargetLayout()
        }
        .contentMargins(7)
        .scrollPosition($scrollPosition, anchor: .top)
        .navigationTitle(surah.transliteration)
        .toolbarTitleDisplayMode(.inline)
        .toolbarTitleMenu {
            Menu {
                ForEach(verses) { verse in
                    Button {
                        scrollToVerse(verse)
                    } label: {
                        Text("Verse \(verse.verseIndex)")
                    }
                }
            } label: {
                Label("Verse List", systemImage: "list.bullet")
            }
        }
        .toolbar {
            SurahToolbar(surah: surah)
        }
        .task {
            verses = dataManager.loadVerses(for: surah)

            if let targetID = initialScrollIdentifier() {
                scrollPosition.scrollTo(id: targetID, anchor: .top)
            }
        }
        #if os(macOS)
        .navigationSubtitle(surah.translation)
        #endif
    }

    private func scrollToVerse(_ verse: Verse) {
        scrollPosition.scrollTo(id: scrollIdentifier(for: verse), anchor: .top)
    }

    private func scrollIdentifier(for verse: Verse) -> String {
        "verse\(verse.id)"
    }

    private func initialScrollIdentifier() -> String? {
        if let initial = initialVerseNumberToScrollTo, initial > 0, initial <= verses.count {
            return scrollIdentifier(for: verses[initial - 1])
        }

        if let markedVerse = progressManager.getProgress(for: surah.id),
           markedVerse > 0, markedVerse <= verses.count {
            return scrollIdentifier(for: verses[markedVerse - 1])
        }

        return nil
    }
}

#Preview {
    SurahDetailView(surah: Mock.surah)
}
