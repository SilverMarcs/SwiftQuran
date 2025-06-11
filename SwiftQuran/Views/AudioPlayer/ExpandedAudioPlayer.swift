import SwiftUI

struct ExpandedAudioPlayer: View {
    @ObservedObject private var audioPlayer = AudioPlayerManager.shared
    
    var body: some View {
        if audioPlayer.currentVerse != nil {
            HStack(spacing: 20) {
                Text(getSurahName())
                    .lineLimit(1)
                
                Spacer()
                
                ControlGroup {
                    Button {
                        audioPlayer.seek(to: max(0, audioPlayer.currentTime - 5))
                    } label: {
                        Image(systemName: "gobackward.5")
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        if audioPlayer.isPlaying {
                            audioPlayer.pause()
                        } else {
                            resumePlayback()
                        }
                    } label: {
                        Image(systemName: audioPlayer.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .contentTransition(.symbolEffect(.replace))
                            .font(.title2)
                    }
                    .buttonStyle(.plain)
                    
                    
                    Button {
                        audioPlayer.seek(to: min(audioPlayer.duration, audioPlayer.currentTime + 5))
                    } label: {
                        Image(systemName: "goforward.5")
                    }
                    .buttonStyle(.plain)
                }
                
//                Button {
//                    audioPlayer.stop()
//                } label: {
//                    Image(systemName: "stop.circle.fill")
//                        .foregroundStyle(.red)
//                }
//                .buttonStyle(.plain)
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
    VStack {
        Spacer()
        ExpandedAudioPlayer()
    }
}
