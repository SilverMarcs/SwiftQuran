import SwiftUI

struct ExpandedAudioPlayer: View {
    @Environment(AudioPlayerManager.self) var manager
    
    private var sliderRange: ClosedRange<Double> {
        let upper = max(manager.duration, manager.currentTime)
        return 0...max(upper, 1)
    }
    
    var body: some View {
        VStack {
            GlassEffectContainer {
                HStack {
                    Button {
                        manager.seek(to: max(0, manager.currentTime - 5))
                    } label: {
                        Image(systemName: "gobackward.5")
                            .font(.title)
                            .padding(8)
                    }
                    
                    Button {
                        if manager.isPlaying {
                            manager.pause()
                        } else {
                            resumePlayback()
                        }
                    } label: {
                        Image(systemName: manager.isPlaying ? "pause.fill" : "play.fill")
                            .contentTransition(.symbolEffect(.replace))
                            .font(.largeTitle)
                            .padding(15)
                            .frame(width: 60)
                    }

                    
                    Button {
                        manager.seek(to: min(manager.duration, manager.currentTime + 5))
                    } label: {
                        Image(systemName: "goforward.5")
                            .padding(8)
                    }
                    .font(.title)
                }
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
            }
            
            Slider(value: Binding(
                get: { manager.currentTime },
                set: { manager.seek(to: $0) }
            ), in: sliderRange)
            .disabled(manager.duration <= 0)
            .padding(.horizontal)
        }
        .padding()
        .toolbarTitleDisplayMode(.inline)
        .navigationTitle(manager.currentSurahTitle)
        .navigationSubtitle(manager.currentAyahLabel)
    }
    
    private func resumePlayback() {
        if let currentVerse = manager.currentVerse {
            manager.play(verse: currentVerse)
        }
    }
}
