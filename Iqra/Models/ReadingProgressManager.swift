import Foundation

@Observable final class ReadingProgressManager {
    private let progressKey = "reading_progress"
    private let cloudStore = NSUbiquitousKeyValueStore.default

    private(set) var markedVerses: [Int: Int] = [:] // [surahNumber: verseNumber]

    init() {
        loadProgress()
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
        loadProgress()
    }

    func toggleProgress(for surahNumber: Int, verseNumber: Int) {
        if markedVerses[surahNumber] == verseNumber {
            markedVerses.removeValue(forKey: surahNumber)
        } else {
            markedVerses[surahNumber] = verseNumber
        }
        saveProgress()
    }

    func toggleProgress(for verse: Verse) {
        toggleProgress(for: verse.surahNumber, verseNumber: verse.verseIndex)
    }

    func resetProgress(for surahNumber: Int) {
        markedVerses.removeValue(forKey: surahNumber)
        saveProgress()
    }

    func getProgress(for surahNumber: Int) -> Int? {
        markedVerses[surahNumber]
    }

    func isProgress(for verse: Verse) -> Bool {
        getProgress(for: verse.surahNumber) == verse.verseIndex
    }

    private func loadProgress() {
        if let cloudData = cloudStore.array(forKey: progressKey) as? [[Int]] {
            markedVerses = Dictionary(uniqueKeysWithValues: cloudData.map { ($0[0], $0[1]) })
        }
    }

    private func saveProgress() {
        let data = markedVerses.map { [$0.key, $0.value] }
        cloudStore.set(data, forKey: progressKey)
        cloudStore.synchronize()
    }
}
