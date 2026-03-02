import SwiftUI

struct CommentaryReferenceView: View {
    @Environment(QuranDataManager.self) private var dataManager

    let verse: Verse

    private var text: String? {
        dataManager.commentary(for: verse)
    }

    var body: some View {
        List {
            if let text {
                Section("Commentary") {
                    Text(text)
                        .textSelection(.enabled)
                }
            } else {
                ContentUnavailableView("No commentary available for this ayah.", systemImage: "text.page")
            }
        }
    }
}
