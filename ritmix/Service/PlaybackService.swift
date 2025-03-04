//
//  PlaybackService.swift
//  ritmix
//
//  Created by Nico Samuelson on 04/03/25.
//

import Foundation

@Observable
class PlaybackService {
    var player: AudioPlayerService = AudioPlayerService()
    var tracks: [Track] = []
    var currentTrack: Track? = nil
    var currentTrackDuration: Double = 0
    var currentTime: Double = 0
    
    var isPlaying: Bool = false
    var isSliding: Bool = false
    
    func setupTimeObserver() {
        self.player.addPeriodicTimeObserver { [weak self] time in
            if !(self?.isSliding ?? false) {
                self?.currentTime = time
            }
            self?.fadeOutVolume()
        }
    }
    
    func getCurrentTrackIndex() -> Int {
        return self.tracks.firstIndex(where: {$0.id == currentTrack?.id}) ?? -1
    }
    
    func playTrack() {
        // Start playback with the track's URL
        self.player.startAudio(urlString: currentTrack?.playUrl)
        self.isPlaying = true
        
        // Setup Time Observer to get live updates
        self.setupTimeObserver()
        
        // Get duration when ready
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
        }
        else {
            self.player.play()
            self.isPlaying = true
        }
    }
    
    @objc func playNextTrack() {
        let index = (self.getCurrentTrackIndex() + 1) % self.tracks.count
        self.currentTrack = self.tracks[index]
        self.playTrack()
    }
    
    func playPrevTrack() {
        // Replay the track if it's already played more than 5s
        if self.currentTime > 5.0 {
            seekTo(second: 0)
        }
        else {
            let currentIndex = self.getCurrentTrackIndex()
            if currentIndex > 0 {
                self.currentTrack = self.tracks[currentIndex - 1]
                self.playTrack()
            } else {
                self.currentTrack = self.tracks[tracks.count - 1]
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
}
