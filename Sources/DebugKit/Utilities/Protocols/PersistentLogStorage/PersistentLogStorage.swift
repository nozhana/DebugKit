//
//  PersistentLogStorage.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/6/25.
//

import Combine
import Foundation

protocol PersistentLogStorage {
    associatedtype Log
    associatedtype Publisher: Combine.Publisher<Update<Queue<Log>>, Never>
    associatedtype SerializerType: Serializer where SerializerType.Value == Log
    func store(_ log: Log)
    func remove(_ log: Log)
    var updatesPublisher: Publisher { get }
}

extension PersistentLogStorage {
    var updates: AsyncPublisher<Publisher> {
        updatesPublisher.values
    }
}
