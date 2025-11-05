//
//  FileSystemEvent.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/4/25.
//

import Foundation

enum FileSystemEvent: RawRepresentable, Equatable, Identifiable, CustomStringConvertible, Codable {
    case delete, write, extend, attrib, link, rename, revoke, funlock, unknown(UInt)
    
    init(rawValue: UInt) {
        switch rawValue {
        case DispatchSource.FileSystemEvent.delete.rawValue: self = .delete
        case DispatchSource.FileSystemEvent.write.rawValue: self = .write
        case DispatchSource.FileSystemEvent.extend.rawValue: self = .extend
        case DispatchSource.FileSystemEvent.attrib.rawValue: self = .attrib
        case DispatchSource.FileSystemEvent.link.rawValue: self = .link
        case DispatchSource.FileSystemEvent.rename.rawValue: self = .rename
        case DispatchSource.FileSystemEvent.revoke.rawValue: self = .revoke
        case DispatchSource.FileSystemEvent.funlock.rawValue: self = .funlock
        default:
            let events = DispatchSource.FileSystemEvent(rawValue: rawValue)
            if events.contains(.delete) { self = .delete }
            else if events.contains(.write) { self = .write }
            else if events.contains(.extend) { self = .extend }
            else if events.contains(.attrib) { self = .attrib }
            else if events.contains(.link) { self = .link }
            else if events.contains(.rename) { self = .rename }
            else if events.contains(.revoke) { self = .revoke }
            else if events.contains(.funlock) { self = .funlock }
            else { self = .unknown(rawValue) }
        }
    }
    
    init(_ event: DispatchSource.FileSystemEvent) {
        self.init(rawValue: event.rawValue)
    }
    
    var rawValue: UInt {
        switch self {
        case .delete: DispatchSource.FileSystemEvent.delete.rawValue
        case .write: DispatchSource.FileSystemEvent.write.rawValue
        case .extend: DispatchSource.FileSystemEvent.extend.rawValue
        case .attrib: DispatchSource.FileSystemEvent.attrib.rawValue
        case .link: DispatchSource.FileSystemEvent.link.rawValue
        case .rename: DispatchSource.FileSystemEvent.rename.rawValue
        case .revoke: DispatchSource.FileSystemEvent.revoke.rawValue
        case .funlock: DispatchSource.FileSystemEvent.funlock.rawValue
        case .unknown(let value): value
        }
    }
    
    var id: UInt { rawValue }
    
    var description: String {
        switch self {
        case .delete: "Delete"
        case .write: "Write"
        case .extend: "Extend"
        case .attrib: "Attrib"
        case .link: "Link"
        case .rename: "Rename"
        case .revoke: "Revoke"
        case .funlock: "F-Unlock"
        case .unknown(let value): "Unknown (\(value))"
        }
    }
    
    var systemImage: String {
        switch self {
        case .delete: "trash"
        case .write: "pencil"
        case .extend: "puzzlepiece.extension"
        case .attrib: "chevron.left.slash.chevron.right"
        case .link: "link"
        case .rename: "pencil.line"
        case .revoke: "lock"
        case .funlock: "lock.open"
        case .unknown: "questionmark.circle.dashed"
        }
    }
}
