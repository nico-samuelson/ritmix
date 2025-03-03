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
                    ForEach(Array(viewModel.tracks.filter {
                        viewModel.searchText.isEmpty || $0.title.lowercased().contains(viewModel.searchText.lowercased())
                    }.enumerated()), id: \.element.id) { index, track in
                        TrackItem(track: track, currentlyPlaying: viewModel.currentTrack?.id == track.id)
                            .listRowSeparator(.hidden)
                            .padding(.bottom, index == viewModel.tracks.count - 1 ? 120 : 0)
                            .onTapGesture {
                                withAnimation {
                                    viewModel.currentIndex = index
                                    viewModel.playTrack()
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
        .searchable(text: $viewModel.searchText, prompt: "Search Artist...")
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("TrackFinished"))) { _ in
            withAnimation {
                viewModel.currentIndex = (viewModel.currentIndex + 1) % viewModel.tracks.count
                viewModel.playTrack()
            }
        }
    }
}

#Preview {
    TrackView()
}
