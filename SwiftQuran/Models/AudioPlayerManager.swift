import AVFoundation

@Observable class AudioPlayerManager {
    @ObservationIgnored private var player: AVPlayer?
    @ObservationIgnored private var timeObserverToken: Any?
    
    var isPlaying = false
    var currentTime: Double = 0
    var duration: Double = 0
    var currentVerse: Verse?
    var isExpanded = false
    
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
    
    var currentSurahTitle: String {
        currentVerse?.surah?.translation ?? ""
    }
    
    var currentAyahLabel: String {
        guard let verse = currentVerse else { return "" }
        return "Ayah \(verse.verseIndex)"
    }
    
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
        configureMetadata(for: playerItem)
        addTimeObserver()
        
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
        removeTimeObserver()
        isPlaying = false
        currentTime = 0
        duration = 0
        currentVerse = nil
        isExpanded = false
    }
    
    func seek(to time: Double) {
        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        player?.seek(to: cmTime)
        currentTime = time
    }
    
    private func configureMetadata(for playerItem: AVPlayerItem) {
        let assetDuration = playerItem.asset.duration
        if assetDuration.isNumeric {
            duration = assetDuration.seconds
        } else {
            duration = 0
        }
        currentTime = 0
    }
    
    private func addTimeObserver() {
        removeTimeObserver()
        guard let player else { return }
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self, let player = self.player else { return }
            currentTime = time.seconds
            if let item = player.currentItem {
                let duration = item.duration
                if duration.isNumeric {
                    self.duration = duration.seconds
                }
            }
        }
    }
    
    private func removeTimeObserver() {
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
            timeObserverToken = nil
        }
    }
}

private extension CMTime {
    var isNumeric: Bool {
        isValid && !flags.contains(.indefinite) && !flags.contains(.positiveInfinity) && !flags.contains(.negativeInfinity)
    }
    
    var seconds: Double {
        CMTimeGetSeconds(self)
    }
}
