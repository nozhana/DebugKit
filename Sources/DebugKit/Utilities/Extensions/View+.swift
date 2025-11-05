//
//  View+.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/4/25.
//

import SwiftUI

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
