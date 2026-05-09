//
//  MenuCommands.swift
//  SwiftQuran
//
//  Created by Zabir Raihan on 14/03/2025.
//

import SwiftUI
import SwiftData

struct MenuCommands: Commands {
    @AppStorage("arabicTextFontSize") var arabicTextFontSize: Double = 26
    @AppStorage("translationFontSize") var translationFontSize: Double = 18
    
    private let minFontSize: Double = 10
    private let maxFontSize: Double = 60
    
    var body: some Commands {
        // CommandGroup(replacing: .newItem) {}
        
        CommandGroup(before: .toolbar) {
            Button {
                if arabicTextFontSize < maxFontSize {
                    arabicTextFontSize += 1
                }
            } label: {
                Label("Increase Font Size", systemImage: "plus.magnifyingglass")
            }
            .keyboardShortcut("+")
            
            Button {
                if arabicTextFontSize > minFontSize {
                    arabicTextFontSize -= 1
                }
            } label: {
                Label("Decrease Font Size", systemImage: "minus.magnifyingglass")
            }
            .keyboardShortcut("-")
            
            Button {
                arabicTextFontSize = 21
                #if os(iOS)
                translationFontSize = 18
                #else
                translationFontSize = 13
                #endif
            } label: {
                Label("Reset Font Size", systemImage: "arrow.counterclockwise")
            }
            .keyboardShortcut("o")
        }
    }
}
