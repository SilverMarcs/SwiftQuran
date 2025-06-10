import SwiftUI
import AVKit

struct VerseRow: View {
    let verse: Verse
    let surahNumber: Int
    let verseNumber: Int
    
    @ObservedObject var settings = AppSettings.shared
    @ObservedObject var progressManager = ReadingProgressManager.shared
    @ObservedObject private var audioPlayer = AudioPlayerManager.shared
    
    private var verseId: String {
        "verse_\(surahNumber)_\(verseNumber)"
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
                .opacity(0.7)
                #endif
                .kerning(8)
                .lineSpacing(4)
                .font(.system(size: settings.arabicTextFontSize))
                .frame(maxWidth: .infinity, alignment: .leading)
                .environment(\.layoutDirection, .rightToLeft)
            
            HStack(alignment: .bottom) {
                Text("\(verseNumber) • \(verse.translation)")
                    .textSelection(.enabled)
                    .font(.system(size: settings.translationFontSize))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(alignment: .center) {
                    Button {
                        progressManager.toggleProgress(for: surahNumber, verseNumber: verseNumber)
                    } label: {
                        Image(systemName: progressManager.getProgress(for: surahNumber) == verseNumber ? "bookmark.fill" : "bookmark")
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(progressManager.getProgress(for: surahNumber) == verseNumber ? .accent : .secondary)
                    
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
        let urlString = "https://the-quran-project.github.io/Quran-Audio/Data/1/\(surahNumber)_\(verseNumber).mp3"
        guard let url = URL(string: urlString) else { return }
        audioPlayer.play(url: url, verseId: verseId)
    }
}

#Preview {
    VerseRow(verse: Mock.verse, surahNumber: 1, verseNumber: 1)
        .padding()
}
