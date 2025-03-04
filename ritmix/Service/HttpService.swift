//
//  HttpService.swift
//  ritmix
//
//  Created by Nico Samuelson on 03/03/25.
//

import Foundation

class HttpService {
    func callAPI<T: Decodable>(urlString: String, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            logger.error("Bad URL")
            completion(.failure(URLError(.badURL)))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    logger.error("\(error.localizedDescription)")
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
                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                
                DispatchQueue.main.async {
                    completion(.success(decodedResponse))
                }
            } catch {
                DispatchQueue.main.async {
                    logger.error("\(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    func fetchTracksData(artist: String, completion: @escaping (Result<[Track], Error>) -> Void) {
        let urlString = "https://itunes.apple.com/search?term=\(artist)&media=music&entity=musicTrack"
        
        self.callAPI(urlString: urlString) { (result: Result<iTunesResponse, Error>) in
            switch result {
            case .success(let response):
                completion(.success(response.results))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
