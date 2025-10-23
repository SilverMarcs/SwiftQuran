import Foundation

@Observable final class ReadingProgressManager {
    static let shared = ReadingProgressManager()
    private let progressKey = "reading_progress"
    private let cloudStore = NSUbiquitousKeyValueStore.default
    
    private(set) var markedVerses: [Int: Int] = [:] // [surahNumber: verseNumber]
    
    private init() {
        loadProgress()
        setupCloudSync()
    }
    
    private func setupCloudSync() {
        // Sync from iCloud on startup
        cloudStore.synchronize()
        
        // Listen for iCloud changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCloudUpdate),
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: cloudStore
        )
    }
    
    @objc private func handleCloudUpdate(_ notification: Notification) {
        // Reload progress when iCloud data changes
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
    
    // Convenience method that works directly with Verse objects
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
    
    // Convenience method to check if a specific verse is the marked progress
    func isProgress(for verse: Verse) -> Bool {
        return getProgress(for: verse.surahNumber) == verse.verseIndex
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
