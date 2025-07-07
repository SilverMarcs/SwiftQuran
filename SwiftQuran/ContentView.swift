import SwiftUI

struct ContentView: View {
    @ObservedObject var progressManager = ReadingProgressManager.shared
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
            
            Tab(value: .search, role: .search) {
                NavigationStack {
                    SurahSearchTab(searchText: $searchText)
                        .surahNavigationDestination()
                }
            }
            
            Tab("Saved", systemImage: "heart", value: .saved) {
                NavigationStack {
                    SavedVersesList()
                        .surahNavigationDestination()
                }
            }
        }
        .searchable(text: $searchText)
        .tabViewStyle(.sidebarAdaptable)
        #if os(macOS)
        .tabViewSidebarBottomBar {
            AudioPlayer()
                .padding()
        }
        #else
        .tabBarMinimizeBehavior(.onScrollDown)
        .tabViewBottomAccessory {
            AudioPlayer()
        }
        #endif
    }
}

enum Tabs: Equatable, Hashable {
    case surahList
    case search
    case saved
}

#Preview {
    ContentView()
}
