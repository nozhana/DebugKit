//
//  MemoryPressureObserver.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/8/25.
//

import Foundation

final class MemoryPressureObserver {
    private let source: DispatchSourceMemoryPressure
    private let queue = DispatchQueue.global(qos: .utility)
    private var eventHandler: EventHandler?
    
    @MainActor
    static let shared = MemoryPressureObserver().beginObservation()
    
    init(eventMask: DispatchSource.MemoryPressureEvent = .all) {
        source = DispatchSource.makeMemoryPressureSource(eventMask: eventMask, queue: queue)
    }
    
    deinit {
        stopObservation()
    }
    
    typealias EventHandler = (_ event: DispatchSource.MemoryPressureEvent) -> Void
    
    @discardableResult
    func onEvent(perform action: @escaping EventHandler) -> Self {
        self.eventHandler = action
        return self
    }
    
    @discardableResult
    func onEvent(perform action: @escaping () -> Void) -> Self {
        self.eventHandler = { _ in action() }
        return self
    }
    
    @discardableResult
    func beginObservation() -> Self {
        defer { source.resume() }
        
        source.setEventHandler {
            NotificationCenter.default.post(name: Self.didReceiveMemoryPressureUpdateNotification, object: nil, userInfo: ["event": self.source.data])
            self.eventHandler?(self.source.data)
        }
        return self
    }
    
    func stopObservation() {
        source.cancel()
    }
}

extension MemoryPressureObserver {
    static let didReceiveMemoryPressureUpdateNotification = Notification.Name("com.nozhana.DebugKit.Notifications.didReceiveMemoryPressureUpdate")
}
