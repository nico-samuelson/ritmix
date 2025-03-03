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
    var tracks: [Track] = [
        Track(
            title: "Lonely",
            artist: "Justin Bieber",
            album: "Justice",
            thumbnail: "https://is1-ssl.mzstatic.com/image/thumb/Music124/v4/f5/7a/9e/f57a9e6a-31c8-0784-dfbd-4a0120bfd4af/21UMGIM17517.rgb.jpg/100x100bb.jpg",
            playURL: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview122/v4/a7/32/0a/a7320af8-ddc6-f7ef-4812-8a3877cfd780/mzaf_12836494553105178407.plus.aac.p.m4a"
        ),
        Track(
            title: "Ghost",
            artist: "Justin Bieber",
            album: "Justice",
            thumbnail: "https://is1-ssl.mzstatic.com/image/thumb/Music124/v4/f5/7a/9e/f57a9e6a-31c8-0784-dfbd-4a0120bfd4af/21UMGIM17517.rgb.jpg/100x100bb.jpg",
            playURL: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview122/v4/d9/79/54/d9795413-f334-81e2-5782-99981cd05370/mzaf_1178943107324861277.plus.aac.p.m4a"
        ),
        Track(
            title: "STAY",
            artist: "Justin Bieber",
            album: "F*CK LOVE 3+: OVER YOU",
            thumbnail: "https://is1-ssl.mzstatic.com/image/thumb/Music125/v4/9d/69/f1/9d69f15c-7bcc-24e9-0adc-ec3afd0bf5cc/886449473663.jpg/100x100bb.jpg",
            playURL:
                "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview221/v4/67/69/6d/67696df4-c2da-e548-5e50-679f3466c368/mzaf_484185972701973857.plus.aac.p.m4a"
        ),
        Track(
            title: "Yummy",
            artist: "Justin Bieber",
            album: "Changes",
            thumbnail: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/d2/21/4e/d2214ea9-97ff-46ef-ac45-7fca6fb73839/20UMGIM03126.rgb.jpg/100x100bb.jpg",
            playURL:
                "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview112/v4/2b/d9/7b/2bd97bbc-5d95-5c3a-d84a-903d8f9a5056/mzaf_8453344235613291032.plus.aac.p.m4a"
        ),
        Track(
            title: "Mistletoe",
            artist: "Justin Bieber",
            album: "Under The Mistletoe (Deluxe Edition)",
            thumbnail: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/71/b9/49/71b9493c-57d3-c2dc-0ef0-d38417d7e937/11UMGIM34123.rgb.jpg/100x100bb.jpg",
            playURL:
                "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview126/v4/89/34/f4/8934f48e-e086-c284-52d2-af3c2082ae27/mzaf_9507114783062671151.plus.aac.p.m4a"
        ),
        Track(
            title: "Baby (feat. Ludacris)",
            artist: "Justin Bieber",
            album: "My World 2.0 (Bonus Track Version)",
            thumbnail: "https://is1-ssl.mzstatic.com/image/thumb/Music116/v4/b9/0a/b4/b90ab45a-07b1-0bcc-331c-c496a21d07e4/10UMGIM01134.rgb.jpg/100x100bb.jpg",
            playURL: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview122/v4/2c/87/60/2c8760ba-f050-9bad-6476-5ddb68bd0063/mzaf_5640387850150173603.plus.aac.p.m4a"
        ),
        Track(
            title: "Despacito (feat. Justin Bieber) [Remix]",
            artist: "Luis Fonsi & Daddy Yankee",
            album: "VIDA",
            thumbnail: "https://is1-ssl.mzstatic.com/image/thumb/Music211/v4/e2/ef/f0/e2eff0bc-c51d-7de5-9280-6891ddcee71b/18UMGIM85289.rgb.jpg/100x100bb.jpg",
            playURL:
                "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview122/v4/ff/5f/bc/ff5fbccd-4e48-39ee-8cf1-15d435523c47/mzaf_11702611502068121437.plus.aac.p.m4a"
        ),
        Track(
            title: "I'm the One (feat. Justin Bieber, Quavo, Chance the Rapper & Lil Wayne)",
            artist: "DJ Khaled",
            album: "Grateful",
            thumbnail: "https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/03/5d/32/035d32e9-6fdb-8f08-daf0-c2f208128d06/886446550695.jpg/100x100bb.jpg",
            playURL:
                "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview115/v4/3a/2f/6e/3a2f6eac-0bb7-5261-f749-2438dba74b5d/mzaf_15070134885630517516.plus.aac.p.m4a"
        ),
        Track(
            title: "10,000 Hours",
            artist: "Dan + Shay & Justin Bieber",
            album: "10,000 Hours - Single",
            thumbnail: "https://is1-ssl.mzstatic.com/image/thumb/Music125/v4/c4/80/7f/c4807f05-fa68-a123-c077-bf8041ff3319/054391940995.jpg/100x100bb.jpg",
            playURL: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview125/v4/9c/16/61/9c1661fd-ec64-f5e5-39b4-782398d56508/mzaf_18438317548939967601.plus.aac.p.m4a"
        ),
    ]
    var player: AudioPlayerService = AudioPlayerService()
    var isLoading: Bool = false
    var currentTime: Double = 0
    var duration: Double = 30
    var isPlaying: Bool = false
    var isSliding: Bool = false
    var searchText: String = ""
    var currentIndex: Int = -1
    
    var currentTrack: Track? {
        return (currentIndex >= 0 && currentIndex < tracks.count) ? tracks[currentIndex] : nil
    }
    
    // Helper function to format seconds to mm:ss
    func formatTime(_ seconds: Double) -> String {
        let totalSeconds = Int(seconds)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    func setupTimeObserver() {
        player.addPeriodicTimeObserver { [weak self] time in
            if !(self?.isSliding ?? false) {
                self?.currentTime = time
            }
        }
    }
    
    func playTrack() {
        // Start playback with the track's URL
        player.startAudio(urlString: currentTrack?.playURL)
        isPlaying = true
        
        setupTimeObserver()
        
        // Get duration when ready
        player.getDurationWhenReady { [weak self] duration in
            DispatchQueue.main.async {
                self?.duration = duration
            }
        }
    }
    
    func pauseTrack() {
        player.pause()
        isPlaying = false
    }
    
    func resumeTrack() {
        player.play()
        isPlaying = true
    }
    
    @objc func playNextTrack() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.currentIndex = (self.currentIndex + 1) % self.tracks.count
            self.playTrack()
        }
    }
    
    func playPrevTrack() {
        if self.currentTime > 5.0 {
            seekTo(second: 0)
        }
        else if currentIndex > 0 {
            currentIndex -= 1
            playTrack()
        } else {
            currentIndex = tracks.count - 1
            playTrack()
        }
    }
    
    func seekTo(second: Double) {
        player.pauseTimeObserver()
        
        player.seekTo(time: second)
        currentTime = second
        
        setupTimeObserver()
        resumeTrack()
    }
}
