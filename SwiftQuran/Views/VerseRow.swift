import SwiftUI

struct VerseRow: View {
    let verse: Verse
    let surahNumber: Int
    let verseNumber: Int
    @ObservedObject var settings = AppSettings.shared
    @ObservedObject var progressManager = ReadingProgressManager.shared
    
    var body: some View {
        VStack(spacing: 16) {
            Text(verse.text)
                .kerning(3)
                .font(.system(size: settings.arabicTextFontSize))
                .frame(maxWidth: .infinity, alignment: .leading)
                .environment(\.layoutDirection, .rightToLeft)
            
            HStack(alignment: .bottom) {
                Text("\(verseNumber) • \(verse.translation)")
                    .font(.system(size: settings.translationFontSize))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Button {
                    progressManager.toggleProgress(for: surahNumber, verseNumber: verseNumber)
                } label: {
                    Image(systemName: progressManager.getProgress(for: surahNumber) == verseNumber ? "bookmark.fill" : "bookmark")
                }
                .buttonStyle(.plain)
                .foregroundStyle(progressManager.getProgress(for: surahNumber) == verseNumber ? .accent : .secondary)
            }
        }
        .id("verse\(verse.id)")
    }
}

#Preview {
    VerseRow(verse: Mock.verse, surahNumber: 1, verseNumber: 1)
}
