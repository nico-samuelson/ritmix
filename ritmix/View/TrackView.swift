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
                    
                    if viewModel.isLoading {
                        ForEach(Array(Array(0..<10).enumerated()), id: \.offset) { index, item in
                            TrackSkeleton()
                                .listRowSeparator(.hidden)
                                .padding(.bottom, index == viewModel.tracks.count - 1 ? 120 : 0)
                        }
                    }
                    else if viewModel.tracks.isEmpty {
                        Spacer()
                        if viewModel.searchText != "" && viewModel.isLoading {
                            ContentUnavailableView {
                                Label("No Tracks", systemImage: "magnifyingglass")
                            } description: {
                                Text("No result found for \"\(viewModel.searchText)\"")
                            }
                            .listRowSeparator(.hidden)
                        }
                        else if viewModel.searchText == "" && viewModel.tracks.isEmpty {
                            ContentUnavailableView {
                                Label("No Tracks", systemImage: "magnifyingglass")
                            } description: {
                                Text("Start searching to listen some music")
                            }
                            .listRowSeparator(.hidden)
                        }
                        else if viewModel.errors != "" {
                            ContentUnavailableView {
                                Label("Error", systemImage: "x.circle.fill")
                            } description: {
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
                            .listRowSeparator(.hidden)
                        }
                    }
                    else {
                        ForEach(Array(viewModel.tracks.enumerated()), id: \.element.id) { index, track in
                            TrackItem(track: track, currentlyPlaying: viewModel.currentTrack?.id == track.id)
                                .listRowSeparator(.hidden)
                                .padding(.bottom, index == viewModel.tracks.count - 1 ? 120 : 0)
                                .onTapGesture {
                                    withAnimation {
                                        viewModel.currentTrack = track
                                        viewModel.playTrack()
                                    }
                                }
                        }
                    }
                }
                .listStyle(.plain)
                .navigationTitle("Play Music")
                .navigationBarTitleDisplayMode(.large)
                .overlay(alignment: .bottom) {
                    if let currentTrack = viewModel.currentTrack {
                        VStack(spacing: 20) {
                            HStack(spacing: 16) {
                                Thumbnail(url: currentTrack.thumbnail, size: 50)
                                
                                VStack(alignment: .leading) {
                                    Text(currentTrack.title)
                                        .fontWeight(.bold)
                                        .truncated()
                                    Text(currentTrack.artist)
                                        .truncated()
                                }
                                
                                Spacer()
                                
                                HStack(spacing: 20) {
                                    Button {
                                        viewModel.playPrevTrack()
                                    } label: {
                                        Image(systemName: "backward.fill").font(.system(size: 20))
                                    }
                                    
                                    Button {
                                        viewModel.isPlaying ? viewModel.pauseTrack() : viewModel.resumeTrack()
                                    } label: {
                                        Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill").font(.system(size: 24))
                                    }
                                    
                                    Button {
                                        viewModel.playNextTrack()
                                    } label: {
                                        Image(systemName: "forward.fill").font(.system(size: 20))
                                    }
                                }
                            }
                            
                            Slider(
                                value: Binding(
                                    get: { viewModel.currentTime },
                                    set: { newValue in
                                        viewModel.currentTime = newValue
                                    }
                                ),
                                in: 0...viewModel.duration,
                                onEditingChanged: { editing in
                                    viewModel.isSliding = editing
                                    
                                    if !editing {
                                        viewModel.seekTo(second: viewModel.currentTime)
                                    }
                                },
                                minimumValueLabel: Text(viewModel.formatTime(viewModel.currentTime)).frame(width: 50, alignment: .leading),
                                maximumValueLabel: Text(viewModel.formatTime(viewModel.duration)).frame(width: 50, alignment: .trailing),
                                label: {
                                    EmptyView()
                                }
                            )
                        }
                        .padding([.horizontal, .top], 20)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .background(.thinMaterial)
                    }
                }
            }
        }
        .onChange(of: viewModel.searchText) {
            viewModel.debouncedFetchTracks()
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("TrackFinished"))) { _ in
            withAnimation {
                let index = (viewModel.getCurrentTrackIndex() + 1) % viewModel.tracks.count
                viewModel.currentTrack = viewModel.tracks[index]
                viewModel.playTrack()
            }
        }
    }
}

#Preview {
    TrackView()
}
