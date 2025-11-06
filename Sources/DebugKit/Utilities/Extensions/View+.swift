//
//  View+.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/4/25.
//

import SwiftUI

extension View {
    /// Add an observer to the view hierarchy to perform an action when a debug menu message is received.
    /// - Parameters:
    ///   - messages: A variadic array of debug menu messages to observe. If left empty, all messages will be observed.
    ///   - action: The action to perform when a message is received.
    /// - Returns: The observing view hierarchy.
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
    public func onDebugMenuMessage(_ messages: DebugMenuMessage..., perform action: @escaping () -> Void) -> some View {
        onReceive(\.debugMenuMessage) {
            if messages.isEmpty || messages.contains($0) {
                action()
            }
        }
    }
}

extension View {
    @ViewBuilder
    func `if`(_ condition: Bool, @ViewBuilder content: @escaping (Self) -> some View) -> some View {
        if condition {
            content(self)
        } else {
            self
        }
    }
}
