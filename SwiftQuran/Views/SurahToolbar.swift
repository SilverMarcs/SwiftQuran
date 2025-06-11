import SwiftUI

struct SurahToolbar: ToolbarContent {
    let surah: Surah
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
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
                VStack(spacing: 20) {
                    FontSizeControl(
                        title: "Arabic",
                        fontSize: $settings.arabicTextFontSize
                    )
                    
                    FontSizeControl(
                        title: "English",
                        fontSize: $settings.translationFontSize
                    )
                }
                .padding()
                .presentationCompactAdaptation(.popover)
            }
        }
    }
}

struct FontSizeControl: View {
    let title: String
    @Binding var fontSize: Double
    
    var body: some View {
        HStack(spacing: 30) {
            Text(title)
                .bold()
            
            ControlGroup {
                Button {
                    if fontSize > AppSettings.minFontSize {
                        fontSize -= 1
                    }
                } label: {
                    Image(systemName: "textformat.size.smaller")
                        .foregroundStyle(fontSize > AppSettings.minFontSize ? .primary : .secondary)
                }
                .disabled(fontSize <= AppSettings.minFontSize)
                
                Button {
                    if fontSize < AppSettings.maxFontSize {
                        fontSize += 1
                    }
                } label: {
                    Image(systemName: "textformat.size.larger")
                        .foregroundStyle(fontSize < AppSettings.maxFontSize ? .primary : .secondary)
                }
                .disabled(fontSize >= AppSettings.maxFontSize)
            }
        }
    }
}

#Preview {
    FontSizeControl(title: "English", fontSize: .constant(17))
}
