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
    
    init(path: URL? = nil) {
        let path = path ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.path = path
        beginObservation()
    }
    
    func beginObservation() {
        descriptor = open(path.path(), O_EVTONLY)
        self.source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: descriptor, eventMask: .all, queue: queue)
        defer { source.resume() }
        
        source.setEventHandler {
            let event = FileSystemEvent(self.source.data)
            let userInfo = ["event": event, "path": self.path]
            NotificationCenter.default.post(name: .fileSystemDidChange, object: nil, userInfo: userInfo)
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
    
    func stopObservation() {
        source.cancel()
    }
}
