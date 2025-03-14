//
//  Surah.swift
//  SwiftQuran
//
//  Created by Zabir Raihan on 14/03/2025.
//

import Foundation

struct Surah: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let transliteration: String
    let translation: String
    let type: String
    let totalVerses: Int
    let verses: [Verse]
    
    static func == (lhs: Surah, rhs: Surah) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, transliteration, translation, type
        case totalVerses = "total_verses"
        case verses
    }
}

struct Verse: Codable, Identifiable {
    let id: Int
    let text: String
    let translation: String
}
