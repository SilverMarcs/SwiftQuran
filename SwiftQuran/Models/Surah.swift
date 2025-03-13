//
//  Surah.swift
//  SwiftQuran
//
//  Created by Zabir Raihan on 14/03/2025.
//

import Foundation
import SwiftData

@Model
final class Surah {
    var id: Int
    var name: String
    var transliteration: String
    var translation: String
    var type: String
    var totalVerses: Int
    
    @Relationship(deleteRule: .cascade) var unorderedVerses: [Verse]
    @Relationship(deleteRule: .cascade) var readingProgress: ReadingProgress?
    var verses: [Verse] {
        unorderedVerses.sorted { $0.id < $1.id }
    }
    
    init(id: Int, name: String, transliteration: String, translation: String, type: String, totalVerses: Int, verses: [Verse]) {
        self.id = id
        self.name = name
        self.transliteration = transliteration
        self.translation = translation
        self.type = type
        self.totalVerses = totalVerses
        self.unorderedVerses = verses
    }
}
