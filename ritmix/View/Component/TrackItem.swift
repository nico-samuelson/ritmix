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
            Thumbnail(url: track.thumbnail)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(track.title)
                    .fontWeight(.bold)
                    .font(.headline)
                    .foregroundStyle(currentlyPlaying ? .accent : .primary)
                    .truncated()
                Text(track.artist)
                    .fontWeight(.medium)
                    .font(.subheadline)
                    .foregroundStyle(currentlyPlaying ? .accent : .primary)
                    .truncated()
                Text(track.album)
                    .font(.subheadline)
                    .foregroundStyle(currentlyPlaying ? .accent : .gray)
                    .truncated()
            }
            Spacer()
            
            if currentlyPlaying {
                Image(systemName: "waveform")
                    .symbolEffect(.variableColor.iterative, options: .repeat(.continuous))
                    .foregroundStyle(.accent)
            }
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    TrackItem(
        track: Track(
            title: "Lonely",
            artist: "Justin Bieber",
            album: "Justice",
            thumbnail: "https://is1-ssl.mzstatic.com/image/thumb/Music124/v4/f5/7a/9e/f57a9e6a-31c8-0784-dfbd-4a0120bfd4af/21UMGIM17517.rgb.jpg/100x100bb.jpg",
            playURL: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview122/v4/a7/32/0a/a7320af8-ddc6-f7ef-4812-8a3877cfd780/mzaf_12836494553105178407.plus.aac.p.m4a"
        ),
        currentlyPlaying: true
    )
}
