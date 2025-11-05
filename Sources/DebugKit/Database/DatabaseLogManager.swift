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
    
    var logs = Queue<DatabaseLog>(capacity: 50)
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
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
