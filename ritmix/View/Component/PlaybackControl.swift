//
//  PlaybackControl.swift
//  ritmix
//
//  Created by Nico Samuelson on 04/03/25.
//

import SwiftUI

struct PlaybackControl: View {
    @Binding var viewModel: TrackViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 16) {
                Thumbnail(url: viewModel.playbackManager.currentTrack?.thumbnail ?? "", size: 50)
                
                VStack(alignment: .leading) {
                    Text(viewModel.playbackManager.currentTrack?.title ?? "")
                        .fontWeight(.bold)
                        .truncated()
                    Text(viewModel.playbackManager.currentTrack?.artist ?? "")
                        .truncated()
                }
                
                Spacer()
                
                HStack(spacing: 20) {
                    Button {
                        viewModel.playbackManager.playPrevTrack()
                    } label: {
                        Image(systemName: "backward.fill").font(.system(size: 20))
                    }
                    
                    Button {
                        viewModel.playbackManager.togglePlayback()
                    } label: {
                        Image(systemName: viewModel.playbackManager.isPlaying ? "pause.fill" : "play.fill").font(.system(size: 24))
                    }
                    
                    Button {
                        viewModel.playbackManager.playNextTrack()
                    } label: {
                        Image(systemName: "forward.fill").font(.system(size: 20))
                    }
                }
            }
            
            Slider(
                value: Binding(
                    get: { viewModel.playbackManager.currentTime },
                    set: { newValue in
                        viewModel.playbackManager.currentTime = newValue
                    }
                ),
                in: 0...viewModel.playbackManager.currentTrackDuration,
                onEditingChanged: { editing in
                    viewModel.playbackManager.isSliding = editing
                    
                    if !editing {
                        viewModel.playbackManager.seekTo(second: viewModel.playbackManager.currentTime)
                    }
                },
                minimumValueLabel: Text(viewModel.formatTime(viewModel.playbackManager.currentTime)).frame(width: 50, alignment: .leading),
                maximumValueLabel: Text(viewModel.formatTime(viewModel.playbackManager.currentTrackDuration)).frame(width: 50, alignment: .trailing),
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
