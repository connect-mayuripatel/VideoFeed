//
//  Manifest.swift
//  HatchVideoFeed
//
//  Created by Mayuri Patel on 2025-10-08.
//

import Foundation

//  Represents the manifest.json file containing the list of video URLs
struct Manifest: Decodable {
    let videos: [URL]
}
