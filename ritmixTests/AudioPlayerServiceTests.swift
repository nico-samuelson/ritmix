//
//  AudioPlayerServiceTests.swift
//  ritmixTests
//
//  Created by Nico Samuelson on 04/03/25.
//

import XCTest
import AVFoundation
@testable import ritmix

final class AudioPlayerServiceTests: XCTestCase {
    var audioPlayerService: AudioPlayerService!
    
    override func setUp() {
        super.setUp()
        audioPlayerService = AudioPlayerService()
    }
    
    override func tearDown() {
        audioPlayerService = nil
        super.tearDown()
    }
    
    func testActivateSession() {
        audioPlayerService.activateSession()
        
        XCTAssertEqual(audioPlayerService.session.category, .playback, "Audio session category should be set to playback")
        XCTAssertTrue(audioPlayerService.session.isOtherAudioPlaying == false, "Other audio should not be playing")
    }
    
    func testStartAudioWithValidURL() {
        let expectation = self.expectation(description: "Audio should start playing")
        audioPlayerService.startAudio()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            XCTAssertNotNil(self.audioPlayerService.player, "Player should be initialized")
            XCTAssertEqual(self.audioPlayerService.player?.timeControlStatus, .playing, "Player should be playing")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testPauseAndPlay() {
        let expectation = self.expectation(description: "Player should transition to playing")
        
        audioPlayerService.startAudio()
        audioPlayerService.pause()
        XCTAssertEqual(audioPlayerService.player?.timeControlStatus, .paused, "Player should be paused")
        
        audioPlayerService.play()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            XCTAssertEqual(self.audioPlayerService.player?.timeControlStatus, .playing, "Player should be playing")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testSeekToTime() {
        audioPlayerService.startAudio()
        
        let seekTime: Double = 10.0
        audioPlayerService.seekTo(time: seekTime)
        
        let currentTime = audioPlayerService.player?.currentTime().seconds ?? 0.0
        XCTAssertEqual(currentTime, seekTime, accuracy: 0.5, "Seek time should be approximately \(seekTime) seconds")
    }
    
    func testGetDurationWhenReady() {
        let expectation = self.expectation(description: "Duration should be retrieved")
        
        audioPlayerService.startAudio()
        audioPlayerService.getDurationWhenReady { duration in
            XCTAssertGreaterThan(duration, 0, "Duration should be greater than 0")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
}
