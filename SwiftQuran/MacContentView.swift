import SwiftUI

struct MacContentView: View {
    @Environment(QuranDataManager.self) var dataManager

    @State private var selectedSurah: Surah?

    var body: some View {
        NavigationSplitView {
            SurahList()
                .safeAreaBar(edge: .bottom) {
                    InlineAudioPlayer()
                }
                .surahNavigationDestination()
                .navigationSplitViewColumnWidth(min: 220, ideal: 260, max: 320)
        } detail: {
            ScrollView {
                ContentUnavailableView("Select a Surah", systemImage: "book")
            }
            .defaultScrollAnchor(.center)
            .navigationSplitViewColumnWidth(min: 480, ideal: 720)
        }
    }
}

#Preview {
    MacContentView()
}
