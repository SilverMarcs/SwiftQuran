import AVFoundation
import Combine

class AudioPlayerManager: ObservableObject {
    static let shared = AudioPlayerManager()
    
    private var player: AVPlayer?
    private var timeObserver: Any?
    
    @Published var isPlaying = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    @Published var currentVerseId: String?
    
    // Computed properties for easier access to verse information
    var currentSurahNumber: Int? {
        guard let verseId = currentVerseId else { return nil }
        let components = verseId.components(separatedBy: "_")
        if components.count == 3, let surahNumber = Int(components[1]) {
            return surahNumber
        }
        return nil
    }
    
    var currentVerseNumber: Int? {
        guard let verseId = currentVerseId else { return nil }
        let components = verseId.components(separatedBy: "_")
        if components.count == 3, let verseNumber = Int(components[2]) {
            return verseNumber
        }
        return nil
    }
    
    private init() {}
    
    func play(url: URL, verseId: String) {
        // Stop current playback if different verse
        if currentVerseId != verseId {
            stop()
        }
        
        // If same verse and paused, just resume
        if currentVerseId == verseId && player != nil {
            player?.play()
            isPlaying = true
            return
        }
        
        // New playback
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        currentVerseId = verseId
        
        setupPlayerObservers(playerItem: playerItem)
        
        player?.play()
        isPlaying = true
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
        currentVerseId = nil
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
            self?.stop()
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
