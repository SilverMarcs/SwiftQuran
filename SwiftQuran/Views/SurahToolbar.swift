import SwiftUI

struct SurahToolbar: ToolbarContent {
    @State private var showingFontSettings = false
    @ObservedObject var settings = AppSettings.shared
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                showingFontSettings.toggle()
            } label: {
                Image(systemName: "textformat.size")
            }
            .popover(isPresented: $showingFontSettings) {
                Form {
                    Section() {
                        Stepper(value: $settings.arabicTextFontSize, in: AppSettings.minFontSize...AppSettings.maxFontSize) {
                            Text("Arabic Text Size")
                            Text("\(Int(settings.arabicTextFontSize))")
                        }
               
                    
                        Stepper(value: $settings.translationFontSize, in: AppSettings.minFontSize...AppSettings.maxFontSize) {
                            Text("Translation Text Size")
                            Text("\(Int(settings.translationFontSize))")
                        }
                    } header: {
                        HStack {
                            Text("Font Settings")
                            
                            Spacer()
                            
                            Button(action: settings.resetAllFontSizes) {
                                Text("Reset")
                            }
                        }
                    }
                }
                .formStyle(.grouped)
                #if os(macOS)
                .frame(width: 300)
                #endif
            }
        }
    }
}
