import SwiftUI
import AVKit

struct VerseRow: View {
    let verse: Verse
    @State private var audioPlayer: AVPlayer?
    @State private var isPlaying = false
    let surahNumber: Int
    let verseNumber: Int
    @ObservedObject var settings = AppSettings.shared
    @ObservedObject var progressManager = ReadingProgressManager.shared
    
    var body: some View {
        VStack(spacing: 16) {
            Text(verse.text)
                .kerning(4)
                .lineSpacing(2)
                .font(.system(size: settings.arabicTextFontSize))
                .frame(maxWidth: .infinity, alignment: .leading)
                .environment(\.layoutDirection, .rightToLeft)
            
            HStack(alignment: .bottom) {
                Text("\(verseNumber) • \(verse.translation)")
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
                        if isPlaying {
                            stopVerse()
                        } else {
                            playVerse()
                        }
                    } label: {
                        Image(systemName: isPlaying ? "stop.circle.fill" : "play.circle.fill")
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(isPlaying ? .accent : .secondary)
                }
            }
        }
        .id("verse\(verse.id)")
        .onDisappear {
            cleanup()
        }
    }
    
    private func playVerse() {
        let urlString = "https://the-quran-project.github.io/Quran-Audio/Data/1/\(surahNumber)_\(verseNumber).mp3"
        guard let url = URL(string: urlString) else { return }
        
        stopVerse() // Stop any existing playback
        
        let playerItem = AVPlayerItem(url: url)
        audioPlayer = AVPlayer(playerItem: playerItem)
        
        // Add observer for when playback ends
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: playerItem, queue: .main) { _ in
            isPlaying = false
            audioPlayer = nil
        }
        
        // Add observer for playback errors
        NotificationCenter.default.addObserver(forName: .AVPlayerItemFailedToPlayToEndTime, object: playerItem, queue: .main) { _ in
            isPlaying = false
            audioPlayer = nil
        }
        
        audioPlayer?.play()
        isPlaying = true
    }
    
    private func stopVerse() {
        audioPlayer?.pause()
        audioPlayer = nil
        isPlaying = false
    }
    
    private func cleanup() {
        stopVerse()
        NotificationCenter.default.removeObserver(self)
    }
}

#Preview {
    VerseRow(verse: Mock.verse, surahNumber: 1, verseNumber: 1)
        .padding()
}
