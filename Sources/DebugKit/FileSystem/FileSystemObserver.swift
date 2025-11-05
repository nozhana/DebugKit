//
//  FileSystemObserver.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/4/25.
//

import Foundation

final class FileSystemObserver {
    private let path: URL
    private let fileManager = FileManager.default
    private let queue = DispatchQueue(label: "com.nozhana.DebugKit.FileSystemObserver", qos: .utility)
    private var source: DispatchSourceFileSystemObject!
    private var descriptor: Int32 = 0
    
    typealias EventHandler = (_ event: FileSystemEvent) -> Void
    private var eventHandler: EventHandler?
    
    init(path: URL? = nil) {
        let path = path ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.path = path
        beginObservation()
    }
    
    deinit {
        stopObservation()
    }
    
    @discardableResult
    func onEvent(perform action: @escaping EventHandler) -> Self {
        eventHandler = action
        return self
    }
    
    @discardableResult
    func onEvent(perform action: @escaping () -> Void) -> Self {
        eventHandler = { _ in action() }
        return self
    }
    
    private func beginObservation() {
        descriptor = open(path.path(), O_EVTONLY)
        self.source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: descriptor, eventMask: .all, queue: queue)
        defer { source.resume() }
        
        source.setEventHandler {
            let event = FileSystemEvent(self.source.data)
            let userInfo = ["event": event, "path": self.path]
            NotificationCenter.default.post(name: .fileSystemDidChange, object: nil, userInfo: userInfo)
            self.eventHandler?(event)
            switch event {
            case .delete, .rename:
                self.stopObservation()
            default:
                break
            }
        }
        
        source.setCancelHandler {
            close(self.descriptor)
            self.descriptor = 0
            let event = self.source.data
            self.source = nil
            switch event {
            case .delete, .rename:
                self.beginObservation()
            default:
                break
            }
        }
    }
    
    private func stopObservation() {
        source?.cancel()
    }
}
