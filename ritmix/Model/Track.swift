//
//  Track.swift
//  mmp
//
//  Created by Nico Samuelson on 03/03/25.
//

import Foundation

struct Track: Codable, Equatable {
    var id: Int?
    let title: String?
    let artist: String?
    let album: String?
    let thumbnail: String?
    let playUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "trackId"
        case title = "trackName"
        case artist = "artistName"
        case album = "collectionName"
        case thumbnail = "artworkUrl100"
        case playUrl = "previewUrl"
    }
    
    static func == (lhs: Track, rhs: Track) -> Bool {
        return lhs.id == rhs.id
    }
}
