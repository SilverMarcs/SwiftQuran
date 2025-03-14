import SwiftUI
import SwiftData

struct SurahDetailView: View {
    let surah: Surah?
    
    @ObservedObject var settings = AppSettings.shared
    @Environment(\.modelContext) private var modelContext
    @Query private var readingProgress: [ReadingProgress]
    @State private var topVisibleVerseId: Int?
    @State private var lastScrollPhase: ScrollPhase = .idle
    @State private var scrollTarget: Int?
    
    var body: some View {
        if let surah = surah {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(surah.verses, id: \.id) { verse in
                        VStack(spacing: 16) {
                            Text(verse.text)
                                .kerning(3)
                                .font(.system(size: settings.arabicTextFontSize))
                                .frame(maxWidth: .infinity, alignment: .trailing)
                            
                            Text("\(verse.id) • \(verse.translation)")
                                .font(.system(size: settings.translationFontSize))
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Divider()
                        }
                        .id(verse.id)
                        .padding(4)
                        .onAppear {
                            // Update topmost visible verse
                            topVisibleVerseId = verse.id
                        }
                    }
                    .padding(.horizontal)
                }
                .scrollTargetLayout()
            }
            .background(.background)
            .scrollContentBackground(.visible)
            .scrollPosition(id: $scrollTarget)
            .onScrollPhaseChange { _, newPhase in
                if lastScrollPhase != .idle && newPhase == .idle {
                    // Only update progress when scrolling stops
                    if let verseId = topVisibleVerseId {
//                        print("Updating progress for verse: \(verseId)")
                        updateReadingProgress(verseId: verseId, surah: surah)
                    }
                }
                lastScrollPhase = newPhase
            }
            .onAppear {
                // Set initial scroll position if there's reading progress
                if let progress = getProgress(for: surah.id) {
                    Task { @MainActor in
                        scrollTarget = progress.lastReadVerseId
                    }
                }
            }
            .navigationTitle(surah.transliteration + " • " + surah.name)
            .toolbarTitleDisplayMode(.inline)
            .toolbar { SurahToolbar() }
            #if os(macOS)
            .navigationSubtitle(surah.translation)
            #endif
        } else {
            Text("Select a Surah")
                .font(.title)
                .foregroundStyle(.secondary)
        }
    }
    
    private func updateReadingProgress(verseId: Int, surah: Surah) {
        if let existingProgress = getProgress(for: surah.id) {
            existingProgress.lastReadAt = Date()
            existingProgress.lastReadVerseId = verseId
        } else {
            let progress = ReadingProgress(lastReadVerseId: verseId, surahId: surah.id)
            modelContext.insert(progress)
        }
    }
    
    private func getProgress(for surahId: Int) -> ReadingProgress? {
        readingProgress.first { $0.surahId == surahId }
    }
}

#Preview {
    SurahDetailView(surah: nil)
}
