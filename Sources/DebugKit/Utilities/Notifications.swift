//
//  Notifications.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/5/25.
//

import Foundation

extension Notification.Name {
    public static let debugMenuMessage = Notification.Name("com.nozhana.DebugKit.Notifications.debugMenuMessage")
    
    static let presentDebugMenu = Notification.Name("com.nozhana.DebugKit.Notifications.presentDebugMenu")
    static let presentNetworkLogs = Notification.Name("com.nozhana.DebugKit.Notifications.presentNetworkLogs")
    static let presentNetworkEvents = Notification.Name("com.nozhana.DebugKit.Notifications.presentNetworkEvents")
    static let presentFileSystemLogs = Notification.Name("com.nozhana.DebugKit.Notifications.presentFileSystemLogs")
    static let presentDatabaseLogs = Notification.Name("com.nozhana.DebugKit.Notifications.presentDatabaseLogs")
    static let deviceDidShake = Notification.Name("com.nozhana.DebugKit.Notifications.deviceDidShake")
}
