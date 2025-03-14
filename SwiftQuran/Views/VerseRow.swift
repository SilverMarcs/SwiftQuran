import SwiftUI

struct VerseRow: View {
    let verse: Verse
    @ObservedObject var settings = AppSettings.shared
    
    var body: some View {
        VStack(spacing: 16) {
            Text(verse.text)
                .kerning(3)
                .font(.system(size: settings.arabicTextFontSize))
                .frame(maxWidth: .infinity, alignment: .leading)
                .environment(\.layoutDirection, .rightToLeft)
            
            Text("\(verse.id) • \(verse.translation)")
                .font(.system(size: settings.translationFontSize))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    VerseRow(verse: Mock.verse)
}
