//
//  Update.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/6/25.
//

import Foundation

struct Update<Value> {
    var oldValue: Value
    var newValue: Value
    var timestamp: Date = .now
}

extension Update {
    init(initialValue: Value, timestamp: Date = .now) {
        self.oldValue = initialValue
        self.newValue = initialValue
        self.timestamp = timestamp
    }
}

extension Update where Value: BidirectionalCollection, Value.Element: Equatable {
    var difference: CollectionDifference<Value.Element> {
        newValue.difference(from: oldValue)
    }
}
