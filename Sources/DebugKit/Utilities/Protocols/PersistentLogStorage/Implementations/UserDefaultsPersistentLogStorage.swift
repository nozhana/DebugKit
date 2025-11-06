//
//  UserDefaultsPersistentLogStorage.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/6/25.
//

import Combine
import Foundation

final class UserDefaultsPersistentLogStorage<Log>: PersistentLogStorage, ObservableObject, @unchecked Sendable where Log: Codable {
    typealias SerializerType = JSONSerializer<Log>
    
    private let storage: UserDefaults
    private let keyPath: ReferenceWritableKeyPath<UserDefaults, Data?>
    private let idForLog: (Log) -> String
    
    private var cancellables = Set<AnyCancellable>()
    
    @Published private var internalUpdate: Update<Queue<Log>> = .init(initialValue: [])
    
    var updatesPublisher: Published<Update<Queue<Log>>>.Publisher {
        $internalUpdate
    }
    
    init(storage: UserDefaults = .standard, keyPath: ReferenceWritableKeyPath<UserDefaults, Data?>, id: @escaping (Log) -> String) {
        self.storage = storage
        self.keyPath = keyPath
        self.idForLog = id
        setupBindings()
    }
    
    static func ofType(_ logType: Log.Type, storage: UserDefaults = .standard, keyPath: ReferenceWritableKeyPath<UserDefaults, Data?>, id: @escaping (Log) -> String) -> UserDefaultsPersistentLogStorage {
        .init(storage: storage, keyPath: keyPath, id: id)
    }
    
    private func setupBindings() {
        storage.publisher(for: keyPath)
            .receive(on: RunLoop.main)
            .sink { [weak self] data in
                guard let self else { return }
                guard let data else {
                    let update = Update(oldValue: internalUpdate.newValue, newValue: [])
                    DispatchQueue.main.async { [self] in
                        internalUpdate = update
                    }
                    return
                }
                guard let logs = try? JSONDecoder().decode(Queue<Log>.self, from: data) else { return }
                let update = Update(oldValue: internalUpdate.newValue, newValue: logs)
                DispatchQueue.main.async { [self] in
                    internalUpdate = update
                }
            }
            .store(in: &cancellables)
    }
    
    func store(_ log: Log) {
        var logs = internalUpdate.newValue
        logs.push(log)
        guard let data = try? JSONEncoder().encode(logs) else { return }
        storage[keyPath: keyPath] = data
    }
    
    func remove(_ log: Log) {
        var logs = internalUpdate.newValue
        logs.removeAll(where: { idForLog($0) == idForLog(log) })
        guard let data = try? JSONEncoder().encode(logs) else { return }
        storage[keyPath: keyPath] = data
    }
}
