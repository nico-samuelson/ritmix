//
//  TrackView.swift
//  mmp
//
//  Created by Nico Samuelson on 03/03/25.
//

import SwiftUI

struct TrackView: View {
    @State private var viewModel = TrackViewModel()
    
    var body: some View {
        NavigationStack {
            GeometryReader { gr in
                List {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                            .padding(.leading, 8)
                        
                        TextField("Search Artist...", text: $viewModel.searchText)
                            .foregroundColor(.primary)
                        
                        if !viewModel.searchText.isEmpty {
                            Button(action: {
                                viewModel.searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                                    .padding(.trailing, 8)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .listRowSeparator(.hidden)
                    .padding(10)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(10)
                    
                    switch viewModel.pageState {
                    case .idle, .error, .notFound:
                        Spacer()
                        let label = viewModel.pageState == .error ? "Error" : "No Tracks"
                        let icon = viewModel.pageState == .error ? "x.circle.fill" : "magnifyingglass"
                        
                        ContentUnavailableView {
                            Label(label, systemImage: icon)
                        } description: {
                            if viewModel.pageState == .error {
                                VStack {
                                    Text("An error occured while searching for \"\(viewModel.searchText)\". Try seearching for something else or ")
                                    Button {
                                        viewModel.debouncedFetchTracks()
                                    } label: {
                                        Text("Try again")
                                            .foregroundStyle(.accent)
                                    }
                                }
                            }
                            else if viewModel.pageState == .idle {
                                Text("Start searching to listen some music")
                            }
                            else {
                                Text("No result found for \"\(viewModel.searchText)\"")
                            }
                        }
                        .listRowSeparator(.hidden)
                    case .loading:
                        ForEach(Array(Array(0..<10).enumerated()), id: \.offset) { index, item in
                            TrackSkeleton()
                                .listRowSeparator(.hidden)
                                .padding(.bottom, index == viewModel.playbackManager.tracks.count - 1 ? 120 : 0)
                        }
                    case .found:
                        ForEach(Array(viewModel.playbackManager.tracks.enumerated()), id: \.element.id) { index, track in
                            EmptyView()
                            TrackItem(
                                track: track,
                                currentlyPlaying: viewModel.playbackManager.currentTrack?.id == track.id
                            )
                            .listRowSeparator(.hidden)
                            .padding(.bottom, index == viewModel.playbackManager.tracks.count - 1 ? 120 : 0)
                            .onTapGesture {
                                withAnimation {
                                    viewModel.playbackManager.currentTrack = track
                                    viewModel.playbackManager.playTrack()
                                }
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .navigationTitle("Play Music")
                .navigationBarTitleDisplayMode(.large)
                .overlay(alignment: .bottom) {
                    if viewModel.playbackManager.currentTrack != nil {
                        PlaybackControl(viewModel: $viewModel)
                    }
                }
            }
        }
        .onChange(of: viewModel.searchText) {
            viewModel.debouncedFetchTracks()
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("TrackFinished"))) { _ in
            withAnimation {
                let index = (viewModel.playbackManager.getCurrentTrackIndex() + 1) % viewModel.playbackManager.tracks.count
                viewModel.playbackManager.currentTrack = viewModel.playbackManager.tracks[index]
                viewModel.playbackManager.playTrack()
            }
        }
    }
}

#Preview {
    TrackView()
}
