//
//  HatchVideoFeedApp.swift
//  HatchVideoFeed
//
//  Created by Mayuri Patel on 2025-10-07.
//

import SwiftUI

@main
struct HatchVideoFeedApp: App {
    var body: some Scene {
        WindowGroup {
            VideoFeedContainer()
                .edgesIgnoringSafeArea(.all)
        }
    }
}
