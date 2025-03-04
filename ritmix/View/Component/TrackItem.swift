//
//  TrackItem.swift
//  mmp
//
//  Created by Nico Samuelson on 03/03/25.
//

import SwiftUI

struct TrackItem: View {
    var track: Track
    let currentlyPlaying: Bool;
    
    var body: some View {
        HStack(spacing: 16) {
            Thumbnail(url: track.thumbnail ?? "")
            
            VStack(alignment: .leading, spacing: 4) {
                Text(track.title ?? "")
                    .fontWeight(.bold)
                    .font(.headline)
                    .foregroundStyle(currentlyPlaying ? .accent : .primary)
                    .truncated()
                Text(track.artist ?? "")
                    .fontWeight(.medium)
                    .font(.subheadline)
                    .foregroundStyle(currentlyPlaying ? .accent : .primary)
                    .truncated()
                Text(track.album ?? "")
                    .font(.subheadline)
                    .foregroundStyle(currentlyPlaying ? .accent : .gray)
                    .truncated()
            }
            Spacer()
            
            if currentlyPlaying {
                Image(systemName: "waveform")
                    .symbolEffect(.variableColor.iterative)
                    .foregroundStyle(.accent)
                    .font(.system(size: 24))
            }
        }
        .contentShape(Rectangle())
    }
}
