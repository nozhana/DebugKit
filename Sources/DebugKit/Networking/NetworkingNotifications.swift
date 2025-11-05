//
//  NetworkingNotifications.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/4/25.
//

import Foundation

extension Notification.Name {
    static let networkTaskStarted = Notification.Name("com.nozhana.DebugKit.Notifications.networkTaskStarted")
    static let networkTaskFinished = Notification.Name("com.nozhana.DebugKit.Notifications.networkTaskFinished")
    static let networkTaskDidReceiveResponse = Notification.Name("com.nozhana.DebugKit.Notifications.networkTaskDidReceiveResponse")
    static let networkTaskDidLoadData = Notification.Name("com.nozhana.DebugKit.Notifications.networkTaskDidLoadData")
}
