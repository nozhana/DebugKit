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
    private let storage = FSPersistentLogStorage
        .ofType(DatabaseLog.self, path: .databaseLogs, fileName: \.id.uuidString)
    
    var logs = Queue<DatabaseLog>(capacity: 50)
    private(set) var persistedLogs = Queue<DatabaseLog>()
    
    @MainActor
    @ObservationIgnored
    static let shared = DatabaseLogManager()
    
    private init() {
        setupBindings()
    }
    
    func persist(_ log: DatabaseLog) {
        storage.store(log)
    }
    
    func removePersistedLog(_ log: DatabaseLog) {
        storage.remove(log)
    }
    
    private func setupBindings() {
        storage.updatesPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] update in
                guard let self else { return }
                persistedLogs = update.newValue
            }
            .store(in: &cancellables)
        
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

extension UserDefaults {
    private var databaseLogsDataKey: String {
        "com.nozhana.DebugKit.UserDefaults.databaseLogsData"
    }
    
    @objc dynamic var databaseLogsData: Data? {
        get { data(forKey: databaseLogsDataKey) }
        set { set(newValue, forKey: databaseLogsDataKey) }
    }
}
