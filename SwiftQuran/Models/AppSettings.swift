import SwiftUI

class AppSettings: ObservableObject {
    static let shared = AppSettings()
    
    // Default font sizes per platform
    #if os(iOS)
    static let defaultTranslationFontSize: Double = 18
    #else
    static let defaultTranslationFontSize: Double = 13
    #endif
    
    static let defaultArabicFontSize: Double = 21
    static let minFontSize: Double = 10
    static let maxFontSize: Double = 50
    
    @AppStorage("arabicTextFontSize") var arabicTextFontSize: Double = defaultArabicFontSize
    @AppStorage("translationFontSize") var translationFontSize: Double = defaultTranslationFontSize
    
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
