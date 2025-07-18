import SwiftUI

struct InlineAudioPlayer: View {
    private var audioPlayer = AudioPlayerManager.shared
    
    var body: some View {
        HStack {
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
            
            Button {
                audioPlayer.stop()
            } label: {
                Image(systemName: "stop.circle.fill")
                    .foregroundStyle(.red)
            }
            .buttonStyle(.plain)
        }
        .padding()
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
