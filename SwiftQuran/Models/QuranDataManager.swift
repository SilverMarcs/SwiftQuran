import Foundation

@Observable
class QuranDataManager {
    private(set) var surahs: [Surah] = []
    private(set) var isLoaded = false

    func loadQuranData() {
        guard !isLoaded else { return }
        surahs = QuranDatabase.shared.loadSurahs()
        isLoaded = true
    }

    func surah(id: Int) -> Surah? {
        surahs.first { $0.id == id }
    }
}
