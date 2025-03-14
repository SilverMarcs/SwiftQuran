import SwiftUI

struct SurahDetailView: View {
    let surah: Surah
    
    var body: some View {
        List {
            ForEach(surah.verses, id: \.id) { verse in
                VerseRow(verse: verse)
                    .id(verse.id)
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
    }
}

#Preview {
    SurahDetailView(surah: Mock.surah)
}
