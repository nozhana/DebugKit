//
//  DatabaseEvent.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/5/25.
//

import Foundation
import SwiftData

enum DatabaseEvent: Equatable, CustomStringConvertible {
    case save(inserted: Set<PersistentIdentifier> = [], updated: Set<PersistentIdentifier> = [], deleted: Set<PersistentIdentifier> = [])
    
    static let save = save()
    
    var title: String {
        switch self {
        case .save: "Save"
        }
    }
    
    var description: String {
        switch self {
        case .save: "Model Context Saved."
        }
    }
    
    var systemImage: String {
        switch self {
        case .save: "arrow.down.circle.dotted"
        }
    }
}
