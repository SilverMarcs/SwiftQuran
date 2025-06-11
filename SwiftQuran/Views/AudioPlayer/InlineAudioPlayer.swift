import SwiftUI

struct InlineAudioPlayer: View {
    @ObservedObject private var audioPlayer = AudioPlayerManager.shared
    
    var body: some View {
        if audioPlayer.currentVerse != nil {
            HStack(spacing: 16) {
                Text(getSurahName())
                    .font(.caption.bold())
                    .lineLimit(1)
                
                Spacer()
                
                Button {
                    if audioPlayer.isPlaying {
                        audioPlayer.pause()
                    } else {
                        resumePlayback()
                    }
                } label: {
                    Image(systemName: audioPlayer.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .contentTransition(.symbolEffect(.replace))
                }
                .buttonStyle(.plain)
            }
            .padding()
        } else {
            Text("Not Playing")
        }
    }
    
    private func getSurahName() -> String {
        return audioPlayer.currentVerse?.surah?.translation ?? ""
    }
    
    private func resumePlayback() {
        if let currentVerse = audioPlayer.currentVerse {
            audioPlayer.play(verse: currentVerse)
        }
    }
}

#Preview {
    InlineAudioPlayer()
}
