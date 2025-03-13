import SwiftUI
import SwiftData

@main
struct SwiftQuranApp: App {
    @State private var importer: BackgroundImporter?
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Surah.self,
            Verse.self
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
                    if importer == nil {
                        importer = BackgroundImporter(modelContainer: sharedModelContainer)
                        try? await importer?.fetchAndImportQuran()
                    }
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
