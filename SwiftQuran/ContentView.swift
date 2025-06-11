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
                        .navigationDestination(for: Surah.self) { surah in
                            SurahDetailView(surah: surah)
                                .id(surah.id)
                        }
                }
            }
            
            Tab(value: .search, role: .search) {
                NavigationStack {
                    SurahSearchTab(searchText: $searchText)
                        .navigationDestination(for: Surah.self) { surah in
                            SurahDetailView(surah: surah)
                                .id(surah.id)
                        }
                }
            }
            
            Tab("Saved", systemImage: "heart", value: .saved) {
                NavigationStack {
                    SavedVersesListView()
                        .navigationDestination(for: Surah.self) { surah in
                            SurahDetailView(surah: surah)
                                .id(surah.id)
                        }
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
