import SwiftUI

struct SurahDetailView: View {
    @Environment(ReadingProgressManager.self) var progressManager

    @State private var hasPerformedInitialScroll = false

    let dataManager: QuranDataManager
    let surah: Surah
    let initialVerseNumberToScrollTo: Int?
    let shouldScrollToSavedProgress: Bool

    let verses: [Verse]
    
    init(
        surah: Surah,
        dataManager: QuranDataManager,
        initialVerseNumberToScrollTo: Int? = nil,
        shouldScrollToSavedProgress: Bool = false
    ) {
        self.dataManager = dataManager
        self.surah = surah
        self.initialVerseNumberToScrollTo = initialVerseNumberToScrollTo
        self.shouldScrollToSavedProgress = shouldScrollToSavedProgress
        self.verses = dataManager.loadVerses(for: self.surah)
    }

    var body: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(verses, id: \.id) { verse in
                    VerseRow(verse: verse, surahTitle: surah.translation)
                        .id(scrollIdentifier(for: verse))
                    #if os(macOS)
                        .padding(7)
                    #endif
                }
            }
            .listStyle(.plain)
            .navigationTitle(surah.transliteration)
            .toolbarTitleDisplayMode(.inline)
            .toolbarTitleMenu {
                ForEach(verses) { verse in
                    Button {
                        proxy.scrollTo(scrollIdentifier(for: verse), anchor: .top)
                    } label: {
                        Text("Verse \(verse.verseIndex)")
                    }
                }
            }
            .toolbar {
                SurahToolbar(surah: surah)
            }
            .task {
                guard !hasPerformedInitialScroll else {
                    return
                }

                hasPerformedInitialScroll = true

                if let targetID = initialScrollIdentifier() {
                    proxy.scrollTo(targetID, anchor: .top)
                }
            }
            #if os(macOS)
            .navigationSubtitle(surah.translation)
            #endif
        }
    }

    private func scrollIdentifier(for verse: Verse) -> String {
        "verse\(verse.id)"
    }

    private func initialScrollIdentifier() -> String? {
        if let initial = initialVerseNumberToScrollTo, initial > 0, initial <= verses.count {
            return scrollIdentifier(for: verses[initial - 1])
        }

        if shouldScrollToSavedProgress,
           let markedVerse = progressManager.getProgress(for: surah.id),
           markedVerse > 0, markedVerse <= verses.count {
            return scrollIdentifier(for: verses[markedVerse - 1])
        }

        return nil
    }
}

#Preview {
    SurahDetailView(surah: Mock.surah, dataManager: QuranDataManager())
}
