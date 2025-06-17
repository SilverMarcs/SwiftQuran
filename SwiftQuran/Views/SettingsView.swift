import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings = AppSettings.shared
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
                    fontSize: $settings.arabicTextFontSize,
                    sampleText: sampleArabicText,
                    isArabic: true
                )
                
                // English Font Settings
                fontSettingsSection(
                    title: "English Translation",
                    fontSize: $settings.translationFontSize,
                    sampleText: sampleEnglishText,
                    isArabic: false
                )
            }
            .formStyle(.grouped)
            .navigationTitle("Settings")
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Reset") {
                        settings.resetAllFontSizes()
                    }
                    .foregroundStyle(.red)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
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
                in: AppSettings.minFontSize...AppSettings.maxFontSize,
                step: 1
            )
        }
    }
}

#Preview {
    SettingsView()
}
