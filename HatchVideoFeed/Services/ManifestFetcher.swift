//
//  ManifestFetcher.swift
//  HatchVideoFeed
//
//  Created by Mayuri Patel on 2025-10-08.
//

import Foundation

final class ManifestFetcher {
    static let shared = ManifestFetcher()
    private init() {}
    
    private let manifestURL = URL(string: "https://cdn.dev.airxp.app/AgentVideos-HLS-Progressive/manifest.json")!
    
    func fetchManifest(completion: @escaping ([VideoItem]) -> Void) {
        URLSession.shared.dataTask(with: manifestURL) { data, _, error in
            guard let data = data, error == nil else {
                print("Error fetching manifest:", error ?? "")
                completion([])
                return
            }
            do {
                let manifest = try JSONDecoder().decode(Manifest.self, from: data)
                let items = manifest.videos.map { VideoItem(url: $0) }
                completion(items)
            } catch {
                print("Error decoding manifest:", error)
                completion([])
            }
        }.resume()
    }
}
