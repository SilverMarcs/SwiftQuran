import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedSurah: Surah?
    
    var body: some View {
        NavigationSplitView {
            SurahListView(selectedSurah: $selectedSurah)
        } detail: {
            SurahDetailView(surah: selectedSurah)
                .id(selectedSurah?.id)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [ReadingProgress.self], inMemory: true)
}
