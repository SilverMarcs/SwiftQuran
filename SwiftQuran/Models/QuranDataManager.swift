import Foundation

// Helper structs for JSON decoding
private struct RawSurah: Codable {
    let id: Int
    let name: String
    let transliteration: String
    let translation: String
    let type: String
    let totalVerses: Int
    let verses: [RawVerse]
}

private struct RawVerse: Codable {
    let id: Int
    let text: String
    let translation: String
}

@Observable
class QuranDataManager {
    @ObservationIgnored static let shared = QuranDataManager()
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
            // First decode the raw JSON structure
            let rawSurahs = try JSONDecoder().decode([RawSurah].self, from: data)
            
            // Transform to populate surah number and verse index
            surahs = rawSurahs.map { rawSurah in
                let transformedVerses = rawSurah.verses.enumerated().map { (index, rawVerse) in
                    Verse(
                        id: rawVerse.id,
                        text: rawVerse.text,
                        translation: rawVerse.translation,
                        surahNumber: rawSurah.id,
                        verseIndex: index + 1
                    )
                }
                
                return Surah(
                    id: rawSurah.id,
                    name: rawSurah.name,
                    transliteration: rawSurah.transliteration,
                    translation: rawSurah.translation,
                    type: rawSurah.type,
                    totalVerses: rawSurah.totalVerses,
                    verses: transformedVerses
                )
            }
            
            isLoaded = true
        } catch {
            print("Error loading Quran data: \(error)")
        }
    }
    
    func surah(id: Int) -> Surah? {
        surahs.first { surah in surah.id == id }
    }
}
