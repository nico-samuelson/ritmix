//
//  TrackItem.swift
//  mmp
//
//  Created by Nico Samuelson on 03/03/25.
//

import SwiftUI

struct TrackItem: View {
    var track: Track
    @Binding var currentPlaying: Track?
    
    var body: some View {
        HStack(spacing: 16) {
            Thumbnail(url: track.thumbnail)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(track.title)
                    .fontWeight(.bold)
                    .font(.headline)
                    .foregroundStyle(currentPlaying?.id == track.id ? .accent : .primary)
                    .truncated()
                Text(track.artist)
                    .fontWeight(.medium)
                    .font(.subheadline)
                    .foregroundStyle(currentPlaying?.id == track.id ? .accent : .primary)
                    .truncated()
                Text(track.album)
                    .font(.subheadline)
                    .foregroundStyle(currentPlaying?.id == track.id ? .accent : .gray)
                    .truncated()
            }
            Spacer()
            
            if currentPlaying?.id == track.id {
                Image(systemName: "waveform")
                    .symbolEffect(.variableColor.iterative.reversing, options: .repeat(.continuous))
                    .foregroundStyle(.accent)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            currentPlaying = track
        }
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
        currentPlaying: .constant(Track(
            title: "Lonely",
            artist: "Justin Bieber",
            album: "Justice",
            thumbnail: "https://is1-ssl.mzstatic.com/image/thumb/Music124/v4/f5/7a/9e/f57a9e6a-31c8-0784-dfbd-4a0120bfd4af/21UMGIM17517.rgb.jpg/100x100bb.jpg",
            playURL: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview122/v4/a7/32/0a/a7320af8-ddc6-f7ef-4812-8a3877cfd780/mzaf_12836494553105178407.plus.aac.p.m4a"
        ))
    )
}
