import SwiftUI

struct VerseReferenceView: View {
    @Environment(QuranDataManager.self) private var dataManager

    let verse: Verse

    @State private var selectedSection: VerseReferenceSection = .tafseer

    private var surahTitle: String? {
        dataManager.surah(id: verse.surahNumber)?.transliteration
    }

    var body: some View {
        Group {
            switch selectedSection {
            case .tafseer:
                TafseerReferenceView(verse: verse)
            case .commentary:
                CommentaryReferenceView(verse: verse)
            case .hadith:
                HadithReferenceView(verse: verse)
            }
        }
        .navigationTitle("Ayah \(verse.verseIndex)")
        .navigationSubtitle(surahTitle ?? "")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            Menu {
                Picker(selection: $selectedSection) {
                    ForEach(VerseReferenceSection.allCases) { section in
                        Label(section.title, systemImage: section.symbol)
                            .tag(section)
                    }
                } label: {
                    Label(selectedSection.title, systemImage: selectedSection.symbol)
                }
            } label: {
                Label(selectedSection.title, systemImage: selectedSection.symbol)
            }
        }
    }
}
