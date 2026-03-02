import Foundation

@Observable class SavedVersesManager {
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

    func getSavedVersesData(surahs: [Surah]) -> [Verse] {
        // Group saved verse keys by surah
        var surahVerses: [Int: [Int]] = [:]
        for verseKey in savedVerses {
            let components = verseKey.split(separator: "_")
            guard components.count == 2,
                  let surahNumber = Int(components[0]),
                  let verseNumber = Int(components[1]) else {
                continue
            }
            surahVerses[surahNumber, default: []].append(verseNumber)
        }

        // Load verses from DB for each surah that has saved verses
        var result: [Verse] = []
        for (surahID, verseNumbers) in surahVerses {
            guard let surah = surahs.first(where: { $0.id == surahID }) else { continue }
            let allVerses = QuranDatabase.shared.loadVerses(for: surah)
            let saved = allVerses.filter { verseNumbers.contains($0.verseIndex) }
            result.append(contentsOf: saved)
        }

        return result.sorted { lhs, rhs in
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
