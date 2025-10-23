import Foundation

@Observable class SavedVersesManager {
    static let shared = SavedVersesManager()
    private let savedVersesKey = "saved_verses"
    private let cloudStore = NSUbiquitousKeyValueStore.default
    
    private(set) var savedVerses: Set<String> = [] // Set of "surahNumber_verseNumber"
    
    private init() {
        loadSavedVerses()
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
        // Reload saved verses when iCloud data changes
        loadSavedVerses()
    }
    
    // Convenience methods that work directly with Verse objects
    func toggleSaved(verse: Verse) {
        if savedVerses.contains(verse.verseKey) {
            savedVerses.remove(verse.verseKey)
        } else {
            savedVerses.insert(verse.verseKey)
        }
        saveSavedVerses()
    }
    
    func isSaved(verse: Verse) -> Bool {
        return savedVerses.contains(verse.verseKey)
    }
    
    // Legacy methods for backward compatibility
    func toggleSaved(surahNumber: Int, verseNumber: Int) {
        let verseKey = "\(surahNumber)_\(verseNumber)"
        if savedVerses.contains(verseKey) {
            savedVerses.remove(verseKey)
        } else {
            savedVerses.insert(verseKey)
        }
        saveSavedVerses()
    }
    
    func isSaved(surahNumber: Int, verseNumber: Int) -> Bool {
        let verseKey = "\(surahNumber)_\(verseNumber)"
        return savedVerses.contains(verseKey)
    }
    
    // New method that returns actual Verse objects instead of tuples
    func getSavedVersesData() -> [Verse] {
        let quranData = QuranDataManager.shared
        return savedVerses.compactMap { verseKey in
            let components = verseKey.split(separator: "_")
            guard components.count == 2,
                  let surahNumber = Int(components[0]),
                  let verseNumber = Int(components[1]) else {
                return nil
            }
            
            guard let surah = quranData.surahs.first(where: { $0.id == surahNumber }),
                  verseNumber > 0 && verseNumber <= surah.verses.count else {
                return nil
            }
            
            return surah.verses[verseNumber - 1]
        }.sorted { lhs, rhs in
            if lhs.surahNumber == rhs.surahNumber {
                return lhs.verseIndex < rhs.verseIndex
            }
            return lhs.surahNumber < rhs.surahNumber
        }
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
