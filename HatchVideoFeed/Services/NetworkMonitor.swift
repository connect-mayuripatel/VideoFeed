//
//  NetworkMonitor.swift
//  HatchVideoFeed
//
//  Created by Mayuri Patel on 2025-10-08.
//

import Network
import UIKit

extension Notification.Name {
    static let NetworkBecameAvailable = Notification.Name("NetworkBecameAvailable")
}

class NetworkMonitor {
    static let shared = NetworkMonitor()
    private let monitor = NWPathMonitor()
    var isFastNetwork: Bool = true

    private init() {
        monitor.pathUpdateHandler = { path in
            self.isFastNetwork = path.status == .satisfied && path.isExpensive == false

            // Post notification when network becomes available
            if path.status == .satisfied {
                NotificationCenter.default.post(name: .NetworkBecameAvailable, object: nil)
            }
        }
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }
}
