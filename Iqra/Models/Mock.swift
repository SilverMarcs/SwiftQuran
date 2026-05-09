//
//  Mock.swift
//  SwiftQuran
//
//  Created by Zabir Raihan on 14/03/2025.
//

import SwiftUI

enum Mock {
    static let surah = Surah(
        id: 1,
        name: "الفاتحة",
        transliteration: "Al-Fatiha",
        translation: "The Opener",
        type: "meccan",
        ayatFrom: 1,
        ayatTo: 7
    )

    static let verse = Verse(
        id: 1,
        text: "بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ",
        translation: "In the name of Allah, the Entirely Merciful, the Especially Merciful",
        surahNumber: 1,
        verseIndex: 1
    )
}
