//
//  AudioPlayerService.swift
//  ritmix
//
//  Created by Nico Samuelson on 03/03/25.
//
import AVFoundation

class AudioPlayerService {
    var player: AVPlayer?
    var session = AVAudioSession.sharedInstance()
    private var timeObserverToken: Any?
    private var statusObserver: NSKeyValueObservation?
    private var durationObserver: NSKeyValueObservation?
    
    init() {}
    
    deinit {
        removeObservers()
        player = nil
    }
    
    func activateSession() {
        do {
            try session.setCategory(
                .playback,
                mode: .default,
                options: []
            )
        } catch _ {}
        
        do {
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch _ {}
        
        do {
            try session.overrideOutputAudioPort(.speaker)
        } catch _ {}
    }
    
    func deactivateSession() {
        removeObservers()
        do {
            try session.setActive(false, options: .notifyOthersOnDeactivation)
        } catch let error as NSError {
            logger.error("Failed to deactivate audio session: \(error.localizedDescription)")
        }
    }
    
    func startAudio(urlString: String? = nil) {
        deactivateSession()
        activateSession()
        let urlString = urlString ?? "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview122/v4/a7/32/0a/a7320af8-ddc6-f7ef-4812-8a3877cfd780/mzaf_12836494553105178407.plus.aac.p.m4a"
        
        guard let url = URL(string: urlString) else {
            logger.error("Invalid URL provided")
            return
        }
        
        let playerItem = AVPlayerItem(url: url)
        
        // Remove previous observer
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        
        if let player = player {
            player.replaceCurrentItem(with: playerItem)
        } else {
            player = AVPlayer(playerItem: playerItem)
        }
        
        if let player = player {
            player.volume = 1.0
            player.play()
        }
        
        // Observe when the track ends
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(trackDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: playerItem
        )
    }
    
    func addPeriodicTimeObserver(onUpdate: @escaping (Double) -> Void) {
        guard let player = player else {
            logger.info("Cannot add time observer - player is nil")
            return
        }
        
        // Remove any existing time observer
        if let timeObserverToken = timeObserverToken {
            player.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
        
        // Add new time observer for live update
        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
            let seconds = CMTimeGetSeconds(time)
            onUpdate(seconds)
        }
    }
    
    func pauseTimeObserver() {
        if let timeObserverToken = timeObserverToken, let player = player {
            player.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
    
    func removeObservers() {
        statusObserver?.invalidate()
        durationObserver?.invalidate()
        
        pauseTimeObserver()
    }
    
    func play() {
        if let player = player {
            player.play()
        }
    }
    
    func pause() {
        if let player = player {
            player.pause()
        }
    }
    
    func getDurationWhenReady(completion: @escaping (Double) -> Void) {
        guard let playerItem = player?.currentItem else {
            completion(0)
            return
        }
        
        // If already available, return immediately
        if playerItem.status == .readyToPlay && playerItem.duration.seconds > 0 {
            completion(playerItem.duration.seconds)
            return
        }
        
        var statusObserver: NSKeyValueObservation?
        
        // Assign value to duration as soon as it's ready
        statusObserver = playerItem.observe(\.status, options: [.new]) { item, _ in
            if item.status == .readyToPlay {
                DispatchQueue.main.async {
                    completion(item.duration.seconds)
                }
                // Clean up the observer after getting the duration
                statusObserver?.invalidate()
            }
        }
    }
    
    func seekTo(time: Double) {
        guard let player = player else { return }
        let targetTime = CMTime(seconds: time, preferredTimescale: 1000)
        player.seek(
            to: targetTime,
            toleranceBefore: .zero,
            toleranceAfter: .zero
        )
    }
    
    @objc private func trackDidFinishPlaying(_ notification: Notification) {
        // Notify SwiftUI ViewModel that track has finished
        NotificationCenter.default.post(name: NSNotification.Name("TrackFinished"), object: nil)
    }
}
