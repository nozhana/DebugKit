//
//  DebugMenuMessage.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/5/25.
//

import Foundation

public struct DebugMenuMessage: ExpressibleByStringLiteral, Equatable {
    var content: String
    
    init(_ content: some StringProtocol) {
        self.content = String(content)
    }
    
    public init(stringLiteral value: String) {
        self.content = value
    }
}
