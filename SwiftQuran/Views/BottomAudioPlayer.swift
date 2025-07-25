import SwiftUI

struct BottomAudioPlayer: View {
    private var audioPlayer = AudioPlayerManager.shared
    @State private var isDragging = false
    
    var body: some View {
        if audioPlayer.currentVerse != nil && audioPlayer.duration > 0 {
            VStack(spacing: 0) {
                VStack(spacing: 12) {
                    // Progress bar
                    HStack(spacing: 8) {
                        Text(formatTime(audioPlayer.currentTime))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                        
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
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                    
                    // Control buttons
                    HStack(spacing: 28) {
                        Text("\(getVerseDisplayText())")
                            .font(.caption.bold())
                        
                        Spacer()
                        
                        Button {
                            audioPlayer.seek(to: max(0, audioPlayer.currentTime - 5))
                        } label: {
                            Image(systemName: "gobackward.5")
                                .font(.title3)
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
                                .font(.title)
                        }
                        .buttonStyle(.plain)
                        
                        Button {
                            audioPlayer.seek(to: min(audioPlayer.duration, audioPlayer.currentTime + 5))
                        } label: {
                            Image(systemName: "goforward.5")
                                .font(.title3)
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                        
                        Button {
                            audioPlayer.stop()
                        } label: {
                            Image(systemName: "stop.circle.fill")
                                .foregroundStyle(.red)
                        }
                        .buttonStyle(.plain)
                    }
                    .foregroundStyle(.primary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .glassEffect(in: RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal)
                .padding(.vertical, 13)
            }
        }
    }
    
    private func getVerseDisplayText() -> String {
        if let surahNumber = audioPlayer.currentSurahNumber,
           let verseNumber = audioPlayer.currentVerseNumber {
            return "\(surahNumber):\(verseNumber)"
        }
        return ""
    }
    
    private func resumePlayback() {
        // Resume playing current verse
        if let currentVerse = audioPlayer.currentVerse {
            audioPlayer.play(verse: currentVerse)
        }
    }
    
    private func formatTime(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let seconds = Int(seconds) % 60
        return unsafe String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    VStack {
        Spacer()
        BottomAudioPlayer()
    }
}
