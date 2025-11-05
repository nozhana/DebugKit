//
//  DatabaseLog.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/5/25.
//

import Foundation

struct DatabaseLog: Identifiable, Equatable {
    var id = UUID()
    var event: DatabaseEvent
    var timestamp: Date = .now
}

extension DatabaseLog: CustomStringConvertible {
    var description: String {
        event.description
    }
}
