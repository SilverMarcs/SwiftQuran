import Foundation

@Observable final class ReadingProgressManager {
    static let shared = ReadingProgressManager()
    private let progressKey = "reading_progress"
    
    private(set) var markedVerses: [Int: Int] = [:] // [surahNumber: verseNumber]
    
    private init() {
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
        if let data = UserDefaults.standard.array(forKey: progressKey) as? [[Int]] {
            markedVerses = Dictionary(uniqueKeysWithValues: data.map { ($0[0], $0[1]) })
        }
    }
    
    private func saveProgress() {
        let data = markedVerses.map { [$0.key, $0.value] }
        UserDefaults.standard.set(data, forKey: progressKey)
    }
}
