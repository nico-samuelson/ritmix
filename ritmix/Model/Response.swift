//
//  Response.swift
//  ritmix
//
//  Created by Nico Samuelson on 03/03/25.
//

struct APIResponse: Codable {
    let results: [ITunesItem]
}

struct ITunesItem: Codable {
    let trackName: String?
    let artistName: String?
    let collectionName: String?
    let artworkUrl100: String?
    let previewUrl: String?
}
