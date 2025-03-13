import SwiftUI

struct SurahDetailView: View {
    let surah: Surah?
    
    var body: some View {
        if let surah = surah {
            List {
                ForEach(surah.verses, id: \.id) { verse in
                    VStack(spacing: 16) {
                        Text(verse.text)
                            .font(.title)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        
                        Text("\(verse.id) • \(verse.translation)")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(8)
                    .listRowSeparator(.visible)
                }
            }
            .navigationTitle(surah.transliteration + " • " + surah.name)
            .navigationSubtitle(surah.translation)
            .listStyle(.plain)
            .toolbarTitleDisplayMode(.inline)
        } else {
            Text("Select a Surah")
                .font(.title)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    SurahDetailView(surah: nil)
}
