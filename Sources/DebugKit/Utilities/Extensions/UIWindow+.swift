//
//  ShakeDetector.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/5/25.
//

#if canImport(UIKit)
import UIKit

extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        guard motion == .motionShake else { return }
        DebugMenuView.initialize()
        NotificationCenter.default.post(name: .deviceDidShake, object: nil)
    }
}
#endif
