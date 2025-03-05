//
//  PlaybackServiceTests.swift
//  ritmixTests
//
//  Created by Nico Samuelson on 04/03/25.
//

import XCTest
import AVFoundation
@testable import ritmix

final class PlaybackServiceTests: XCTestCase {
    var playbackService: PlaybackService!
    
    func populateTracks() {
        playbackService.tracks = [
            Track(
                id: 1,
                title: "Lonely",
                artist: "Justin Bieber",
                album: "Justice",
                thumbnail: "https://is1-ssl.mzstatic.com/image/thumb/Music124/v4/f5/7a/9e/f57a9e6a-31c8-0784-dfbd-4a0120bfd4af/21UMGIM17517.rgb.jpg/100x100bb.jpg",
                playUrl: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview122/v4/a7/32/0a/a7320af8-ddc6-f7ef-4812-8a3877cfd780/mzaf_12836494553105178407.plus.aac.p.m4a"
            ),
            Track(
                id: 2,
                title: "Ghost",
                artist: "Justin Bieber",
                album: "Justice",
                thumbnail: "https://is1-ssl.mzstatic.com/image/thumb/Music124/v4/f5/7a/9e/f57a9e6a-31c8-0784-dfbd-4a0120bfd4af/21UMGIM17517.rgb.jpg/100x100bb.jpg",
                playUrl: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview122/v4/d9/79/54/d9795413-f334-81e2-5782-99981cd05370/mzaf_1178943107324861277.plus.aac.p.m4a"
            ),
            Track(
                id: 3,
                title: "STAY",
                artist: "Justin Bieber",
                album: "F*CK LOVE 3+: OVER YOU",
                thumbnail: "https://is1-ssl.mzstatic.com/image/thumb/Music125/v4/9d/69/f1/9d69f15c-7bcc-24e9-0adc-ec3afd0bf5cc/886449473663.jpg/100x100bb.jpg",
                playUrl:
                    "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview221/v4/67/69/6d/67696df4-c2da-e548-5e50-679f3466c368/mzaf_484185972701973857.plus.aac.p.m4a"
            ),
            Track(
                id: 4,
                title: "STAY",
                artist: "Justin Bieber",
                album: "F*CK LOVE 3+: OVER YOU",
                thumbnail: "https://is1-ssl.mzstatic.com/image/thumb/Music125/v4/9d/69/f1/9d69f15c-7bcc-24e9-0adc-ec3afd0bf5cc/886449473663.jpg/100x100bb.jpg",
                playUrl:
                    "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview221/v4/67/69/6d/67696df4-c2da-e548-5e50-679f3466c368/mzaf_484185972701973857.plus.aac.p.m4a"
            ),
            Track(
                id: 5,
                title: "STAY",
                artist: "Justin Bieber",
                album: "F*CK LOVE 3+: OVER YOU",
                thumbnail: "https://is1-ssl.mzstatic.com/image/thumb/Music125/v4/9d/69/f1/9d69f15c-7bcc-24e9-0adc-ec3afd0bf5cc/886449473663.jpg/100x100bb.jpg",
                playUrl:
                    "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview221/v4/67/69/6d/67696df4-c2da-e548-5e50-679f3466c368/mzaf_484185972701973857.plus.aac.p.m4a"
            ),
        ]
        playbackService.queue = playbackService.tracks
    }
    
    override func setUp() {
        super.setUp()
        playbackService = PlaybackService()
        populateTracks()
        playbackService.currentTrack = playbackService.tracks[1]
    }
    
    override func tearDown() {
        playbackService = nil
        super.tearDown()
    }
    
    func testPlayTrack() {
        let expectation = self.expectation(description: "Track should start playing")
        
        self.playbackService.playTrack()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            XCTAssertNotNil(self.playbackService.player, "Player should be initialized")
            XCTAssertTrue(self.playbackService.isPlaying, "Playback status should be set to playing")
            XCTAssertEqual(self.playbackService.player.player?.timeControlStatus, .playing, "Player should be playing")
            XCTAssertGreaterThan(self.playbackService.currentTrackDuration, 0, "Track duration should be greater than zero")
            XCTAssertGreaterThan(self.playbackService.currentTime, 0, "Current time should be greater than zero")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testTogglePlayback() {
        self.playbackService.isPlaying = true
        
        self.playbackService.togglePlayback()
        XCTAssertEqual(self.playbackService.isPlaying, false)
        self.playbackService.togglePlayback()
        XCTAssertEqual(self.playbackService.isPlaying, true)
    }
    
    func testPlayNextTrack() {
        let expectation1 = expectation(description: "Fifth track should be playing")
        let expectation2 = expectation(description: "First track should be playing")
        self.playbackService.currentTrack = self.playbackService.tracks[3]
        self.playbackService.playTrack()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) { [weak self] in
            guard let self = self else { return }
            self.playbackService.playNextTrack()
            //            DispatchQueue.main.asyncAfter(.now() + 1.0) {
            XCTAssertEqual(self.playbackService.getCurrentTrackIndex(), 4, "Fifth track should be playing")
            expectation1.fulfill()
            
            //                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.playbackService.playNextTrack()
            XCTAssertEqual(self.playbackService.getCurrentTrackIndex(), 0, "First track should be playing")
            expectation2.fulfill()
            //                }
            //            }
        }
        
        waitForExpectations(timeout: 6, handler: nil)
    }
    
    func testReplayTrack() {
        let expectation = expectation(description: "Can replay song")
        self.playbackService.currentTrack = self.playbackService.tracks[1]
        self.playbackService.playTrack()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 7.5) {
            self.playbackService.playPrevTrack()
            XCTAssertEqual(self.playbackService.currentTime, 0.0, accuracy: 0.5, "Replaying track from the start")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    func testPlayPrevTrack() {
        let expectation1 = expectation(description: "First track should be playing")
        let expectation2 = expectation(description: "Fifth track should be playing")
        
        // Set the initial track to the second one
        self.playbackService.currentTrack = self.playbackService.tracks[1]
        self.playbackService.playTrack()
        
        // Play previous track after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) { [weak self] in
            guard let self = self else { return }
            self.playbackService.playPrevTrack()
            XCTAssertEqual(self.playbackService.getCurrentTrackIndex(), 0, "First track should be playing")
            expectation1.fulfill()
            
            self.playbackService.playPrevTrack()
            XCTAssertEqual(self.playbackService.getCurrentTrackIndex(), 4, "Fifth track should be playing")
            expectation2.fulfill()
        }
        
        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    
    func testSeeking() {
        let expectation = expectation(description: "Can seek to specific time")
        self.playbackService.playTrack()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            self.playbackService.seekTo(second: 5)
            XCTAssertEqual(self.playbackService.currentTime, 5, accuracy: 0.5, "Seeking to 5 seconds")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    func testShuffleRemainingQueue() {
        let expectation = expectation(description: "Tracks after the current track should be shuffled")
        
        // Set up initial state
        playbackService.currentTrack = playbackService.tracks[0] // Assume first track is playing
        let originalQueue = playbackService.tracks
        
        // Call shuffle function
        playbackService.toggleShuffle()
        
        // Extract shuffled portion
        let currentIndex = playbackService.getCurrentTrackIndex()
        let shuffledPart = Array(playbackService.queue[(currentIndex + 1)...])
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            XCTAssertEqual(self.playbackService.queue.prefix(currentIndex + 1), originalQueue.prefix(currentIndex + 1), "Tracks before the current track should remain unchanged")
            
            XCTAssertNotEqual(shuffledPart, Array(originalQueue[(currentIndex + 1)...]), "Tracks after the current track should be shuffled")
            
            XCTAssertEqual(self.playbackService.queue.sorted { $0.id ?? 0 < $1.id ?? 0 }, originalQueue.sorted { $0.id ?? 0 < $1.id ?? 0 }, "Shuffling should not add or remove tracks")
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
}
