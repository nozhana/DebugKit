//
//  SettingsView.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/8/25.
//

import SwiftUI

struct SettingsView: View {
    @Bindable private var presenter = DebugMenuPresenter.shared
    
    var body: some View {
        List {
            Section {
#if os(iOS)
                Picker("Shake Mode", systemImage: "iphone.motion", selection: $presenter.shakeMode) {
                    ForEach(DebugMenuView.ShakeMode.allCases, id: \.rawValue) { mode in
                        Label(mode.description, systemImage: mode.systemImage)
                            .tag(mode)
                    }
                }
#endif
                Picker("Presentation Mode", systemImage: "menubar.arrow.up.rectangle", selection: $presenter.presentationMode) {
                    ForEach(DebugMenuView.PresentationMode.allCases, id: \.rawValue) { mode in
                        Label(mode.description, systemImage: mode.systemImage)
                            .tag(mode)
                    }
                }
            } header: {
                Label("Presentation", systemImage: "sparkle")
            }
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
