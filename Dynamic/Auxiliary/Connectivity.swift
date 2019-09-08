//
//  Connectivity.swift
//  Dynamic Dark Mode
//
//  Created by Apollo Zhu on 5/4/19.
//  Copyright © 2019 Dynamic Dark Mode. All rights reserved.
//

import Network

public final class Connectivity {
    private var monitor: NWPathMonitor!
    private let queue: DispatchQueue
    public init(label: String) {
        self.queue = DispatchQueue(label: label)
    }
    public static let `default` = Connectivity(label: "Connectivity")
    
    private var isObserving = false
    public func startObserving(onSuccess: @escaping () -> Void) {
        stopObserving()
        monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            switch path.status {
            case .satisfied:
                onSuccess()
            case .requiresConnection, .unsatisfied:
                break
            @unknown default:
                remindReportingBug("\(path.status)")
            }
        }
        monitor.start(queue: queue)
        isObserving = true
    }
    
    public func stopObserving() {
        guard isObserving else { return }
        monitor.cancel()
        isObserving = false
    }
}

extension Connectivity {
    public func scheduleWhenReconnected() {
        startObserving {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                Scheduler.shared.schedule()
            }
        }
    }
}
