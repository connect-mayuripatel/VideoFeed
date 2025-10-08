//
//  VideoFeedContainer.swift
//  HatchVideoFeed
//
//  Created by Mayuri Patel on 2025-10-07.
//

import SwiftUI
import UIKit

struct VideoFeedContainer: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> some UIViewController {
        return VideoFeedViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        //Add logic to update controller here
    }
}
