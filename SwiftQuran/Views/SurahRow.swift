import SwiftUI

struct SurahRow: View {
    let surah: Surah
    @ObservedObject var progressManager = ReadingProgressManager.shared
    
    var body: some View {
        HStack(alignment: .center) {
            Text("\(surah.id)")
                .foregroundStyle(.secondary)
                #if !(macOS)
                .padding(.trailing, 2)
                #endif
            
            VStack(alignment: .leading, spacing: 4) {
                Text(surah.transliteration)
                    .font(.headline)
                Text("\(surah.translation) • \(surah.name)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            if let markedVerse = progressManager.getProgress(for: surah.id) {
                Text("\(markedVerse)/\(surah.totalVerses)")
                    .font(.subheadline)
                    .foregroundStyle(.accent)
            } else {
                Text("\(surah.totalVerses)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .swipeActions(edge: .trailing) {
            if progressManager.getProgress(for: surah.id) != nil {
                Button(role: .destructive) {
                    progressManager.resetProgress(for: surah.id)
                } label: {
                    Label("Reset Progress", systemImage: "arrow.counterclockwise")
                }
            }
        }
    }
}

#Preview {
   SurahRow(surah: Mock.surah)
}
