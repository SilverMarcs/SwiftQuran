import AVFoundation
import Combine

@Observable class AudioPlayerManager {
    @ObservationIgnored static let shared = AudioPlayerManager()
    
    @ObservationIgnored private var player: AVPlayer?
    
    var isPlaying = false
    var currentTime: Double = 0
    var duration: Double = 0
    var currentVerse: Verse?
    
    // Computed properties for easier access to verse information
    var currentSurahNumber: Int? {
        currentVerse?.surahNumber
    }
    
    var currentVerseNumber: Int? {
        currentVerse?.verseIndex
    }
    
    // Legacy computed property for compatibility
    var currentVerseId: String? {
        guard let verse = currentVerse else { return nil }
        return "verse_\(verse.verseKey)"
    }
    
    private init() {}
    
    func play(url: URL, verse: Verse) {
        // Stop current playback if different verse
        let verseId = "verse_\(verse.verseKey)"
        if currentVerseId != verseId {
            stop()
        }
        
        // If same verse and paused, just resume
        if currentVerse?.id == verse.id && player != nil {
            player?.play()
            isPlaying = true
            return
        }
        
        // New playback
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        currentVerse = verse
        
        player?.play()
        isPlaying = true
    }
    
    // Convenience method to play a verse directly from Verse object
    func play(verse: Verse) {
        let urlString = "https://the-quran-project.github.io/Quran-Audio/Data/1/\(verse.verseKey).mp3"
        guard let url = URL(string: urlString) else { return }
        play(url: url, verse: verse)
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
    }
    
    func stop() {
        player?.pause()
        player = nil
        isPlaying = false
        currentTime = 0
        duration = 0
        currentVerse = nil
    }
    
    func seek(to time: Double) {
        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        player?.seek(to: cmTime)
    }
}
