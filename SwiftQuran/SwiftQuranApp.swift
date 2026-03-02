import SwiftUI
import SwiftData

@main
struct SwiftQuranApp: App {
    let quranDataManager = QuranDataManager()
    let savedVersesManager = SavedVersesManager()
    let progressManager = ReadingProgressManager()
    let audioPlayerManager = AudioPlayerManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(quranDataManager)
                .environment(savedVersesManager)
                .environment(progressManager)
                .environment(audioPlayerManager)
                .task {
                    quranDataManager.loadQuranData()
                }
        }
        .commands { MenuCommands() }
    }
}
