import SwiftUI

struct TafseerReferenceView: View {
    @Environment(QuranDataManager.self) private var dataManager

    let verse: Verse

    private var text: String? {
        dataManager.tafseer(for: verse)
    }

    var body: some View {
        List {
            if let text {
                Section("Tafseer") {
                    Text(text)
                        .textSelection(.enabled)
                }
            } else {
                ContentUnavailableView("No tafseer available for this ayah.", systemImage: "text.page")
            }
        }
    }
}
