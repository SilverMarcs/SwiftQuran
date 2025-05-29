import SwiftUI

struct SurahToolbar: ToolbarContent {
    let surah: Surah
    var proxy: ScrollViewProxy? = nil
    
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
                    
                    Section {
                        Menu {
                            ForEach(surah.verses) { verse in
                                Button(action: {
                                    proxy?.scrollTo("verse\(verse.id)", anchor: .top)
                                }) {
                                    Text("Verse \(verse.id)")
                                }
                            }
                        } label: {
                            Label("Verse List", systemImage: "list.bullet")
                        }
                    }
                }
                .presentationDetents(horizontalSizeClass == .compact ? [.medium] : [.large])
                .presentationDragIndicator(.hidden)
                .formStyle(.grouped)
                #if os(macOS)
                .frame(width: 300)
                #endif
            }
        }
    }
}

#Preview {
   VStack {
       Text("whatever")
   }
   .frame(width: 300, height: 300)
   .toolbar {
       SurahToolbar(surah: Mock.surah)
   }
}
