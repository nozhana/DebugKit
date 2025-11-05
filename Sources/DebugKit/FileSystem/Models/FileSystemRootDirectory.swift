//
//  FileSystemRootDirectory.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/5/25.
//

import Foundation

enum FileSystemRootDirectory: RawRepresentable, CaseIterable, Codable {
    case documents
    case caches
    case temporary
#if os(macOS)
    case downloads
    case desktop
    case movies
    case music
    case pictures
#endif
    
    var rawValue: URL {
        switch self {
        case .documents: .documentsDirectory
        case .caches: .cachesDirectory
        case .temporary: .temporaryDirectory
#if os(macOS)
        case .downloads: .downloadsDirectory
        case .desktop: .desktopDirectory
        case .movies: .moviesDirectory
        case .music: .musicDirectory
        case .pictures: .picturesDirectory
#endif
        }
    }
    
    init?(rawValue: URL) {
        switch rawValue {
        case .documentsDirectory: self = .documents
        case .cachesDirectory: self = .caches
        case .temporaryDirectory: self = .temporary
#if os(macOS)
        case .downloadsDirectory: self = .downloads
        case .desktopDirectory: self = .desktop
        case .moviesDirectory: self = .movies
        case .musicDirectory: self = .music
        case .picturesDirectory: self = .pictures
#endif
        default: return nil
        }
    }
    
    var title: String {
        switch self {
        case .documents: "Documents"
        case .caches: "Caches"
        case .temporary: "Temporary"
#if os(macOS)
        case .downloads: "Downloads"
        case .desktop: "Desktop"
        case .movies: "Movies"
        case .music: "Music"
        case .pictures: "Pictures"
#endif
        }
    }
    
    var systemImage: String {
        switch self {
        case .documents: "folder"
        case .caches: "square.on.square"
        case .temporary: "square.dashed"
#if os(macOS)
        case .downloads: "square.and.arrow.down"
        case .desktop: "desktopcomputer"
        case .movies: "movieclapper"
        case .music: "music.note"
        case .pictures: "photo"
#endif
        }
    }
}
