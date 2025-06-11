import Foundation

@MainActor
final class SavedVersesManager: ObservableObject {
    static let shared = SavedVersesManager()
    private let store = NSUbiquitousKeyValueStore.default
    private let savedVersesKey = "saved_verses"
    
    @Published private(set) var savedVerses: Set<String> = [] // Set of "surahNumber_verseNumber"
    
    private init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(storeDidChange),
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: NSUbiquitousKeyValueStore.default
        )
        
        loadSavedVerses()
        store.synchronize()
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
        if let data = store.array(forKey: savedVersesKey) as? [String] {
            savedVerses = Set(data)
        }
    }
    
    private func saveSavedVerses() {
        let data = Array(savedVerses)
        store.set(data, forKey: savedVersesKey)
        store.synchronize()
    }
    
    @objc private func storeDidChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let keys = userInfo[NSUbiquitousKeyValueStoreChangedKeysKey] as? [String] else { return }
        
        if keys.contains(savedVersesKey) {
            // Ensure we're on main actor since notification might come from background
            Task { @MainActor in
                self.loadSavedVerses()
            }
        }
    }
}