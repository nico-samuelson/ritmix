import Foundation

@Observable
class PlaybackService {
    var player: AudioPlayerService = AudioPlayerService()
    var tracks: [Track] = []
    var queue: [Track] = []
    var currentTrack: Track? = nil
    var currentTrackDuration: Double = 0
    var currentTime: Double = 0
    
    var isPlaying: Bool = false
    var isSliding: Bool = false
    var isShuffled: Bool = false
    var isRepeat: Bool = false
    
    func setupTimeObserver() {
        self.player.addPeriodicTimeObserver { [weak self] time in
            if !(self?.isSliding ?? false) {
                self?.currentTime = time
            }
            self?.fadeOutVolume()
        }
    }
    
    func getCurrentTrackIndex() -> Int {
        return self.queue.firstIndex(where: {$0.id == currentTrack?.id}) ?? -1
    }
    
    func playTrack() {
        self.player.startAudio(urlString: currentTrack?.playUrl)
        self.isPlaying = true
        
        self.setupTimeObserver()
        
        self.player.getDurationWhenReady { [weak self] duration in
            DispatchQueue.main.async {
                self?.currentTrackDuration = duration
            }
        }
    }
    
    func togglePlayback() {
        if self.isPlaying {
            self.player.pause()
            self.isPlaying = false
        } else {
            self.player.play()
            self.isPlaying = true
        }
    }
    
    @objc func playNextTrack() {
        if isRepeat {
            self.seekTo(second: 0)
        }
        else {
            let index = (self.getCurrentTrackIndex() + 1) % self.queue.count
            self.currentTrack = self.queue[index]
            self.playTrack()
        }
    }
    
    func playPrevTrack() {
        if self.currentTime > 5.0 {
            seekTo(second: 0)
        } else {
            let currentIndex = self.getCurrentTrackIndex()
            if currentIndex > 0 {
                self.currentTrack = self.queue[currentIndex - 1]
                self.playTrack()
            } else {
                self.currentTrack = self.queue[queue.count - 1]
                self.playTrack()
            }
        }
    }
    
    func seekTo(second: Double) {
        self.player.pauseTimeObserver()
        self.player.seekTo(time: second)
        self.currentTime = second
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.setupTimeObserver()
            self.player.play()
        }
    }
    
    func fadeOutVolume() {
        if self.currentTrackDuration - self.currentTime <= 4.0 {
            self.player.player?.volume -= max(0, 1.0 / 40)
        }
    }
    
    func toggleShuffle() {
        self.isShuffled.toggle()
        let currentIndex = getCurrentTrackIndex()
        
        if self.isShuffled {
            if currentIndex >= 0 && currentIndex < queue.count - 1 {
                let remainingTracks = queue[(currentIndex + 1)...].shuffled()
                queue = Array(queue.prefix(currentIndex + 1)) + remainingTracks
            }
        }
        else {
            self.queue = Array(tracks[currentIndex...])
        }
    }
    
    func addToQueue(track: Track) {
        queue.append(track)
    }
    
    func removeFromQueue(track: Track) {
        queue.removeAll { $0.id == track.id }
    }
}
