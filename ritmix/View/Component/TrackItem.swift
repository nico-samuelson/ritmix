//
//  TrackItem.swift
//  mmp
//
//  Created by Nico Samuelson on 03/03/25.
//

import SwiftUI

struct TrackItem: View {
    var track: Track
    var variant: String = "big"
    let currentlyPlaying: Bool;
    
    
    var body: some View {
        HStack(spacing: 16) {
            Thumbnail(url: track.thumbnail ?? "", size: variant == "big" ? 70 : 50)
            
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
                if variant == "big" {
                    Text(track.album ?? "")
                        .font(.subheadline)
                        .foregroundStyle(currentlyPlaying ? .accent : .gray)
                        .truncated()
                }
            }
            Spacer()
            
            if currentlyPlaying {
                Image(systemName: "waveform")
                    .symbolEffect(.variableColor.iterative)
                    .foregroundStyle(.accent)
                    .font(.system(size: variant == "big" ? 24 : 16))
            }
        }
        .contentShape(Rectangle())
    }
}
