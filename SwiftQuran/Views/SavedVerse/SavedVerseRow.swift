import SwiftUI

struct SavedVerseRow: View {
    let verse: Verse
    
    @ObservedObject var settings = AppSettings.shared
    
    var body: some View {
        VStack(spacing: 8) {
            Text(verse.text)
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .environment(\.layoutDirection, .rightToLeft)
                .lineLimit(1)
                .truncationMode(.tail)
            
            Text("\(verse.verseIndex) • \(verse.translation)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(1)
                .truncationMode(.tail)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    SavedVerseRow(verse: Mock.verse)
        .padding()
}
