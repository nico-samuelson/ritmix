//
//  HttpService.swift
//  ritmix
//
//  Created by Nico Samuelson on 03/03/25.
//

import Foundation

func fetchITunesData(artist: String,completion: @escaping (Result<[Track], Error>) -> Void) {
    let urlString = "https://itunes.apple.com/search?term=\(artist)&media=music&entity=musicTrack"
    
    guard let url = URL(string: urlString) else {
        print("Invalid URL")
        return
    }
    
    URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            DispatchQueue.main.async {
                completion(.failure(error))
            }
            return
        }
        
        guard let data = data else {
            DispatchQueue.main.async {
                completion(.failure(NSError(domain: "DataError", code: -1, userInfo: nil)))
            }
            return
        }
        
        do {
            // Decode JSON
            let decodedResponse = try JSONDecoder().decode(APIResponse.self, from: data)
            
            let tracks = decodedResponse.results.map { item in
                Track(
                    title: item.trackName ?? "Unknown Title",
                    artist: item.artistName ?? "Unknown Artist",
                    album: item.collectionName ?? "Unknown Album",
                    thumbnail: item.artworkUrl100 ?? "",
                    playURL: item.previewUrl ?? ""
                )
            }
            
            DispatchQueue.main.async {
                completion(.success(tracks))
            }
        } catch {
            DispatchQueue.main.async {
                completion(.failure(error))
            }
        }
    }.resume()
}
