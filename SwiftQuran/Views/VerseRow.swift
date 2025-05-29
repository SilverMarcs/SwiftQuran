import SwiftUI
import AVKit

struct VerseRow: View {
    let verse: Verse
    let surahNumber: Int
    let verseNumber: Int
    @ObservedObject var settings = AppSettings.shared
    @ObservedObject var progressManager = ReadingProgressManager.shared
    @ObservedObject private var audioPlayer = AudioPlayerManager.shared
    @State private var isDragging = false
    
    private var verseId: String {
        "verse_\(surahNumber)_\(verseNumber)"
    }
    
    private var isCurrentVerse: Bool {
        audioPlayer.currentVerseId == verseId
    }
    
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
            
            // Audio player controls - only show if this verse is playing
            if isCurrentVerse && audioPlayer.duration > 0 {
                VStack(spacing: 8) {
                    HStack {
                        Text(formatTime(audioPlayer.currentTime))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Slider(
                            value: Binding(
                                get: { isDragging ? audioPlayer.currentTime : audioPlayer.currentTime },
                                set: { newValue in
                                    if isDragging {
                                        audioPlayer.seek(to: newValue)
                                    }
                                }
                            ),
                            in: 0...audioPlayer.duration,
                            onEditingChanged: { editing in
                                isDragging = editing
                            }
                        )
                        .accentColor(.accent)
                        
                        Text(formatTime(audioPlayer.duration))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Button {
                            audioPlayer.seek(to: max(0, audioPlayer.currentTime - 15))
                        } label: {
                            Image(systemName: "gobackward.15")
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                        
                        Button {
                            audioPlayer.stop()
                        } label: {
                            Image(systemName: "stop.fill")
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                        
                        Button {
                            audioPlayer.seek(to: min(audioPlayer.duration, audioPlayer.currentTime + 15))
                        } label: {
                            Image(systemName: "goforward.15")
                        }
                        .buttonStyle(.plain)
                    }
                    .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
            }
        }
        .id("verse\(verse.id)")
//        .onDisappear {
//            cleanup()
//        }
    }
    
    private func playVerse() {
        let urlString = "https://the-quran-project.github.io/Quran-Audio/Data/1/\(surahNumber)_\(verseNumber).mp3"
        guard let url = URL(string: urlString) else { return }
        audioPlayer.play(url: url, verseId: verseId)
    }
    
    private func formatTime(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let seconds = Int(seconds) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    VerseRow(verse: Mock.verse, surahNumber: 1, verseNumber: 1)
        .padding()
}
