import SwiftUI

struct ContentView: View {
    @Environment(AudioPlayerManager.self) var audioManager
    
    @State private var selectedTab: Tabs = .surahList
    @State private var searchText: String = ""
    
    @Namespace private var audioPlayerAnimation
    
    var body: some View {
        @Bindable var manager = audioManager

        TabView(selection: $selectedTab) {
            Tab("Surahs", systemImage: "book", value: .surahList) {
                NavigationStack {
                    SurahList()
                        .surahNavigationDestination()
                }
            }
            
            Tab("Saved", systemImage: "heart", value: .saved) {
                NavigationStack {
                    SavedVersesList()
                        .surahNavigationDestination()
                }
            }
            
            Tab("Prayers", systemImage: "clock", value: .prayers) {
                NavigationStack {
                    PrayerTimesTab()
                }
            }
            
            Tab(value: .search, role: .search) {
                NavigationStack {
                    SurahSearchTab()
                        .surahNavigationDestination()
                }
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        .onOpenURL { url in
            if url.scheme == "swiftquran" && url.host == "prayers" {
                selectedTab = .prayers
            }
        }
        #if os(macOS)
        .tabViewSidebarBottomBar {
            InlineAudioPlayer()
                .padding()
        }
        #else
        .tabViewSearchActivation(.searchTabSelection)
        .tabBarMinimizeBehavior(.onScrollDown)
        .tabViewBottomAccessory(isEnabled: audioManager.currentVerse != nil) {
            InlineAudioPlayer()
                .matchedTransitionSource(id: "MINIPLAYER", in: audioPlayerAnimation)
        }
        .sheet(isPresented: $manager.isExpanded) {
            NavigationStack {
                ExpandedAudioPlayer()
                    .presentationDetents([.fraction(1/3.5)])
                    .presentationDragIndicator(.visible)
                    .presentationBackgroundInteraction(.enabled)
            }
            .navigationTransition(.zoom(sourceID: "MINIPLAYER", in: audioPlayerAnimation))
        }
        #endif
    }
}

enum Tabs: Equatable, Hashable {
    case surahList
    case search
    case saved
    case prayers
}

#Preview {
    ContentView()
}
