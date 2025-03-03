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
                        TrackItem(track: track, currentPlaying: $viewModel.currentlyPlaying)
                            .listRowSeparator(.hidden)
                            .padding(.bottom, index == viewModel.tracks.count - 1 ? 120 : 0)
                    }
                }
                .listStyle(.plain)
                .navigationTitle("Play Music")
                .navigationBarTitleDisplayMode(.large)
                .overlay(alignment: .bottom) {
                    if let currentlyPlaying = viewModel.currentlyPlaying {
                        VStack {
                            HStack() {
                                Thumbnail(url: currentlyPlaying.thumbnail, size: 50)
                                
                                VStack(alignment: .leading) {
                                    Text(currentlyPlaying.title)
                                        .fontWeight(.bold)
                                        .truncated()
                                    Text(currentlyPlaying.artist)
                                        .truncated()
                                }
                                
                                Spacer()
                                
                                HStack(spacing: 20) {
                                    Button {
                                        
                                    } label: {
                                        Image(systemName: "backward.fill").font(.system(size: 20))
                                    }
                                    
                                    Button {
                                        
                                    } label: {
                                        Image(systemName: "play.fill").font(.system(size: 20))
                                    }
                                    
                                    Button {
                                        
                                    } label: {
                                        Image(systemName: "forward.fill").font(.system(size: 20))
                                    }
                                }
                            }
                            
                            Slider(
                                value: $viewModel.playback,
                                in: 0...30,
                                step: 1,
                                minimumValueLabel: Text("0:00"),
                                maximumValueLabel: Text("0:30"),
                                label: {
                                    EmptyView()
                                }
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .background(.ultraThinMaterial)
                    }
                }
            }
        }
        .searchable(text: $viewModel.searchText, prompt: "Search Artist...")
        .onAppear {
            self.viewModel.currentlyPlaying = self.viewModel.tracks[0]
        }
    }
}

#Preview {
    TrackView()
}
