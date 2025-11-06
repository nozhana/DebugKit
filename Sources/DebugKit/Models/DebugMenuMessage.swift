//
//  DebugMenuMessage.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/5/25.
//

import Foundation

/// A message published from inside the customized debug menu content view.
///
/// - SeeAlso: Register custom debug menu content: ``DebugMenuView/registerContent(_:)-fdls``
public struct DebugMenuMessage: ExpressibleByStringLiteral, Equatable {
    /// The string content of the message.
    var content: String
    
    /// Initialize a ``DebugMenuMessage`` instance.
    /// - Parameter content: A value conforming to `StringProtocol`.
    public init(_ content: some StringProtocol) {
        self.content = String(content)
    }
    
    /// Initialize a ``DebugMenuMessage`` with a string literal.
    /// - Parameter value: The content of the debug message as a string literal.
    public init(stringLiteral value: String) {
        self.content = value
    }
}
