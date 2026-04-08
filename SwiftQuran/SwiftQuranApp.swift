import SwiftUI

@main
struct SwiftQuranApp: App {
    let quranDataManager = QuranDataManager()
    let savedVersesManager = SavedVersesManager()
    let progressManager = ReadingProgressManager()
    let audioPlayerManager = AudioPlayerManager()

    var body: some Scene {
        WindowGroup {
            Group {
                #if os(macOS)
                MacContentView()
                #else
                ContentView()
                #endif
            }
            .environment(quranDataManager)
            .environment(savedVersesManager)
            .environment(progressManager)
            .environment(audioPlayerManager)
        }
        .commands { MenuCommands() }

        #if os(macOS)
        Window("Prayer Times", id: "prayer-times") {
            PrayerTimesTab()
        }
        .restorationBehavior(.disabled)
        .defaultSize(width: 360, height: 470)
        #endif
    }
}
