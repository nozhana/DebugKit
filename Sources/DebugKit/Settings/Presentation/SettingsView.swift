//
//  SettingsView.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/8/25.
//

import SwiftUI

struct SettingsView: View {
    @State private var shakeMode = DebugMenuView.shakeMode
    @State private var presentationMode = DebugMenuView.presentationMode
    
    var body: some View {
        List {
            Section {
                Picker("Shake Mode", systemImage: "iphone.motion", selection: $shakeMode) {
                    ForEach(DebugMenuView.ShakeMode.allCases, id: \.rawValue) { mode in
                        Label(mode.description, systemImage: mode.systemImage)
                            .tag(mode)
                    }
                }
                Picker("Presentation Mode", systemImage: "menubar.arrow.up.rectangle", selection: $presentationMode) {
                    ForEach(DebugMenuView.PresentationMode.allCases, id: \.self) { mode in
                        Label(mode.description, systemImage: mode.systemImage)
                            .tag(mode)
                    }
                }
            } header: {
                Label("Presentation", systemImage: "sparkle")
            }
        }
        .onChange(of: shakeMode) { _, newValue in
            DebugMenuView.shakeMode = newValue
        }
        .onChange(of: presentationMode) { _, newValue in
            DebugMenuView.presentationMode = newValue
        }
        .navigationTitle("Settings")
    }
}

private extension DebugMenuView.ShakeMode {
    var systemImage: String {
        switch self {
        case .debugMenu: "ladybug"
        case .networkLogs: "globe"
        case .networkEvents: "circle.dotted.circle"
        case .fileSystemLogs: "archivebox"
        case .databaseLogs: "cylinder.split.1x2"
        case .disabled: "iphone.slash"
        }
    }
}

private extension DebugMenuView.PresentationMode {
    var systemImage: String {
        switch self {
        case .cover: "arrow.up.page.on.clipboard"
        case .flip: "arrow.trianglehead.2.clockwise.rotate.90.page.on.clipboard"
        }
    }
}
