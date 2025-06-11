import SwiftUI
import AVKit

struct VerseRow: View {
    let verse: Verse
    
    @ObservedObject var settings = AppSettings.shared
    @ObservedObject var progressManager = ReadingProgressManager.shared
    @ObservedObject var savedVersesManager = SavedVersesManager.shared
    @ObservedObject private var audioPlayer = AudioPlayerManager.shared
    
    private var verseId: String {
        "verse_\(verse.verseKey)"
    }
    
    private var isCurrentVerse: Bool {
        audioPlayer.currentVerseId == verseId
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text(verse.text)
                #if os(macOS)
                .opacity(0.9)
                #else
                .opacity(0.75)
                #endif
                .kerning(8)
                .lineSpacing(4)
                .font(.system(size: settings.arabicTextFontSize))
                .frame(maxWidth: .infinity, alignment: .leading)
                .environment(\.layoutDirection, .rightToLeft)
            
            HStack(alignment: .bottom) {
                Text("\(verse.verseIndex) • \(verse.translation)")
                    .textSelection(.enabled)
                    .font(.system(size: settings.translationFontSize))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(alignment: .center) {
                    Button {
                        savedVersesManager.toggleSaved(verse: verse)
                    } label: {
                        Image(systemName: savedVersesManager.isSaved(verse: verse) ? "heart.fill" : "heart")
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(savedVersesManager.isSaved(verse: verse) ? .red : .secondary)
                    
                    Button {
                        progressManager.toggleProgress(for: verse)
                    } label: {
                        Image(systemName: progressManager.isProgress(for: verse) ? "bookmark.fill" : "bookmark")
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(progressManager.isProgress(for: verse) ? .accent : .secondary)
                    
                    Button {
                        if isCurrentVerse && audioPlayer.isPlaying {
                            audioPlayer.pause()
                        } else if isCurrentVerse {
                            playVerse()
                        } else {
                            playVerse()
                        }
                    } label: {
                        Image(systemName: (isCurrentVerse && audioPlayer.isPlaying) ? "pause.circle.fill" : "play.circle.fill")
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle((isCurrentVerse && audioPlayer.isPlaying) ? .accent : .secondary)
                }
            }
        }
        .id("verse\(verse.id)")
    }
    
    private func playVerse() {
        audioPlayer.play(verse: verse)
    }
}

#Preview {
    VerseRow(verse: Mock.verse)
        .padding()
}
