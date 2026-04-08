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
        } detail: {
            ScrollView {
                ContentUnavailableView("Select a Surah", systemImage: "book")
            }
            .defaultScrollAnchor(.center)
        }
    }
}

#Preview {
    MacContentView()
}
