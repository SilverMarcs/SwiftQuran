import SwiftUI

struct SurahToolbar: ToolbarContent {
    let surah: Surah
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var showingFontSettings = false
    @AppStorage("arabicTextFontSize") var arabicTextFontSize: Double = 21
    @AppStorage("translationFontSize") var translationFontSize: Double = 18
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                showingFontSettings.toggle()
            } label: {
                Image(systemName: "textformat.size")
            }
            .popover(isPresented: $showingFontSettings) {
                VStack(alignment: .trailing, spacing: 20) {
                    FontSizeControl(
                        title: "Arabic",
                        fontSize: $arabicTextFontSize
                    )
                    
                    FontSizeControl(
                        title: "English",
                        fontSize: $translationFontSize
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
    
    private let minFontSize: Double = 10
    private let maxFontSize: Double = 60
    
    var body: some View {
        HStack(spacing: 30) {
            Text(title)
                .bold()
            
            ControlGroup {
                Button {
                    if fontSize > minFontSize {
                        fontSize -= 1
                    }
                } label: {
                    Image(systemName: "textformat.size.smaller")
                        .foregroundStyle(fontSize > minFontSize ? .primary : .secondary)
                }
                .disabled(fontSize <= minFontSize)
                
                Button {
                    if fontSize < maxFontSize {
                        fontSize += 1
                    }
                } label: {
                    Image(systemName: "textformat.size.larger")
                        .foregroundStyle(fontSize < maxFontSize ? .primary : .secondary)
                }
                .disabled(fontSize >= maxFontSize)
            }
        }
    }
}

#Preview {
    FontSizeControl(title: "English", fontSize: .constant(17))
}
