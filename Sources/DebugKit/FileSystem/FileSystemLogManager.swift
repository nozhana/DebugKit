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
    private let storage = FSPersistentLogStorage
        .ofType(FileSystemLog.self, path: .fileSystemLogs, fileName: \.id.uuidString)
    
    var logs = Queue<FileSystemLog>(capacity: 50)
    
    private(set) var persistedLogs = Queue<FileSystemLog>()
    
    @MainActor
    @ObservationIgnored
    static let shared = FileSystemLogManager()
    
    private init() {
        setupBindings()
    }
    
    func persist(_ log: FileSystemLog) {
        storage.store(log)
    }
    
    func removePersistedLog(_ log: FileSystemLog) {
        storage.store(log)
    }
    
    private func setupBindings() {
        storage.updatesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] update in
                guard let self else { return }
                persistedLogs = update.newValue
            }
            .store(in: &cancellables)
        
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
                guard !difference.isEmpty else { return }
                let log = FileSystemLog(rootDirectory: rootDirectory, event: event, difference: difference)
                logs.push(log)
                self.contents[rootDirectory] = contents
            }
            .store(in: &cancellables)
    }
}

extension UserDefaults {
    private var fileSystemLogsDataKey: String {
        "com.nozhana.DebugKit.UserDefaults.fileSystemLogsData"
    }
    
    @objc dynamic var fileSystemLogsData: Data? {
        get { data(forKey: fileSystemLogsDataKey) }
        set { set(newValue, forKey: fileSystemLogsDataKey) }
    }
}

