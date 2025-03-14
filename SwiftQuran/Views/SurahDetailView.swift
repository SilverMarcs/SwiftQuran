import SwiftUI

struct SurahDetailView: View {
    let surah: Surah
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(surah.verses, id: \.id) { verse in
                    VerseRow(verse: verse)
                        .id(verse.id)
                }
                .padding(.horizontal)
            }
            .scrollTargetLayout()
        }
        .background(.background)
        .scrollContentBackground(.visible)
        .navigationTitle(surah.transliteration)
        .toolbarTitleDisplayMode(.inline)
        .toolbar { SurahToolbar(surah: surah) }
        #if os(macOS)
        .navigationSubtitle(surah.translation)
        #endif
    }
}

//#Preview {
//    SurahDetailView(surah: .sample)
//}
