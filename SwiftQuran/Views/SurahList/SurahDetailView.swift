import SwiftUI

struct SurahDetailView: View {
    let surah: Surah
    let initialVerseNumberToScrollTo: Int?
    @Environment(ReadingProgressManager.self) var progressManager

    @State private var verses: [Verse] = []

    init(surah: Surah, initialVerseNumberToScrollTo: Int? = nil) {
        self.surah = surah
        self.initialVerseNumberToScrollTo = initialVerseNumberToScrollTo
    }

    var body: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(verses, id: \.id) { verse in
                    VerseRow(verse: verse, surahTitle: surah.translation)
                        .listRowSeparator(.hidden, edges: .top)
                        .listRowSeparator(.visible, edges: .bottom)
                }
                .padding(10)
            }
            .listStyle(.plain)
            .scrollContentBackground(.visible)
            .navigationTitle(surah.transliteration)
            .toolbarTitleDisplayMode(.inline)
            .toolbarTitleMenu {
                Menu {
                    ForEach(verses) { verse in
                        Button(action: {
                            proxy.scrollTo("verse\(verse.id)", anchor: .top)
                        }) {
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
                verses = QuranDatabase.shared.loadVerses(for: surah)
            }
            .onAppear {
                scrollToInitial(proxy: proxy)
            }
            #if os(macOS)
            .navigationSubtitle(surah.translation)
            #endif
        }
    }

    private func scrollToInitial(proxy: ScrollViewProxy) {
        if let initial = initialVerseNumberToScrollTo, initial > 0, initial <= verses.count {
            let verseId = verses[initial - 1].id
            proxy.scrollTo("verse\(verseId)", anchor: .top)
        } else if let markedVerse = progressManager.getProgress(for: surah.id),
                  markedVerse > 0, markedVerse <= verses.count {
            let verseId = verses[markedVerse - 1].id
            proxy.scrollTo("verse\(verseId)", anchor: .top)
        }
    }
}

#Preview {
    SurahDetailView(surah: Mock.surah)
}
