//
//  Surah.swift
//  SwiftQuran
//
//  Created by Zabir Raihan on 14/03/2025.
//

import Foundation

struct Surah: Identifiable, Hashable {
    let id: Int
    let name: String
    let transliteration: String
    let translation: String
    let type: String
    let ayatFrom: Int
    let ayatTo: Int

    var totalVerses: Int { ayatTo - ayatFrom + 1 }
    var verses: [Verse]

    static func == (lhs: Surah, rhs: Surah) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct Verse: Identifiable {
    let id: Int
    let text: String
    let translation: String
    let surahNumber: Int
    let verseIndex: Int

    var surah: Surah? {
        QuranDataManager.shared.surah(id: surahNumber)
    }

    var verseKey: String {
        "\(surahNumber)_\(verseIndex)"
    }
}
