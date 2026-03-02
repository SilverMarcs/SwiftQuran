import SwiftUI

struct VerseReferenceView: View {
    @Environment(QuranDataManager.self) private var dataManager

    let verse: Verse

    @State private var selectedSection: VerseReferenceSection = .tafseer
    @State private var tafseerText: String?
    @State private var commentaryText: String?
    @State private var hadiths: [VerseHadith] = []

    var body: some View {
        List {
            switch selectedSection {
            case .tafseer:
                VerseReferenceTextSection(
                    title: "Tafseer",
                    text: tafseerText,
                    emptyMessage: "No tafseer available for this ayah."
                )
            case .commentary:
                VerseReferenceTextSection(
                    title: "Commentary",
                    text: commentaryText,
                    emptyMessage: "No commentary available for this ayah."
                )
            case .hadith:
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
        .navigationTitle("Ayah \(verse.verseIndex)")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem {
                VerseReferencePicker(selection: $selectedSection)
            }
        }
        .task {
            tafseerText = dataManager.tafseer(for: verse)
            commentaryText = dataManager.commentary(for: verse)
            hadiths = dataManager.hadiths(for: verse)
        }
    }
}

private struct VerseReferencePicker: View {
    @Binding var selection: VerseReferenceSection

    var body: some View {
        Picker(selection.title, selection: $selection) {
            ForEach(VerseReferenceSection.allCases) { section in
                Text(section.title)
                    .tag(section)
            }
        }
        .pickerStyle(.menu)
    }
}

private struct VerseReferenceTextSection: View {
    let title: String
    let text: String?
    let emptyMessage: String

    var body: some View {
        if let text {
            Section(title) {
                Text(text)
                    .textSelection(.enabled)
            }
        } else {
            ContentUnavailableView(emptyMessage, systemImage: "text.page")
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

private enum VerseReferenceSection: String, CaseIterable, Identifiable {
    case tafseer
    case commentary
    case hadith

    var id: String { rawValue }

    var title: String {
        switch self {
        case .tafseer:
            "Tafseer"
        case .commentary:
            "Commentary"
        case .hadith:
            "Hadith"
        }
    }
}
