import SwiftUI

struct ContentView: View {
    @State private var selectedSurah: Surah?
    
    var body: some View {
        NavigationSplitView {
            SurahListView(selectedSurah: $selectedSurah)
        } detail: {
            SurahDetailView(surah: selectedSurah)
                .id(selectedSurah)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Surah.self, Verse.self], inMemory: true)
}
