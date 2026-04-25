import SwiftUI

@main
struct SwiftQuranApp: App {
    let quranDataManager = QuranDataManager()
    let savedVersesManager = SavedVersesManager()
    let progressManager = ReadingProgressManager()
    let audioPlayerManager = AudioPlayerManager()

    var body: some Scene {
        #if os(macOS)
        Window("Quran", id: "main") {
            MacContentView()
                .environment(quranDataManager)
                .environment(savedVersesManager)
                .environment(progressManager)
                .environment(audioPlayerManager)
        }
        .commands { MenuCommands() }

        Window("Prayer Times", id: "prayer-times") {
            PrayerTimesTab()
        }
        .restorationBehavior(.disabled)
        .defaultSize(width: 360, height: 470)
        #else
        WindowGroup {
            ContentView()
                .environment(quranDataManager)
                .environment(savedVersesManager)
                .environment(progressManager)
                .environment(audioPlayerManager)
        }
        .commands { MenuCommands() }
        #endif
    }
}
