//
//  SurahJSON.swift
//  SwiftQuran
//
//  Created by Zabir Raihan on 14/03/2025.
//

import Foundation
import SwiftData

// MARK: - JSON Decodable Models
struct SurahJSON: Codable {
    let id: Int
    let name: String
    let transliteration: String
    let translation: String
    let type: String
    let total_verses: Int
    let verses: [VerseJSON]
}

struct VerseJSON: Codable {
    let id: Int
    let text: String
    let translation: String
}

actor BackgroundImporter {
    var modelContainer: ModelContainer
    
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }
    
    func fetchAndImportQuran() async throws {
        let modelContext = ModelContext(modelContainer)
        
        // Check if data is already loaded
        let descriptor = FetchDescriptor<Surah>(sortBy: [SortDescriptor(\.id)])
        let existingSurahs = try modelContext.fetch(descriptor)
        
        if !existingSurahs.isEmpty {
            print("Quran data already loaded")
            return
        }
        
        // Fetch JSON data
        guard let url = URL(string: "https://cdn.jsdelivr.net/npm/quran-json@3.1.2/dist/quran_en.json") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let surahs = try JSONDecoder().decode([SurahJSON].self, from: data)
        
        // Import in batches
        let batchSize = 10
        for i in 0..<(surahs.count / batchSize + 1) {
            let start = i * batchSize
            let end = min(start + batchSize, surahs.count)
            let batch = surahs[start..<end]
            
            for surahJSON in batch {
                let verses = surahJSON.verses.map { verseJSON in
                    Verse(id: verseJSON.id, text: verseJSON.text, translation: verseJSON.translation)
                }
                
                let surah = Surah(
                    id: surahJSON.id,
                    name: surahJSON.name,
                    transliteration: surahJSON.transliteration,
                    translation: surahJSON.translation,
                    type: surahJSON.type,
                    totalVerses: surahJSON.total_verses,
                    verses: verses
                )
                
                modelContext.insert(surah)
            }
            
            try modelContext.save()
        }
    }
}
