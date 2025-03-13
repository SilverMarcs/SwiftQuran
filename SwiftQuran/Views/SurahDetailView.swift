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
                    .padding(.vertical, 8)
                    .listRowSeparator(.visible)
                }
            }
            .navigationTitle(surah.translation + " • " + surah.name)
//            .navigationSubtitle(surah.name + " • " + surah.type.capitalized)
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
