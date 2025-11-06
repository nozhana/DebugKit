//
//  FSPersistentLogStorage.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/6/25.
//

import Combine
import Foundation

final class FSPersistentLogStorage<Log, SerializerType>: PersistentLogStorage, ObservableObject, @unchecked Sendable where SerializerType: Serializer, SerializerType.Value == Log {
    private let path: URL
    private let urlForLog: (Log) -> URL
    
    @Published private var internalUpdate: Update<Queue<Log>> = .init(initialValue: [])
    
    private let observer: FileSystemObserver
    
    var updatesPublisher: Published<Update<Queue<Log>>>.Publisher {
        $internalUpdate
    }
    
    init(path: URL, url: @escaping (Log) -> URL) {
        self.path = path
        self.urlForLog = url
        self.observer = FileSystemObserver(path: path)
        setupBindings()
        retrieveLogs()
    }
    
    convenience init(path: URL, fileName: @escaping (Log) -> String) {
        self.init(path: path) {
            path.appendingPathComponent(fileName($0), conformingTo: .json)
        }
    }
    
    static func ofType(_ logType: Log.Type, serializer serializerType: SerializerType.Type, path: URL, url: @escaping (Log) -> URL) -> FSPersistentLogStorage {
        .init(path: path, url: url)
    }
    
    static func ofType(_ logType: Log.Type, path: URL, url: @escaping (Log) -> URL) -> FSPersistentLogStorage<Log, JSONSerializer<Log>> where Log: Codable {
        .init(path: path, url: url)
    }
    
    static func ofType(_ logType: Log.Type, serializer serializerType: SerializerType.Type, path: URL, fileName: @escaping (Log) -> String) -> FSPersistentLogStorage {
        .init(path: path, fileName: fileName)
    }
    
    static func ofType(_ logType: Log.Type, path: URL, fileName: @escaping (Log) -> String) -> FSPersistentLogStorage where Log: Codable, SerializerType == JSONSerializer<Log> {
        .init(path: path, fileName: fileName)
    }
    
    private func retrieveLogs(from contents: [URL]? = nil) {
        let contents: [URL] = contents ?? (try? FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: [.creationDateKey])) ?? []
        let logs: Queue<Log> = contents
            .sorted(using: KeyPathComparator(\.creationDate))
            .reduce(into: []) { partialResult, url in
                guard let data = try? Data(contentsOf: url),
                      let log = try? SerializerType.value(from: data) else { return }
                partialResult.push(log)
            }
        DispatchQueue.main.async { [self] in
            internalUpdate = Update(oldValue: internalUpdate.newValue, newValue: logs)
        }
    }
    
    private func setupBindings() {
        observer.onEvent { [weak self] in
            guard let self,
                  let contents = try? FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: [.creationDateKey]) else { return }
            retrieveLogs(from: contents)
        }
    }
    
    func store(_ log: Log) {
        guard let data = try? SerializerType.data(from: log) else { return }
        let url = urlForLog(log)
        try? FileManager.default.removeItem(at: url)
        try? data.write(to: url)
    }
    
    func remove(_ log: Log) {
        let url = urlForLog(log)
        try? FileManager.default.removeItem(at: url)
    }
}
