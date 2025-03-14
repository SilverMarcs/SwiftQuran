//
//  MenuCommands.swift
//  SwiftQuran
//
//  Created by Zabir Raihan on 14/03/2025.
//

import SwiftUI
import SwiftData

struct MenuCommands: Commands {
    @ObservedObject var settings = AppSettings.shared
    
    var body: some Commands {
        CommandGroup(before: .toolbar) {
            Button("Increase Font Size") {
                if settings.arabicTextFontSize < AppSettings.maxFontSize {
                    settings.arabicTextFontSize += 1
                }
            }
            .keyboardShortcut("+")
            
            Button("Decrease Font Size") {
                if settings.arabicTextFontSize > AppSettings.minFontSize {
                    settings.arabicTextFontSize -= 1
                }
            }
            .keyboardShortcut("-")
            
            Button("Reset Font Size") {
                settings.resetAllFontSizes()
            }
            .keyboardShortcut("o")
        }
    }
}
