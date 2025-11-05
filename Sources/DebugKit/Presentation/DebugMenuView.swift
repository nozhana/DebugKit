//
//  DebugMenuView.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/3/25.
//

import Combine
import SwiftUI

public struct DebugMenuView: View {
    @Bindable private var networkLogManager = NetworkLogManager.shared
    @Bindable private var fileSystemLogManager = FileSystemLogManager.shared
    @Bindable private var databaseLogManager = DatabaseLogManager.shared
    
    @State private var currentTasks: (data: [URLSessionDataTask], upload: [URLSessionUploadTask], download: [URLSessionDownloadTask]) = ([], [] ,[])
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink("Logs", destination: NetworkLogsView.init)
                    NavigationLink("Events", destination: NetworkEventsView.init)
                    NavigationLink("Management", destination: NetworkManagementView.init)
                    LabeledContent {
                        Text("^[\(currentTasks.data.count) task](inflect: true)")
                            .contentTransition(.numericText(value: Double(currentTasks.data.count)))
                    } label: {
                        Label("Active Data Tasks", systemImage: "arrow.down.circle.dotted")
                    }
                    .bold(currentTasks.data.count > 0)
                    .animation(.smooth, value: currentTasks.data.count)
                    
                    LabeledContent {
                        Text("^[\(currentTasks.upload.count) task](inflect: true)")
                            .contentTransition(.numericText(value: Double(currentTasks.upload.count)))
                    } label: {
                        Label("Active Upload Tasks", systemImage: "tray.and.arrow.up")
                    }
                    .bold(currentTasks.upload.count > 0)
                    .animation(.smooth, value: currentTasks.upload.count)

                    LabeledContent {
                        Text("^[\(currentTasks.download.count) task](inflect: true)")
                            .contentTransition(.numericText(value: Double(currentTasks.download.count)))
                    } label: {
                        Label("Active Download Tasks", systemImage: "tray.and.arrow.down")
                    }
                    .bold(currentTasks.download.count > 0)
                    .animation(.smooth, value: currentTasks.download.count)
                } header: {
                    Label("Networking", systemImage: "arrow.up.arrow.down")
                }
                .onReceive(
                    NotificationCenter.default
                        .publisher(for: .networkTaskStarted)
                        .merge(with: NotificationCenter.default.publisher(for: .networkTaskDidReceiveResponse),
                               NotificationCenter.default.publisher(for: .networkTaskDidLoadData))
                ) { _ in
                    Task {
                        currentTasks = await URLSession.debug.tasks
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: .networkTaskFinished)) { _ in
                    Task {
                        currentTasks = await URLSession.debug.tasks
                        try await Task.sleep(for: .seconds(0.1))
                        currentTasks = await URLSession.debug.tasks
                    }
                }
                
                Section {
                    NavigationLink("Logs", destination: FileSystemLogsView.init)
                } header: {
                    Label("File System", systemImage: "archivebox")
                }
                
                Section {
                    NavigationLink("Logs", destination: DatabaseLogsView.init)
                } header: {
                    Label("Database", systemImage: "swiftdata")
                }
                
                let callback: PostMessageCallback = { message in
                    NotificationCenter.default.post(name: .debugMenuMessage, object: nil, userInfo: ["message": message])
                }
                AnyView(DebugMenuPresenter.shared.content(callback))
            }
            .toolbar {
                Button("Done", systemImage: "checkmark") {
                    DebugMenuPresenter.shared.dismiss()
                }
            }
            .navigationTitle("Debug Menu")
        }
        .environment(databaseLogManager)
        .environment(fileSystemLogManager)
        .environment(networkLogManager)
    }
}

extension DebugMenuView {
    public static func present() {
        _ = DebugMenuPresenter.shared
        NotificationCenter.default.post(name: .presentDebugMenu, object: nil)
    }
    
    public static func presentNetworkLogs() {
        _ = DebugMenuPresenter.shared
        NotificationCenter.default.post(name: .presentNetworkLogs, object: nil)
    }
    
    public static func presentNetworkEvents() {
        _ = DebugMenuPresenter.shared
        NotificationCenter.default.post(name: .presentNetworkEvents, object: nil)
    }
    
#if os(iOS)
    public enum ShakeMode: Int, CaseIterable, CustomStringConvertible {
        case debugMenu, networkLogs, networkEvents, disabled = -1
        
        public var description: String {
            switch self {
            case .debugMenu: "Debug Menu"
            case .networkLogs: "Network Logs"
            case .networkEvents: "Network Events"
            case .disabled: "Disabled"
            }
        }
    }
    
    public static var shakeMode: ShakeMode {
        get { DebugMenuPresenter.shared.shakeMode }
        set { DebugMenuPresenter.shared.shakeMode = newValue }
    }
#endif
    
    public static var messagePublisher: some Publisher<DebugMenuMessage, Never> {
        NotificationCenter.default.publisher(for: .debugMenuMessage)
            .compactMap({ $0.userInfo?["message"] as? DebugMenuMessage })
    }
    
    public static func onMessage(_ messages: DebugMenuMessage..., perform action: @escaping (_ message: DebugMenuMessage) -> Void) -> AnyCancellable {
        messagePublisher
            .sink { message in
                if messages.isEmpty || messages.contains(message) {
                    action(message)
                }
            }
    }
    
    public static func onMessage(_ messages: DebugMenuMessage..., perform action: @escaping () -> Void) -> AnyCancellable {
        messagePublisher
            .sink { message in
                if messages.isEmpty || messages.contains(message) {
                    action()
                }
            }
    }
    
    public typealias PostMessageCallback = (_ message: DebugMenuMessage) -> Void
    public typealias Content = (_ post: @escaping PostMessageCallback) -> any View
    
    public static func registerContent(@ViewBuilder _ content: @escaping (_ post: @escaping PostMessageCallback) -> some View) {
        DebugMenuPresenter.shared.content = content
    }
}
