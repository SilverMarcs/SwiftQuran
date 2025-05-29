import SwiftUI

struct SurahDetailView: View {
    let surah: Surah
    @ObservedObject var progressManager = ReadingProgressManager.shared
    @ObservedObject private var audioPlayer = AudioPlayerManager.shared
    
    var body: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(Array(surah.verses.enumerated()), id: \.element.id) { index, verse in
                    VerseRow(verse: verse, surahNumber: surah.id, verseNumber: index + 1)
                }
                .padding(10)
            }
            .listStyle(.plain)
            .scrollContentBackground(.visible)
            .navigationTitle(surah.transliteration)
            .toolbarTitleDisplayMode(.inline)
            .toolbar { SurahToolbar(surah: surah) }
            #if os(macOS)
            .navigationSubtitle(surah.translation)
            #endif
            .onAppear {
                if let markedVerse = progressManager.getProgress(for: surah.id) {
                    let verseId = surah.verses[markedVerse - 1].id
                    proxy.scrollTo("verse\(verseId)", anchor: .top)
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                BottomAudioPlayer()
            }
        }
    }
}

#Preview {
    SurahDetailView(surah: Mock.surah)
}
