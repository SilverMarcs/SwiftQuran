import SwiftUI

struct ContentView: View {
    @ObservedObject var progressManager = ReadingProgressManager.shared
    @State private var selectedTab: Tabs = .surahList
    @State private var searchText: String = ""
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Surahs", systemImage: "book", value: .surahList) {
                NavigationStack {
                    SurahListTab()
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
                    SavedVersesListView()
                        .surahNavigationDestination()
                }
            }
        }
        .searchable(text: $searchText)
        .tabViewStyle(.sidebarAdaptable)
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
