//
//  TrackView.swift
//  mmp
//
//  Created by Nico Samuelson on 03/03/25.
//

import SwiftUI

struct TrackView: View {
    @State private var viewModel = TrackViewModel()
    @State private var showQueue: Bool = false
    @FocusState private var isFocused: Bool
    
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
                            .focused($isFocused)
                        
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
                            TrackItem(
                                track: track,
                                currentlyPlaying: viewModel.playbackManager.currentTrack?.id == track.id
                            )
                            .listRowSeparator(.hidden)
                            .padding(.bottom, index == viewModel.playbackManager.tracks.count - 1 ? 120 : 0)
                            .onTapGesture {
                                withAnimation {
                                    isFocused = false
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
                            .onTapGesture {
                                showQueue = true
                                isFocused = false
                            }
                            .sheet(isPresented: $showQueue) {
                                VStack(alignment: .leading) {
                                    Text("Queue")
                                        .fontWeight(.bold)
                                        .font(.title3)
                                        .padding(.leading, 16)
                                    List {
                                        ForEach(Array(Array(viewModel.playbackManager.queue[viewModel.playbackManager.getCurrentTrackIndex()...]).enumerated()), id: \.element.id) { index, track in
                                            TrackItem(
                                                track: track,
                                                variant: "small",
                                                currentlyPlaying: viewModel.playbackManager.currentTrack?.id == track.id
                                            )
                                            .listRowSeparator(.hidden)
                                            .onTapGesture {
                                                withAnimation {
                                                    viewModel.playbackManager.currentTrack = track
                                                    viewModel.playbackManager.playTrack()
                                                }
                                            }
                                            .swipeActions(edge: .trailing) {
                                                Button(role: .destructive) {
                                                    withAnimation {
                                                        viewModel.playbackManager.removeFromQueue(track: track)
                                                    }
                                                } label: {
                                                    Label("Remove", systemImage: "trash")
                                                }
                                            }
                                        }
                                    }
                                    HStack {
                                        
                                        Button {
                                            viewModel.playbackManager.toggleShuffle()
                                        } label : {
                                            VStack {
                                                Image(systemName: "shuffle")
                                                    .foregroundStyle(viewModel.playbackManager.isShuffled ? .accent : .primary)
                                                Text("Shuffle")
                                                    .foregroundStyle(viewModel.playbackManager.isShuffled ? .accent : .primary)
                                            }
                                        }
                                        .buttonStyle(.bordered)
                                        .controlSize(.extraLarge)
                                        .buttonBorderShape(.roundedRectangle)
                                        
                                        
                                        Button {
                                            viewModel.playbackManager.isRepeat.toggle()
                                        } label : {
                                            VStack {
                                                Image(systemName: "repeat")
                                                    .foregroundStyle(viewModel.playbackManager.isRepeat ? .accent : .primary)
                                                Text("Repeat")
                                                    .foregroundStyle(viewModel.playbackManager.isRepeat ? .accent : .primary)
                                            }
                                        }
                                        .buttonStyle(.bordered)
                                        .controlSize(.extraLarge)
                                        .buttonBorderShape(.roundedRectangle)
                                        
                                    }
                                    .frame(width: gr.size.width)
                                    .padding([.top], 20)
                                    .background(Color.bg)
                                }
                                .padding([.top], 20)
                                .listStyle(.plain)
                                .presentationDetents([.medium, .large])
                            }
                    }
                }
                .simultaneousGesture(
                    // Hide keyboard on scroll
                    DragGesture().onChanged { _ in
                        isFocused = false
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                )
            }
        }
        .onChange(of: viewModel.searchText) {
            viewModel.debouncedFetchTracks()
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("TrackFinished"))) { _ in
            withAnimation {
                if viewModel.playbackManager.isRepeat {
                    viewModel.playbackManager.seekTo(second: 0)
                }
                else {
                    let index = (viewModel.playbackManager.getCurrentTrackIndex() + 1) % viewModel.playbackManager.tracks.count
                    viewModel.playbackManager.currentTrack = viewModel.playbackManager.tracks[index]
                    viewModel.playbackManager.playTrack()
                }
            }
        }
    }
}

#Preview {
    TrackView()
}
