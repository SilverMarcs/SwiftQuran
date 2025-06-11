import SwiftUI

struct SavedVerseRow: View {
    let verse: Verse
    let surahNumber: Int
    let verseNumber: Int
    
    @ObservedObject var settings = AppSettings.shared
    
    var body: some View {
        VStack(spacing: 8) {
            Text(verse.text)
                .font(.system(size: settings.arabicTextFontSize))
                .frame(maxWidth: .infinity, alignment: .leading)
                .environment(\.layoutDirection, .rightToLeft)
                .lineLimit(1)
                .truncationMode(.tail)
            
            Text("\(verseNumber) • \(verse.translation)")
                .font(.system(size: settings.translationFontSize))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(1)
                .truncationMode(.tail)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    SavedVerseRow(verse: Mock.verse, surahNumber: 1, verseNumber: 1)
        .padding()
}