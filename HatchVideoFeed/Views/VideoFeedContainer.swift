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
        let vc = VideoFeedViewController()
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        //Add logic to update controller here
    }
    
}
