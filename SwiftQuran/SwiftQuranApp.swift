import SwiftUI
import SwiftData

@main
struct SwiftQuranApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    QuranDataManager.shared.loadQuranData()
                }
        }
        .commands { MenuCommands() }
    }
}
