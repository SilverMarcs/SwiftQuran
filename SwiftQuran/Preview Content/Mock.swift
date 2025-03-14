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
        transliteration: "Al-Fatihah",
        translation: "The Opener",
        type: "meccan",
        totalVerses: 7,
        verses: [
            Verse(id: 1, text: "بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ", translation: "In the name of Allah, the Entirely Merciful, the Especially Merciful"),
            Verse(id: 2, text: "ٱلۡحَمۡدُ لِلَّهِ رَبِّ ٱلۡعَٰلَمِينَ", translation: "[All] praise is [due] to Allah, Lord of the worlds"),
            Verse(id: 3, text: "ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ", translation: "The Entirely Merciful, the Especially Merciful"),
            Verse(id: 4, text: "مَٰلِكِ يَوۡمِ ٱلدِّينِ", translation: "Sovereign of the Day of Recompense"),
            Verse(id: 5, text: "إِيَّاكَ نَعۡبُدُ وَإِيَّاكَ نَسۡتَعِينُ", translation: "It is You we worship and You we ask for help"),
            Verse(id: 6, text: "ٱهۡدِنَا ٱلصِّرَٰطَ ٱلۡمُسۡتَقِيمَ", translation: "Guide us to the straight path"),
            Verse(id: 7, text: "صِرَٰطَ ٱلَّذِينَ أَنۡعَمۡتَ عَلَيۡهِمۡ غَيۡرِ ٱلۡمَغۡضُوبِ عَلَيۡهِمۡ وَلَا ٱلضَّآلِّينَ", translation: "The path of those upon whom You have bestowed favor, not of those who have evoked [Your] anger or of those who are astray")
        ]
    )
    
    static let verse = Verse(id: 1, text: "بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ", translation: "In the name of Allah, the Entirely Merciful, the Especially Merciful")
}
