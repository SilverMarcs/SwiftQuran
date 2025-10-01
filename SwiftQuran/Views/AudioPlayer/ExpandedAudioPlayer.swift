import SwiftUI

struct ExpandedAudioPlayer: View {
    @Environment(AudioPlayerManager.self) var manager
    
    private var sliderRange: ClosedRange<Double> {
        let upper = max(manager.duration, manager.currentTime)
        return 0...max(upper, 1)
    }
    
    var body: some View {
        VStack {
            Text(manager.currentSurahTitle)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(manager.currentAyahLabel)
                .font(.headline)
                .fontWeight(.medium)
            
            Spacer()
                
            HStack {
                GlassEffectContainer {
                    Button {
                        manager.seek(to: max(0, manager.currentTime - 5))
                    } label: {
                        Image(systemName: "gobackward.5")
                            .font(.title)
                            .padding(8)
                    }
                    .buttonStyle(.glass)
                    
                    Button {
                        if manager.isPlaying {
                            manager.pause()
                        } else {
                            resumePlayback()
                        }
                    } label: {
                        Image(systemName: manager.isPlaying ? "pause" : "play.fill")
                            .contentTransition(.symbolEffect(.replace))
                            .font(.largeTitle)
                            .padding(15)
                            .frame(width: 60)
                    }
                    .buttonStyle(.glass)
                    
                    Button {
                        manager.seek(to: min(manager.duration, manager.currentTime + 5))
                    } label: {
                        Image(systemName: "goforward.5")
                            .padding(8)
                    }
                    .buttonStyle(.glass)
                    .font(.title)
                }
                .buttonBorderShape(.circle)
            }
            
            Spacer()
            
            Slider(value: Binding(
                get: { manager.currentTime },
                set: { manager.seek(to: $0) }
            ), in: sliderRange)
            .disabled(manager.duration <= 0)
            .padding(.horizontal)
        }
        .padding()
        .padding(.top, 10)
    }
    
    private func resumePlayback() {
        if let currentVerse = manager.currentVerse {
            manager.play(verse: currentVerse)
        }
    }
}
