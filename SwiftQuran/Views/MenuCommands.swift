//
//  MenuCommands.swift
//  SwiftQuran
//
//  Created by Zabir Raihan on 14/03/2025.
//

import SwiftUI
import SwiftData

struct MenuCommands: Commands {
    @AppStorage("arabicTextFontSize") var arabicTextFontSize: Double = 21
    @AppStorage("translationFontSize") var translationFontSize: Double = 18
    
    private let minFontSize: Double = 10
    private let maxFontSize: Double = 60
    
    var body: some Commands {
        CommandGroup(before: .toolbar) {
            Button("Increase Font Size") {
                if arabicTextFontSize < maxFontSize {
                    arabicTextFontSize += 1
                }
            }
            .keyboardShortcut("+")
            
            Button("Decrease Font Size") {
                if arabicTextFontSize > minFontSize {
                    arabicTextFontSize -= 1
                }
            }
            .keyboardShortcut("-")
            
            Button("Reset Font Size") {
                arabicTextFontSize = 21
                #if os(iOS)
                translationFontSize = 18
                #else
                translationFontSize = 13
                #endif
            }
            .keyboardShortcut("o")
        }
    }
}
