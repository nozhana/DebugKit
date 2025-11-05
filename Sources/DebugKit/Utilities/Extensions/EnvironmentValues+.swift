//
//  EnvironmentValues+.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/5/25.
//

import Combine
import SwiftUI

extension EnvironmentValues {
    public var debugMenuMessage: some Publisher<DebugMenuMessage, Never> {
        NotificationCenter.default.publisher(for: .debugMenuMessage)
            .receive(on: RunLoop.main)
            .compactMap({ $0.userInfo?["message"] as? DebugMenuMessage })
    }
}

extension View {
    public func onDebugMenuMessage(_ messages: DebugMenuMessage..., perform action: @escaping (_ message: DebugMenuMessage) -> Void) -> some View {
        onReceive(\.debugMenuMessage) {
            if messages.isEmpty || messages.contains($0) {
                action($0)
            }
        }
    }
    
    public func onDebugMenuMessage(_ messages: DebugMenuMessage..., perform action: @escaping () -> Void) -> some View {
        onReceive(\.debugMenuMessage) {
            if messages.isEmpty || messages.contains($0) {
                action()
            }
        }
    }
}
