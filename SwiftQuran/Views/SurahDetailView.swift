import SwiftUI
import SwiftData

struct SurahDetailView: View {
    let surah: Surah?
    @Environment(\.modelContext) private var modelContext
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
                                .font(.title)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                            
                            Text("\(verse.id) • \(verse.translation)")
//                                .font(.body)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Divider()
                        }
                        .id(verse.id)
                        .padding(4)
                        .onAppear {
                            // Update topmost visible verse
                            topVisibleVerseId = verse.id
                            // print("Verse \(verse.id) became visible")
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
                if let progress = surah.readingProgress {
                    Task { @MainActor in
                        // Small delay to ensure view is ready
//                        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
                        scrollTarget = progress.lastReadVerseId
                    }
                }
            }
            .navigationTitle(surah.transliteration + " • " + surah.name)
            .toolbarTitleDisplayMode(.inline)
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
        if let existingProgress = surah.readingProgress {
            existingProgress.lastReadAt = Date()
            existingProgress.lastReadVerseId = verseId
        } else {
            let progress = ReadingProgress(lastReadVerseId: verseId, surah: surah)
            surah.readingProgress = progress
            modelContext.insert(progress)
        }
        
//        try? modelContext.save()
    }
}

#Preview {
    SurahDetailView(surah: nil)
}
