import AVFoundation
import Combine

class AudioPlayerManager: ObservableObject {
    static let shared = AudioPlayerManager()
    
    private var player: AVPlayer?
    private var timeObserver: Any?
    
    @Published var isPlaying = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    @Published var currentVerse: Verse?
    
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
        
        setupPlayerObservers(playerItem: playerItem)
        
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
        removeTimeObserver()
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
    
    private func setupPlayerObservers(playerItem: AVPlayerItem) {
        // Duration observer
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { [weak self] _ in
            // Only pause and update state, do not reset player or state
            self?.player?.pause()
            self?.isPlaying = false
            // Do not call stop(), do not set player = nil, do not reset currentTime/duration/currentVerse
        }
        
        // Time observer
        let interval = CMTime(seconds: 0.1, preferredTimescale: 600)
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.currentTime = time.seconds
            
            if let duration = self?.player?.currentItem?.duration.seconds, !duration.isNaN {
                self?.duration = duration
            }
        }
    }
    
    private func removeTimeObserver() {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        removeTimeObserver()
    }
}
