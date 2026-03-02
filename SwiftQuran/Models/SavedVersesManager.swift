import Foundation

@Observable
final class SavedVersesManager {
    private let savedVersesKey = "saved_verses"
    private let cloudStore = NSUbiquitousKeyValueStore.default

    private(set) var savedVerses: Set<String> = [] // Set of "surahNumber_verseNumber"

    init() {
        loadSavedVerses()
        setupCloudSync()
    }

    private func setupCloudSync() {
        cloudStore.synchronize()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCloudUpdate),
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: cloudStore
        )
    }

    @objc private func handleCloudUpdate(_ notification: Notification) {
        loadSavedVerses()
    }

    func toggleSaved(verse: Verse) {
        if savedVerses.contains(verse.verseKey) {
            savedVerses.remove(verse.verseKey)
        } else {
            savedVerses.insert(verse.verseKey)
        }
        saveSavedVerses()
    }

    func isSaved(verse: Verse) -> Bool {
        savedVerses.contains(verse.verseKey)
    }

    private func loadSavedVerses() {
        if let cloudData = cloudStore.array(forKey: savedVersesKey) as? [String] {
            savedVerses = Set(cloudData)
        }
    }

    private func saveSavedVerses() {
        let data = Array(savedVerses)
        cloudStore.set(data, forKey: savedVersesKey)
        cloudStore.synchronize()
    }
}
