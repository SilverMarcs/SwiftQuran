import SwiftUI

struct SurahDetailView: View {
    let surah: Surah
    let initialVerseNumberToScrollTo: Int?
    @ObservedObject var progressManager = ReadingProgressManager.shared
    @ObservedObject private var audioPlayer = AudioPlayerManager.shared
    @State private var showingVerseList = false
    
    init(surah: Surah, initialVerseNumberToScrollTo: Int? = nil) {
        self.surah = surah
        self.initialVerseNumberToScrollTo = initialVerseNumberToScrollTo
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(surah.verses, id: \.id) { verse in
                    VerseRow(verse: verse)
                }
                .padding(10)
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                BottomAudioPlayer()
            }
            .listStyle(.plain)
            .scrollContentBackground(.visible)
            .navigationTitle(surah.transliteration)
            .toolbarTitleDisplayMode(.inline)
            .toolbarTitleMenu {
                Menu {
                    ForEach(surah.verses) { verse in
                        Button(action: {
                            proxy.scrollTo("verse\(verse.id)", anchor: .top)
                        }) {
                            Text("Verse \(verse.id)")
                        }
                    }
                } label: {
                    Label("Verse List", systemImage: "list.bullet")
                }
            }
            .toolbar {
                SurahToolbar(surah: surah)
            }
            .onAppear {
                if let initial = initialVerseNumberToScrollTo, initial > 0, initial <= surah.verses.count {
                    let verseId = surah.verses[initial - 1].id
                    proxy.scrollTo("verse\(verseId)", anchor: .top)
                } else if let markedVerse = progressManager.getProgress(for: surah.id) {
                    let verseId = surah.verses[markedVerse - 1].id
                    proxy.scrollTo("verse\(verseId)", anchor: .top)
                }
            }
            #if os(macOS)
            .navigationSubtitle(surah.translation)
            #else
            .toolbar(.hidden, for: .tabBar)
            #endif
        }
    }
}

#Preview {
    SurahDetailView(surah: Mock.surah)
}
