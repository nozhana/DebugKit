//
//  FileSystemLog.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/4/25.
//

import Foundation

struct FileSystemLog: Identifiable, Equatable {
    var id = UUID()
    var rootDirectory: FileSystemRootDirectory
    var event: FileSystemEvent
    var difference: CollectionDifference<URL>
    var timestamp: Date = .now
}
