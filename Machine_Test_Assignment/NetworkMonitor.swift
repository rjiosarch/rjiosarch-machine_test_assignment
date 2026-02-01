//
//  NetworkMonitor.swift
//  Machine_Test_Assignment
//
//  Created by Mr. Raj on 1/2/26.
//

import Network

final class NetworkMonitor {

    static let shared = NetworkMonitor()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    var isConnected = true

    private init() {
        monitor.pathUpdateHandler = { path in
            self.isConnected = path.status == .satisfied
        }
        monitor.start(queue: queue)
    }
}
