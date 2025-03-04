//
//  HttpServiceTests.swift
//  ritmixTests
//
//  Created by Nico Samuelson on 04/03/25.
//

import XCTest
@testable import ritmix

final class HttpServiceTests: XCTestCase {
    var httpService: HttpService!

    override func setUp() {
        super.setUp()
        httpService = HttpService()
    }

    override func tearDown() {
        httpService = nil
        super.tearDown()
    }

    func testFetchTracksData_RealAPI() {
        let expectation = expectation(description: "Real API call should succeed and return tracks")
        
        httpService.fetchTracksData(artist: "Taylor Swift") { result in
            switch result {
            case .success(let tracks):
                XCTAssertFalse(tracks.isEmpty, "API should return at least one track")
                print("Fetched \(tracks.count) tracks")
            case .failure(let error):
                XCTFail("API call failed with error: \(error.localizedDescription)")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testFetchTracksData_NetworkFailure() {
        let expectation = expectation(description: "API call should fail due to no internet")

        // Using a non-existing domain to simulate a network error
        httpService.callAPI(urlString: "https://invalid.apple.com") { (result: Result<iTunesResponse, Error>) in
            switch result {
            case .success:
                XCTFail("API should not succeed without internet")
            case .failure(let error):
                XCTAssertNotNil(error, "Error should not be nil")
                print("Network failure simulated: \(error.localizedDescription)")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testFetchTracksData_InvalidJSON() {
        let expectation = expectation(description: "API call should fail due to invalid JSON")
        
        // Calling a URL that doesn't return valid JSON
        httpService.fetchTracksData(artist: "u") { result in
            switch result {
            case .success:
                XCTFail("API should fail if JSON format is invalid")
            case .failure(let error):
                XCTAssertNotNil(error, "Error should not be nil")
                print("JSON decoding failure simulated: \(error.localizedDescription)")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testFetchTracksData_NotFound() {
        let expectation = expectation(description: "API call should succeed even if no data is returned")
        
        // Calling a URL that doesn't return valid JSON
        httpService.fetchTracksData(artist: "uaksjdakjdaksjd") { result in
            switch result {
            case .success(let tracks):
                XCTAssertTrue(tracks.isEmpty, "API should return empty result")
            case .failure(let error):
                XCTAssertNil(error, "Error should be nil")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
}
