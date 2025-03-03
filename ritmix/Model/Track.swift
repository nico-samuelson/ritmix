//
//  Track.swift
//  mmp
//
//  Created by Nico Samuelson on 03/03/25.
//

import Foundation

struct Track: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String = ""
    var artist: String = ""
    var album: String = ""
    var thumbnail: String = ""
    var playURL: String = ""
}
