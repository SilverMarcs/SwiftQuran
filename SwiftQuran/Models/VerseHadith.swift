import Foundation

struct VerseHadith: Identifiable, Hashable {
    let id: Int
    let number: Int
    let text: String
}

enum VerseReferenceSection: String, CaseIterable, Identifiable {
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

    var symbol: String {
        switch self {
        case .tafseer:
            "text.book.closed"
        case .commentary:
            "text.bubble"
        case .hadith:
            "books.vertical"
        }
    }
}
