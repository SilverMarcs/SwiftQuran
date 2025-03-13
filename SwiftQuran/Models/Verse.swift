//
//  Verse.swift
//  SwiftQuran
//
//  Created by Zabir Raihan on 14/03/2025.
//

import Foundation
import SwiftData

@Model
final class Verse {
    var id: Int
    var text: String
    var translation: String
    var surah: Surah?
    
    init(id: Int, text: String, translation: String) {
        self.id = id
        self.text = text
        self.translation = translation
    }
}
