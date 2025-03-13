import SwiftUI

struct SurahDetailView: View {
    let surah: Surah?
    
    var body: some View {
        if let surah = surah {
            List {
                Section {
                    VStack(spacing: 8) {
                        Text(surah.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("\(surah.transliteration) • \(surah.translation)")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                        
                        Text("\(surah.type.capitalized) • \(surah.totalVerses) verses")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
                
                Section {
                    ForEach(surah.verses, id: \.id) { verse in
                        VStack(spacing: 16) {
                            Text(verse.text)
                                .font(.title)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                            
                            Text(verse.translation)
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                            
                            Text("Verse \(verse.id)")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.vertical, 8)
                        .listRowSeparator(.hidden)
                    }
                }
            }
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
