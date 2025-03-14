import Foundation

@MainActor
final class ReadingProgressManager: ObservableObject {
    static let shared = ReadingProgressManager()
    private let store = NSUbiquitousKeyValueStore.default
    private let progressKey = "reading_progress"
    
    @Published private(set) var markedVerses: [Int: Int] = [:] // [surahNumber: verseNumber]
    
    private init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(storeDidChange),
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: NSUbiquitousKeyValueStore.default
        )
        
        loadProgress()
        store.synchronize()
    }
    
    func toggleProgress(for surahNumber: Int, verseNumber: Int) {
        if markedVerses[surahNumber] == verseNumber {
            markedVerses.removeValue(forKey: surahNumber)
        } else {
            markedVerses[surahNumber] = verseNumber
        }
        saveProgress()
    }
    
    func resetProgress(for surahNumber: Int) {
        markedVerses.removeValue(forKey: surahNumber)
        saveProgress()
    }
    
    func getProgress(for surahNumber: Int) -> Int? {
        markedVerses[surahNumber]
    }
    
    private func loadProgress() {
        if let data = store.array(forKey: progressKey) as? [[Int]] {
            markedVerses = Dictionary(uniqueKeysWithValues: data.map { ($0[0], $0[1]) })
        }
    }
    
    private func saveProgress() {
        let data = markedVerses.map { [$0.key, $0.value] }
        store.set(data, forKey: progressKey)
        store.synchronize()
    }
    
    @objc private func storeDidChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let keys = userInfo[NSUbiquitousKeyValueStoreChangedKeysKey] as? [String] else { return }
        
        if keys.contains(progressKey) {
            // Ensure we're on main actor since notification might come from background
            Task { @MainActor in
                self.loadProgress()
            }
        }
    }
}
