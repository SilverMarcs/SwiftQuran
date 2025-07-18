import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tabs = .surahList
    @State private var searchText: String = ""
    
    var body: some View {
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
                    SurahSearchTab(searchText: $searchText)
                        .surahNavigationDestination()
                }
            }
        }
        .searchable(text: $searchText)
        .tabViewStyle(.sidebarAdaptable)
        .onOpenURL { url in
            if url.scheme == "swiftquran" && url.host == "prayers" {
                selectedTab = .prayers
            }
        }
        #if os(macOS)
        .tabViewSidebarBottomBar {
            AudioPlayer()
                .padding()
        }
        #else
        .tabBarMinimizeBehavior(.onScrollDown)
        .tabViewBottomAccessory {
            if  AudioPlayerManager.shared.currentVerse != nil {
                AudioPlayer()
            }
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
