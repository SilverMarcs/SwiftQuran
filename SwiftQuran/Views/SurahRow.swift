import SwiftUI

struct SurahRow: View {
    let surah: Surah
    
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
            
            Text("\(surah.totalVerses)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    SurahRow(surah: Mock.surah)
}
