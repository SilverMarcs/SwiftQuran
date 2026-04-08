import SwiftUI
import AVKit

struct VerseRow: View {
    let verse: Verse
    var surahTitle: String = ""

    @AppStorage("arabicTextFontSize") var arabicTextFontSize: Double = 26
    @AppStorage("translationFontSize") var translationFontSize: Double = 18
    
    @Environment(ReadingProgressManager.self) var progressManager
    @Environment(SavedVersesManager.self) var savedVersesManager
    @Environment(AudioPlayerManager.self) var audioPlayer

    private var verseId: String {
        "verse_\(verse.verseKey)"
    }

    private var isCurrentVerse: Bool {
        audioPlayer.currentVerseId == verseId
    }

    var body: some View {
        NavigationLink(value: verse) {
            VStack(spacing: 16) {
                Text(verse.text)
                    #if os(macOS)
                    .opacity(0.9)
                    #else
                    .opacity(0.8)
                    #endif
                    .lineSpacing(15)
                    .fontDesign(.serif)
                    .font(.system(size: arabicTextFontSize))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .environment(\.layoutDirection, .rightToLeft)

                Text("\(verse.verseIndex) • \(verse.translation)")
                    .textSelection(.enabled)
                    .font(.system(size: translationFontSize))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
                    Button {
                        savedVersesManager.toggleSaved(verse: verse)
                    } label: {
                        Image(systemName: savedVersesManager.isSaved(verse: verse) ? "heart.fill" : "heart")
                            .frame(width: 20, height: 20)
                    }
                    .buttonStyle(.glass)
                    .foregroundStyle(savedVersesManager.isSaved(verse: verse) ? .red : .secondary)

                    if verse.isProstrationVerse {
                        Text("Sajdah")
                            .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Button {
                        progressManager.toggleProgress(for: verse)
                    } label: {
                        Image(systemName: progressManager.isProgress(for: verse) ? "bookmark.fill" : "bookmark")
                            .frame(width: 20, height: 20)
                    }
                    .buttonStyle(.glass)
                    .foregroundStyle(progressManager.isProgress(for: verse) ? .accent : .secondary)

                    Button {
                        if isCurrentVerse && audioPlayer.isPlaying {
                            audioPlayer.pause()
                        } else {
                            audioPlayer.play(verse: verse, surahTitle: surahTitle)
                        }
                    } label: {
                        Image(systemName: (isCurrentVerse && audioPlayer.isPlaying) ? "pause.fill" : "play.fill")
                            .frame(width: 20, height: 20)
                    }
                    .buttonStyle(.glass)
                    .foregroundStyle((isCurrentVerse && audioPlayer.isPlaying) ? .accent : .secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .foregroundStyle(.primary)
        .navigationLinkIndicatorVisibility(.hidden)
        .id("verse\(verse.id)")
    }
}

#Preview {
    VerseRow(verse: Mock.verse)
        .padding()
        .environment(AudioPlayerManager())
}
