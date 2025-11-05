//
//  URL+.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/6/25.
//

import Foundation

extension URL {
    static let networkLogs = {
        let dir = URL.cachesDirectory.appendingPathComponent("network_logs", conformingTo: .directory)
        if !FileManager.default.fileExists(atPath: dir.path()) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }()
    
    static let databaseLogs = {
        let dir = URL.cachesDirectory.appendingPathComponent("database_logs", conformingTo: .directory)
        if !FileManager.default.fileExists(atPath: dir.path()) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }()
    
    static let fileSystemLogs = {
        let dir = URL.cachesDirectory.appendingPathComponent("filesystem_logs", conformingTo: .directory)
        if !FileManager.default.fileExists(atPath: dir.path()) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }()
}
