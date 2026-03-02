import Foundation

@Observable
class QuranDataManager {
    @ObservationIgnored static let shared = QuranDataManager()
    private(set) var surahs: [Surah] = []
    private(set) var isLoaded = false

    private init() {}

    func loadQuranData() {
        guard !isLoaded else { return }
        surahs = QuranDatabase.shared.loadSurahs()
        for i in surahs.indices {
            surahs[i].verses = QuranDatabase.shared.loadVerses(for: surahs[i])
        }
        isLoaded = true
    }

    func surah(id: Int) -> Surah? {
        surahs.first { $0.id == id }
    }
}
