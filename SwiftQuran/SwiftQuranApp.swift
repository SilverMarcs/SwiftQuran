import SwiftUI
import SwiftData

@main
struct SwiftQuranApp: App {
    @State var audioPlayerManager = AudioPlayerManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(audioPlayerManager)
                .task {
                    QuranDataManager.shared.loadQuranData()
                }
        }
        .commands { MenuCommands() }
    }
}
