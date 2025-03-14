import SwiftUI

class AppSettings: ObservableObject {
    static let shared = AppSettings()
    
    static let defaultArabicFontSize: Double = 18
    
    // Default font sizes per platform
    #if os(iOS)
    static let defaultTranslationFontSize: Double = 18
    #else
    static let defaultTranslationFontSize: Double = 13
    #endif
    
    static let minFontSize: Double = 10
    static let maxFontSize: Double = 50
    
    @AppStorage("arabicTextFontSize") var arabicTextFontSize: Double = defaultArabicFontSize {
        willSet {
            #if os(iOS)
            objectWillChange.send()
            #endif
        }
    }
    
    @AppStorage("translationFontSize") var translationFontSize: Double = defaultTranslationFontSize {
        willSet {
            #if os(iOS)
            objectWillChange.send()
            #endif
        }
    }
    
    func resetAllFontSizes() {
        resetArabicFontSize()
        resetTranslationFontSize()
    }
    
    // Reset functions
    func resetArabicFontSize() {
        arabicTextFontSize = Self.defaultArabicFontSize
    }
    
    func resetTranslationFontSize() {
        translationFontSize = Self.defaultTranslationFontSize
    }
    
    private init() {}
}
