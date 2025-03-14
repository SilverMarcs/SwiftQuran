import Foundation

@Observable
class QuranDataManager {
    static let shared = QuranDataManager()
    private(set) var surahs: [Surah] = []
    private(set) var isLoaded = false
    
    private init() {}
    
    func loadQuranData() {
        guard !isLoaded,
              let url = Bundle.main.url(forResource: "quran_en", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return
        }
        
        do {
            surahs = try JSONDecoder().decode([Surah].self, from: data)
            isLoaded = true
        } catch {
            print("Error loading Quran data: \(error)")
        }
    }
    
    func surah(id: Int) -> Surah? {
        surahs.first { surah in surah.id == id }
    }
}
