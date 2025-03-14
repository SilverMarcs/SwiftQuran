import SwiftUI
import SwiftData

struct SurahToolbar: ToolbarContent {
    let surah: Surah
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.modelContext) private var modelContext
    @Query private var readingProgress: [ReadingProgress]
    @Binding var scrollTarget: Int?
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
                                    withAnimation {
                                        scrollTarget = verse.id
                                    }
                                }) {
                                    Text("Verse \(verse.id)")
                                    
                                }
                            }
                        } label: {
                            Label("Verse List", systemImage: "list.bullet")
                        }
                    }
                    
                    LabeledContent {
                        Button(role: .destructive, action: resetProgress) {
                            Text("Reset")
                        }
                    } label: {
                        Text("Reading Progress")
                    }
                }
                .presentationDetents(horizontalSizeClass == .compact ? [.medium, .large] : [.large])
                .presentationDragIndicator(.hidden)
                .formStyle(.grouped)
                #if os(macOS)
                .frame(width: 300)
                #endif
            }
        }
    }
    
    private func resetProgress() {
        if let progress = readingProgress.first(where: { $0.surahId == surah.id }) {
            modelContext.delete(progress)
            scrollTarget = nil
        }
    }
}
