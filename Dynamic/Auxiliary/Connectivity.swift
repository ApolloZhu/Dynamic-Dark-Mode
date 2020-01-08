//
//  Connectivity.swift
//  Dynamic Dark Mode
//
//  Created by Apollo Zhu on 5/4/19.
//  Copyright © 2018-2020 Dynamic Dark Mode. All rights reserved.
//

import Network
import Schedule

public final class Connectivity {
    private var monitor: NWPathMonitor!
    private let queue: DispatchQueue
    public init(label: String) {
        self.queue = DispatchQueue(label: label)
    }
    public static let `default` = Connectivity(label: "Connectivity")
    
    private var isObserving = false
    private var isInitialUpdate = true
    public func startObserving(onSuccess: @escaping () -> Void) {
        stopObserving()
        monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            guard !self.isInitialUpdate else {
                self.isInitialUpdate = false
                return
            }
            switch path.status {
            case .satisfied:
                if path.isExpensive { return }
                if #available(macOS 10.15, *), path.isConstrained { return }
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
        isInitialUpdate = true
        monitor.cancel()
        isObserving = false
        task = nil
    }
    
    private var task: Task?
    public func scheduleWhenReconnected() {
        startObserving { [weak self] in
            self?.task = Plan.after(5.seconds).do(queue: .main) {
                Scheduler.shared.schedule()
            }
        }
    }
}
