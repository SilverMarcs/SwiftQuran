import SwiftUI

struct InlineAudioPlayer: View {
    @Environment(AudioPlayerManager.self) var manager
    
    var body: some View {
        if manager.currentVerse != nil {
            HStack {
                VStack(alignment: .leading) {
                    Text(manager.currentSurahTitle)
                        .font(.subheadline)
                        .lineLimit(1)
                    
                    Text(manager.currentAyahLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                .fontWeight(.medium)
                
                Spacer()
                
                Button {
                    if manager.isPlaying {
                        manager.pause()
                    } else {
                        resumePlayback()
                    }
                } label: {
                    Image(systemName: manager.isPlaying ? "pause" : "play.fill")
                        .fontWeight(.semibold)
                        .contentTransition(.symbolEffect(.replace))
                }
                
//                    Button {
//                        manager.stop()
//                    } label: {
//                        Image(systemName: "stop.circle")
//                            .foregroundStyle(.red)
//                    }
//                    .buttonStyle(.plain)
            }
            .padding()
            .contentShape(.rect)
            .onTapGesture {
                manager.isExpanded = true
            }
        }
    }
    
    private func resumePlayback() {
        if let currentVerse = manager.currentVerse {
            manager.play(verse: currentVerse)
        }
    }
}
