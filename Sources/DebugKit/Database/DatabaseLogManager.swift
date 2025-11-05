//
//  DatabaseLogManager.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/5/25.
//

import Combine
import Foundation
import SwiftData

@Observable
final class DatabaseLogManager {
    @ObservationIgnored
    private var cancellables = Set<AnyCancellable>()
    
    @ObservationIgnored
    private let persistentLogsObserver = FileSystemObserver(path: .databaseLogs)
    
    var logs = Queue<DatabaseLog>(capacity: 50)
    private(set) var persistedLogs = Queue<DatabaseLog>()
    
    @MainActor
    @ObservationIgnored
    static let shared = DatabaseLogManager()
    
    private init() {
        setupBindings()
        retrievePersistedLogs()
    }
    
    func persist(_ log: DatabaseLog) {
        guard let data = try? JSONEncoder().encode(log) else { return }
        let url = URL.databaseLogs.appendingPathComponent(log.id.uuidString, conformingTo: .json)
        try? data.write(to: url)
    }
    
    func removePersistedLog(_ log: DatabaseLog) {
        let url = URL.databaseLogs.appendingPathComponent(log.id.uuidString, conformingTo: .json)
        try? FileManager.default.removeItem(at: url)
    }
    
    private func retrievePersistedLogs() {
        guard let contents = try? FileManager.default.contentsOfDirectory(at: .databaseLogs, includingPropertiesForKeys: [.creationDateKey]) else { return }
        persistedLogs = contents
            .sorted(using: KeyPathComparator(\.creationDate))
            .reduce(into: []) { partialResult, url in
                guard let data = try? Data(contentsOf: url),
                      let log = try? JSONDecoder().decode(DatabaseLog.self, from: data) else { return }
                partialResult.push(log)
            }
    }
    
    private func setupBindings() {
        persistentLogsObserver.onEvent(perform: retrievePersistedLogs)
        
        NotificationCenter.default.publisher(for: ModelContext.didSave)
            .receive(on: RunLoop.main)
            .sink { [weak self] notification in
                var inserted = Set<PersistentIdentifier>()
                var updated = Set<PersistentIdentifier>()
                var deleted = Set<PersistentIdentifier>()
                
                if let userInfo = notification.userInfo as? [String: [PersistentIdentifier]] {
                    inserted = Set(userInfo["inserted"] ?? [])
                    updated = Set(userInfo["updated"] ?? [])
                    deleted = Set(userInfo["deleted"] ?? [])
                }
                
                let log = DatabaseLog(event: .save(inserted: inserted, updated: updated, deleted: deleted))
                self?.logs.push(log)
            }
            .store(in: &cancellables)
    }
}
