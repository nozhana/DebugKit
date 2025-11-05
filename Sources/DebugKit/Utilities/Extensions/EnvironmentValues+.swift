//
//  EnvironmentValues+.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/5/25.
//

import Combine
import SwiftUI

extension EnvironmentValues {
    public var debugMenuMessage: some Publisher<String, Never> {
        NotificationCenter.default.publisher(for: .debugMenuMessage)
            .compactMap({ $0.userInfo?["message"] as? String })
    }
}

extension View {
    public func onDebugMenuMessage(perform action: @escaping (_ message: String) -> Void) -> some View {
        onReceive(\.debugMenuMessage, perform: action)
    }
}
