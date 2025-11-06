//
//  EnvironmentValues+.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/5/25.
//

import Combine
import SwiftUI

extension EnvironmentValues {
    /// A publisher that publishes ``DebugMenuMessage`` items produced by a ``PostMessageCallback`` in a ``Content`` block.
    ///
    /// ## Usage
    /// Subscribe to this publisher to receive debug menu messages.
    ///
    /// ```swift
    /// @Environment(\.debugMenuMessage) private var debugMenuMessage
    ///
    /// var body: some View {
    ///     ProfileView()
    ///         .onReceive(debugMenuMessage) { message in
    ///             switch message {
    ///                 case .profileDidUpdate:
    ///                     // Do something
    ///                 default:
    ///                     break
    ///             }
    ///         }
    /// }
    /// ```
    ///
    /// - Note: This publisher is canonically equivalent to [`DebugMenuView.messagePublisher`](DebugMenuView/messagePublisher).
    ///
    /// - SeeAlso: ``DebugMenuView/messagePublisher``, ``DebugMenuMessage``, ``DebugMenuView/PostMessageCallback``, ``DebugMenuView/Content``
    public var debugMenuMessage: some Publisher<DebugMenuMessage, Never> {
        NotificationCenter.default.publisher(for: .debugMenuMessage)
            .receive(on: RunLoop.main)
            .compactMap({ $0.userInfo?["message"] as? DebugMenuMessage })
    }
}

extension View {
    /// Add an observer to the view hierarchy to perform an action when a debug menu message is received.
    /// - Parameters:
    ///   - messages: A variadic array of debug menu messages to observe. If left empty, all messages will be observed.
    ///   - action: The action to perform when a message is received.
    /// - Returns: The observing view hierarchy.
    /// - SeeAlso: ``onDebugMenuMessage(_:perform:)``
    public func onDebugMenuMessage(_ messages: DebugMenuMessage..., perform action: @escaping (_ message: DebugMenuMessage) -> Void) -> some View {
        onReceive(\.debugMenuMessage) {
            if messages.isEmpty || messages.contains($0) {
                action($0)
            }
        }
    }
    
    /// Add an observer to the view hierarchy to perform an action when a debug menu message is received.
    /// - Parameters:
    ///   - messages: A variadic array of debug menu messages to observe. If left empty, all messages will be observed.
    ///   - action: The action to perform when a message is received.
    /// - Returns: The observing view hierarchy.
    /// - SeeAlso: ``onDebugMenuMessage(_:perform:)-3qicl``
    public func onDebugMenuMessage(_ messages: DebugMenuMessage..., perform action: @escaping () -> Void) -> some View {
        onReceive(\.debugMenuMessage) {
            if messages.isEmpty || messages.contains($0) {
                action()
            }
        }
    }
}
