import SwiftUI
import SwiftData

@main
struct SwiftQuranApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ReadingProgress.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    QuranDataManager.shared.loadQuranData()
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
