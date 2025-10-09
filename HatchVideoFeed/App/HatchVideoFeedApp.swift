//
//  HatchVideoFeedApp.swift
//  HatchVideoFeed
//
//  Created by Mayuri Patel on 2025-10-07.
//

import SwiftUI

@main
struct HatchVideoFeedApp: App {
    @State private var showFeed = false
    
    var body: some Scene {
        WindowGroup {
            if showFeed {
                VideoFeedContainer()
                    .ignoresSafeArea()
            } else {
                SplashView(showFeed: $showFeed)
            }
        }
    }
}
