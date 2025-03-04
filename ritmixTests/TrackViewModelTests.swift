//
//  TrackViewModelTests.swift
//  ritmixTests
//
//  Created by Nico Samuelson on 04/03/25.
//

import XCTest
@testable import ritmix

final class TrackViewModelTests: XCTestCase {
    var trackViewModel: TrackViewModel!
    var mockHttpService: MockHttpService!
    var mockPlaybackService: MockPlaybackService!
    
    override func setUp() {
        super.setUp()
        mockHttpService = MockHttpService()
        mockPlaybackService = MockPlaybackService()
        trackViewModel = TrackViewModel()
        trackViewModel.httpService = mockHttpService
        trackViewModel.playbackManager = mockPlaybackService
    }
    
    override func tearDown() {
        trackViewModel = nil
        mockHttpService = nil
        mockPlaybackService = nil
        super.tearDown()
    }
    
    func testDebouncedFetchTracks() {
        trackViewModel.searchText = "Bruno Mars"
        
        let expectation = expectation(description: "Debounced fetch should call fetchTracks")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            XCTAssertEqual(self.mockHttpService.fetchTracksCallCount, 1, "fetchTracks should be called once after debounce")
            expectation.fulfill()
        }
        
        trackViewModel.debouncedFetchTracks()
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testFetchTracks_Success() {
        trackViewModel.searchText = "artist"
        mockHttpService.result = .success([
            Track(
                id: 1,
                title: "When I Was Your Man",
                artist: "Bruno Mars",
                album: "Unorthodox Jukebox",
                thumbnail: "",
                playUrl: ""
            )
        ])
        
        trackViewModel.fetchTracks()
        
        XCTAssertEqual(trackViewModel.playbackManager.tracks.count, 1, "Tracks should be fetched successfully")
        XCTAssertEqual(trackViewModel.pageState, .found, "Page state should be found")
        XCTAssertNil(trackViewModel.errors, "Errors should be nil on success")
    }
    
    func testFetchTracks_Failure() {
        trackViewModel.searchText = "artist"
        mockHttpService.result = .failure(NSError(domain: "TestError", code: 1, userInfo: nil))
        
        trackViewModel.fetchTracks()
        
        XCTAssertEqual(trackViewModel.playbackManager.tracks.count, 0, "Tracks should be empty on failure")
        XCTAssertEqual(trackViewModel.pageState, .error, "Page state should be error")
        XCTAssertNotNil(trackViewModel.errors, "Errors should be set on failure")
    }
    
    func testFormatTime() {
        XCTAssertEqual(trackViewModel.formatTime(125), "2:05", "Time formatting should be correct")
        XCTAssertEqual(trackViewModel.formatTime(60), "1:00", "Time formatting should handle exact minutes")
        XCTAssertEqual(trackViewModel.formatTime(0), "0:00", "Time formatting should handle zero seconds")
    }
}

// Mock services for testing
class MockHttpService: HttpService {
    var fetchTracksCallCount = 0
    var result: Result<[Track], Error>?
    
    override func fetchTracksData(artist: String, completion: @escaping (Result<[Track], Error>) -> Void) {
        fetchTracksCallCount += 1
        if let result = result {
            completion(result)
        }
    }
}

class MockPlaybackService: PlaybackService {
    override var tracks: [Track] {
        didSet {}
    }
}
