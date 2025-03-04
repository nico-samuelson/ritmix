//
//  TrackViewModel.swift
//  mmp
//
//  Created by Nico Samuelson on 03/03/25.
//

import Foundation

@Observable
class TrackViewModel: ObservableObject {
    var playbackManager: PlaybackService = PlaybackService()
    var httpService: HttpService = HttpService()
    var pageState: PageState = .idle
    var searchText: String = ""
    var errors: String? = nil
    private var debounceWorkItem: DispatchWorkItem?
    
    func debouncedFetchTracks() {
        self.debounceWorkItem?.cancel()
        
        let workItem = DispatchWorkItem {
            self.fetchTracks()
        }
        
        self.debounceWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
    }
    
    func fetchTracks() {
        if self.searchText != "" {
            pageState = .loading
            self.httpService.fetchTracksData(artist: searchText.lowercased()) { result in
                switch result {
                case .success(let tracks):
                    self.playbackManager.tracks = tracks
                    self.errors = nil
                    self.pageState = tracks.count == 0 ? .notFound : .found
                case .failure(let error):
                    self.playbackManager.tracks = []
                    self.errors = error.localizedDescription
                    self.pageState = .error
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
}

enum PageState {
    case idle
    case loading
    case notFound
    case error
    case found
}
