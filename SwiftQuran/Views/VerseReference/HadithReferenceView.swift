import SwiftUI

struct HadithReferenceView: View {
    @Environment(QuranDataManager.self) private var dataManager

    let verse: Verse

    private var hadiths: [VerseHadith] {
        dataManager.hadiths(for: verse)
    }

    var body: some View {
        List {
            if hadiths.isEmpty {
                ContentUnavailableView("No hadith available for this ayah.", systemImage: "books.vertical")
            } else {
                Section("Hadith") {
                    ForEach(hadiths) { hadith in
                        VerseHadithRow(hadith: hadith)
                    }
                }
            }
        }
    }
}

private struct VerseHadithRow: View {
    let hadith: VerseHadith

    var body: some View {
        VStack(alignment: .leading) {
            Text("Hadith \(hadith.number)")
                .bold()

            Text(hadith.text)
                .textSelection(.enabled)
        }
    }
}
