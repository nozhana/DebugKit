//
//  PlatformAgnosticism.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/5/25.
//

import SwiftUI

#if os(macOS)
typealias PlatformView = NSView
typealias PlatformViewRepresentable = NSViewRepresentable
#elseif os(iOS)
typealias PlatformView = UIView
typealias PlatformViewRepresentable = UIViewRepresentable
#endif

protocol ViewRepresentable: PlatformViewRepresentable {
    associatedtype ViewType: PlatformView
    func makePlatformView(context: Context) -> ViewType
    func updatePlatformView(_ view: ViewType, context: Context)
}

extension ViewRepresentable {
#if os(macOS)
    func makeNSView(context: Context) -> ViewType {
        makePlatformView(context: context)
    }
    
    func updateNSView(_ view: ViewType, context: Context) {
        updatePlatformView(view, context: context)
    }
#elseif os(iOS)
    func makeUIView(context: Context) -> ViewType {
        makePlatformView(context: context)
    }
    
    func updateUIView(_ view: ViewType, context: Context) {
        updatePlatformView(view, context: context)
    }
#endif
}

#if os(macOS)
typealias PlatformImage = NSImage
#elseif os(iOS)
typealias PlatformImage = UIImage
#endif

extension Image {
    init(platformImage: PlatformImage) {
#if os(macOS)
        self.init(nsImage: platformImage)
#elseif os(iOS)
        self.init(uiImage: platformImage)
#endif
    }
}
