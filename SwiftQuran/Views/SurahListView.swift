import SwiftUI
import SwiftData

struct SurahListView: View {
    @Query(sort: \Surah.id) private var surahs: [Surah]
    @Binding var selectedSurah: Surah?
    
    var body: some View {
        List(surahs, id: \.id, selection: $selectedSurah) { surah in
            NavigationLink(value: surah) {
                HStack(alignment: .center) {
                    VStack {
                        Text("\(surah.id)")
                        Spacer()
                    }
                    
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
        .navigationTitle("Surahs")
        #if os(macOS)
        .navigationSplitViewColumnWidth(min: 220, ideal: 250)
        #endif
    }
}
