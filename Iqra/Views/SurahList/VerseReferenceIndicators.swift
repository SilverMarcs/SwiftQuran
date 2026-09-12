import SwiftUI

struct VerseReferenceIndicators: View {
    @Environment(QuranDataManager.self) private var dataManager

    let verse: Verse

    var body: some View {
        HStack {
            ForEach(dataManager.availableReferenceSections(for: verse)) { section in
                Image(systemName: section.symbol)
                    .accessibilityLabel("\(section.title) available")
                    .help("\(section.title) available")
            }
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }
}
