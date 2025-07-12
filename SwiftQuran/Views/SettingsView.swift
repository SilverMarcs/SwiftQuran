import SwiftUI

struct SettingsView: View {
    // Default font sizes per platform
    #if os(iOS)
    private let defaultTranslationFontSize: Double = 18
    #else
    private let defaultTranslationFontSize: Double = 13
    #endif
    
    private let defaultArabicFontSize: Double = 21
    private let minFontSize: Double = 10
    private let maxFontSize: Double = 60
    
    @AppStorage("arabicTextFontSize") var arabicTextFontSize: Double = 21
    @AppStorage("translationFontSize") var translationFontSize: Double = 18
    @Environment(\.dismiss) private var dismiss
    
    // Sample texts for preview
    private let sampleArabicText = "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ"
    private let sampleEnglishText = "In the name of Allah, the Entirely Merciful, the Especially Merciful."
    
    var body: some View {
        NavigationStack {
            Form {
                // Arabic Font Settings
                fontSettingsSection(
                    title: "Arabic Text",
                    fontSize: $arabicTextFontSize,
                    sampleText: sampleArabicText,
                    isArabic: true
                )
                
                // English Font Settings
                fontSettingsSection(
                    title: "English Translation",
                    fontSize: $translationFontSize,
                    sampleText: sampleEnglishText,
                    isArabic: false
                )
            }
            .formStyle(.grouped)
            .navigationTitle("Settings")
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .destructiveAction) {
                    Button("Reset", role: .destructive) {
                        resetAllFontSizes()
                    }
                    .foregroundStyle(.red)
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button(role:. close) {
                        dismiss()
                    }
                }
            }
        }
    }
    
    func resetAllFontSizes() {
        arabicTextFontSize = defaultArabicFontSize
        #if os(iOS)
        translationFontSize = 18
        #else
        translationFontSize = 13
        #endif
    }
    
    @ViewBuilder
    private func fontSettingsSection(
        title: String,
        fontSize: Binding<Double>,
        sampleText: String,
        isArabic: Bool
    ) -> some View {
        Section(title) {
            Text(sampleText)
                .font(.system(size: fontSize.wrappedValue))
                .fontDesign(isArabic ? .serif : .default)
            
            Slider(
                value: fontSize,
                in: minFontSize...maxFontSize,
                step: 1
            )
        }
    }
}

#Preview {
    SettingsView()
}
