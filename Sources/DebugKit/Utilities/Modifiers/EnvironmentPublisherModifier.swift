//
//  EnvironmentPublisherModifier.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/5/25.
//

import Combine
import SwiftUI

struct EnvironmentPublisherModifier<P>: ViewModifier where P: Publisher, P.Failure == Never {
    @Environment private var publisher: P
    private var action: (P.Output) -> Void
    
    init(keyPath: KeyPath<EnvironmentValues, P>, action: @escaping (P.Output) -> Void) {
        self.action = action
        self._publisher = .init(keyPath)
    }
    
    func body(content: Content) -> some View {
        content
            .onReceive(publisher, perform: action)
    }
}

extension View {
    func onReceive<P>(_ keyPath: KeyPath<EnvironmentValues, P>, perform action: @escaping (P.Output) -> Void) -> some View where P: Publisher, P.Failure == Never {
        modifier(EnvironmentPublisherModifier(keyPath: keyPath, action: action))
    }
}
