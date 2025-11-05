//
//  FileSystemLogManager.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/4/25.
//

import Combine
import Foundation

@Observable
final class FileSystemLogManager {
    @ObservationIgnored
    private var cancellables = Set<AnyCancellable>()
    
    @ObservationIgnored
    private let observers: [FileSystemRootDirectory: FileSystemObserver] = Dictionary(uniqueKeysWithValues: FileSystemRootDirectory.allCases.map { ($0, FileSystemObserver(path: $0.rawValue)) })
    
    @ObservationIgnored
    private var contents: [FileSystemRootDirectory: [URL]] = Dictionary(uniqueKeysWithValues: FileSystemRootDirectory.allCases.map { ($0, try! FileManager.default.contentsOfDirectory(at: $0.rawValue, includingPropertiesForKeys: nil)) })
    
    @ObservationIgnored
    private let persistentLogsObserver = FileSystemObserver(path: .fileSystemLogs)
    
    var logs = Queue<FileSystemLog>(capacity: 50)
    
    private(set) var persistedLogs = Queue<FileSystemLog>()
    
    @MainActor
    @ObservationIgnored
    static let shared = FileSystemLogManager()
    
    private init() {
        setupBindings()
        retrievePersistedLogs()
    }
    
    func persist(_ log: FileSystemLog) {
        guard let data = try? JSONEncoder().encode(log) else { return }
        let url = URL.fileSystemLogs.appendingPathComponent(log.id.uuidString, conformingTo: .json)
        try? data.write(to: url)
    }
    
    func removePersistedLog(_ log: FileSystemLog) {
        let url = URL.fileSystemLogs.appendingPathComponent(log.id.uuidString, conformingTo: .json)
        try? FileManager.default.removeItem(at: url)
    }
    
    private func retrievePersistedLogs() {
        guard let contents = try? FileManager.default.contentsOfDirectory(at: .fileSystemLogs, includingPropertiesForKeys: nil) else { return }
        persistedLogs = contents.reduce(into: []) { partialResult, url in
            guard let data = try? Data(contentsOf: url),
                  let log = try? JSONDecoder().decode(FileSystemLog.self, from: data) else { return }
            partialResult.push(log)
        }
    }
    
    private func setupBindings() {
        persistentLogsObserver.onEvent(perform: retrievePersistedLogs)
        
        NotificationCenter.default.publisher(for: .fileSystemDidChange)
            .receive(on: RunLoop.main)
            .sink { [weak self] notification in
                guard let self,
                      let userInfo = notification.userInfo as? [String: Any],
                      let event = userInfo["event"] as? FileSystemEvent,
                      let path = userInfo["path"] as? URL,
                      let rootDirectory = FileSystemRootDirectory(rawValue: path) else { return }
                let contents = try! FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil)
                let difference = contents.difference(from: self.contents[rootDirectory] ?? []).inferringMoves()
                let log = FileSystemLog(rootDirectory: rootDirectory, event: event, difference: difference)
                logs.push(log)
                self.contents[rootDirectory] = contents
            }
            .store(in: &cancellables)
    }
}
