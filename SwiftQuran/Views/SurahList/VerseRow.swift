import SwiftUI
import AVKit

struct VerseRow: View {
    let verse: Verse
    
    @AppStorage("arabicTextFontSize") var arabicTextFontSize: Double = 21
    @AppStorage("translationFontSize") var translationFontSize: Double = 18
    var progressManager = ReadingProgressManager.shared
    var savedVersesManager = SavedVersesManager.shared
    var audioPlayer = AudioPlayerManager.shared
    
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
                .opacity(0.8)
                #endif
                .kerning(8)
                .lineSpacing(4)
                .fontDesign(.serif)
                .font(.system(size: arabicTextFontSize))
                .frame(maxWidth: .infinity, alignment: .leading)
                .environment(\.layoutDirection, .rightToLeft)
            
            Text("\(verse.verseIndex) • \(verse.translation)")
                .textSelection(.enabled)
                .font(.system(size: translationFontSize))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                Button {
                    savedVersesManager.toggleSaved(verse: verse)
                } label: {
                    Image(systemName: savedVersesManager.isSaved(verse: verse) ? "heart.fill" : "heart")
                        .frame(width: 20, height: 20)
                }
                .buttonStyle(.glass)
                .foregroundStyle(savedVersesManager.isSaved(verse: verse) ? .red : .secondary)
                
                Spacer()
                
                Button {
                    progressManager.toggleProgress(for: verse)
                } label: {
                    Image(systemName: progressManager.isProgress(for: verse) ? "bookmark.fill" : "bookmark")
                        .frame(width: 20, height: 20)
                }
                .buttonStyle(.glass)
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
                    Image(systemName: (isCurrentVerse && audioPlayer.isPlaying) ? "pause.fill" : "play.fill")
                        .frame(width: 20, height: 20)
                }
                .buttonStyle(.glass)
                .foregroundStyle((isCurrentVerse && audioPlayer.isPlaying) ? .accent : .secondary)
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
