//
//  VideoPlayerManager.swift
//  HatchVideoFeed
//
//  Created by Mayuri Patel on 2025-10-08.
//

import Foundation
import AVFoundation

class VideoPlayerManager {
    static let shared = VideoPlayerManager()
    
    private var players: [URL: AVPlayer] = [:]
    
    func player(for url: URL) -> AVPlayer {
        if let existing = players[url] {
            return existing
        }
        
        let newPlayer = AVPlayer(url: url)
        newPlayer.actionAtItemEnd = .none
        
        // Loop video automatically
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                               object: newPlayer.currentItem,
                                               queue: .main) { _ in
            newPlayer.seek(to: .zero)
            newPlayer.play()
        }
        
        players[url] = newPlayer
        return newPlayer
    }
    
    func releasePlayer(for url: URL) {
        if let player = players[url] {
            player.pause()
            players.removeValue(forKey: url)
        }
    }
}
