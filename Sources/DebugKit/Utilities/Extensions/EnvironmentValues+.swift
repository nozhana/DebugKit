//
//  EnvironmentValues+.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/5/25.
//

import Combine
import SwiftUI

extension EnvironmentValues {
    /// A publisher that publishes ``DebugMenuMessage`` items produced by a ``DebugMenuView/PostMessageCallback`` in a ``DebugMenuView/Content`` block.
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
    /// - Note: This publisher is canonically equivalent to ``DebugMenuView/messagePublisher``.
    ///
    /// - SeeAlso: ``DebugMenuView/messagePublisher``, ``DebugMenuMessage``, ``DebugMenuView/PostMessageCallback``, ``DebugMenuView/Content``
    public var debugMenuMessage: some Publisher<DebugMenuMessage, Never> {
        NotificationCenter.default.publisher(for: .debugMenuMessage)
            .receive(on: RunLoop.main)
            .compactMap({ $0.userInfo?["message"] as? DebugMenuMessage })
    }
}
