//
//  TrackViewModel.swift
//  mmp
//
//  Created by Nico Samuelson on 03/03/25.
//

import Foundation
import AVFoundation

@Observable
class TrackViewModel: ObservableObject {
    var tracks: [Track] = []
    var player: AudioPlayerService = AudioPlayerService()
    
    var isLoading: Bool = false
    var isPlaying: Bool = false
    var isSliding: Bool = false
    
    var duration: Double = 30
    var currentTime: Double = 0
    var currentTrack: Track? = nil
    
    var searchText: String = ""
    var errors: String = ""
    private var debounceWorkItem: DispatchWorkItem?
    
    func debouncedFetchTracks() {
        self.debounceWorkItem?.cancel()
        
        let workItem = DispatchWorkItem {
            self.fetchTracks()
        }
        
        self.debounceWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: workItem)
    }
    
    func fetchTracks() {
        if self.searchText != "" {
            self.isLoading = true
            fetchITunesData(artist: searchText.lowercased()) { result in
                self.isLoading = false
                switch result {
                case .success(let tracks):
                    self.errors = ""
                    print(tracks)
                    self.tracks = tracks
                case .failure(let error):
                    self.errors = error.localizedDescription
                    self.tracks = []
                    print("Error fetching data: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Helper function to format seconds to mm:ss
    func formatTime(_ seconds: Double) -> String {
        let totalSeconds = Int(seconds)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
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
        self.player.startAudio(urlString: currentTrack?.playURL)
        self.isPlaying = true
        
        self.setupTimeObserver()
        
        // Get duration when ready
        self.player.getDurationWhenReady { [weak self] duration in
            DispatchQueue.main.async {
                self?.duration = duration
            }
        }
    }
    
    func pauseTrack() {
        self.player.pause()
        self.isPlaying = false
    }
    
    func resumeTrack() {
        self.player.play()
        self.isPlaying = true
    }
    
    @objc func playNextTrack() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let index = (self.getCurrentTrackIndex() + 1) % self.tracks.count
            self.currentTrack = self.tracks[index]
            self.playTrack()
        }
    }
    
    func playPrevTrack() {
        // replay the track if it's already played more than 5s
        if self.currentTime > 5.0 {
            return seekTo(second: 0)
        }
        
        let currentIndex = self.getCurrentTrackIndex()
        if currentIndex > 0 {
            self.currentTrack = self.tracks[currentIndex - 1]
            return self.playTrack()
        } else {
            self.currentTrack = self.tracks[tracks.count - 1]
            return self.playTrack()
        }
    }
    
    func seekTo(second: Double) {
        player.pauseTimeObserver()
        
        player.seekTo(time: second)
        currentTime = second
        
        setupTimeObserver()
        resumeTrack()
    }
    
    func fadeOutVolume() {
        if duration - currentTime <= 4.0 {
            self.player.player?.volume -= max(0, 1.0 / 40)
        }
    }
}
