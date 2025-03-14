import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedSurah: Surah?
    
    var body: some View {
        NavigationSplitView {
            SurahListView(selectedSurah: $selectedSurah)
        } detail: {
            if let surah = selectedSurah {
                SurahDetailView(surah: surah)
                    .id(surah.id)
            }
        }
    }
}

#Preview {
    ContentView()
}
