//
//  DebugMenuView.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/3/25.
//

import Combine
import SwiftUI

/// The main SwiftUI View representing the Debug Menu.
public struct DebugMenuView: View {
    @Bindable private var networkLogManager = NetworkLogManager.shared
    @Bindable private var fileSystemLogManager = FileSystemLogManager.shared
    @Bindable private var databaseLogManager = DatabaseLogManager.shared
    @Bindable private var systemInformationManager = SystemInformationManager.shared
    
    @State private var currentTasks: (data: [URLSessionDataTask], upload: [URLSessionUploadTask], download: [URLSessionDownloadTask]) = ([], [] ,[])
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink("Logs", destination: NetworkLogsView.init)
                        .bold()
                    NavigationLink("Events", destination: NetworkEventsView.init)
                        .bold()
                    NavigationLink("Management", destination: NetworkManagementView.init)
                        .bold()
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
                    LabeledContent("Operating System", value: SystemInformation.operatingSystemName)
                    LabeledContent("OS Version", value: SystemInformation.operatingSystemVersion)
                    LabeledContent("Device Model", value: SystemInformation.deviceModel)
                    LabeledContent("Running via Mac Catalyst", value: SystemInformation.isMacCatalystApp ? "Yes" : "No")
                    LabeledContent("Running native iOS app on Mac", value: SystemInformation.isiOSAppOnMac ? "Yes" : "No")
                    LabeledContent("Low-Power Mode", value: systemInformationManager.isLowPowerModeEnabled ? "On" : "Off")
#if os(iOS)
                    LabeledContent("Battery Level", value: systemInformationManager.batteryLevel, format: .percent.rounded(rule: .toNearestOrAwayFromZero, increment: 1))
                    LabeledContent("Battery State", value: systemInformationManager.batteryState.description)
#endif
                    LabeledContent("Thermal State", value: systemInformationManager.thermalState.description)
                    TimelineView(.animation(minimumInterval: 1)) { _ in
                        let duration = Duration.seconds(SystemInformation.systemUpime)
                        LabeledContent("System Uptime", value: duration, format: .time(pattern: .hourMinuteSecond))
                            .contentTransition(.numericText(value: SystemInformation.systemUpime))
                            .animation(.smooth, value: SystemInformation.systemUpime)
                    }
                    LabeledContent("System Startup", value: SystemInformation.systemStartup, format: .dateTime.month().day().hour().minute().second())
                    TimelineView(.animation(minimumInterval: 1)) { timeline in
                        LabeledContent("Current Time", value: timeline.date, format: .dateTime.month().day().hour().minute().second())
                            .contentTransition(.numericText(value: timeline.date.timeIntervalSinceReferenceDate))
                            .animation(.smooth, value: timeline.date)
                    }
                    TimelineView(.animation(minimumInterval: 1)) { timeline in
                        LabeledContent("Memory in use", value: SystemInformation.basicMemoryUsage, format: .byteCount(style: .memory))
                            .contentTransition(.numericText(value: SystemInformation.basicMemoryUsage.value))
                            .animation(.smooth, value: timeline.date)
                    }
                    TimelineView(.animation(minimumInterval: 1)) { timeline in
                        LabeledContent("VM memory in use", value: SystemInformation.virtualMemoryUsage, format: .byteCount(style: .memory))
                            .contentTransition(.numericText(value: SystemInformation.virtualMemoryUsage.value))
                            .animation(.smooth, value: timeline.date)
                    }
                    TimelineView(.animation(minimumInterval: 1)) { timeline in
                        LabeledContent("Consumed energy", value: SystemInformation.powerUsage, format: .measurement(width: .wide, usage: .asProvided, numberFormatStyle: .number.precision(.fractionLength(0...3))))
                            .contentTransition(.numericText(value: SystemInformation.powerUsage.value))
                            .animation(.smooth, value: timeline.date)
                    }
                    NavigationLink("More Details", destination: SystemInformationView.init)
                        .bold()
                    NavigationLink("System Events", destination: SystemEventsView.init)
                        .bold()
                } header: {
                    Label("System Information", systemImage: "info.circle")
                }
                
                Section {
                    LabeledContent("App Launches") {
                        Text("^[\(SystemInformation.appLaunches) time](inflect: true)")
                    }
                    LabeledContent("Bundle Name", value: SystemInformation.bundleName)
                    LabeledContent("Bundle Executable", value: SystemInformation.bundleExecutable)
                    LabeledContent("Bundle Identifier", value: SystemInformation.bundleIdentifier)
                    LabeledContent("Bundle Version", value: SystemInformation.bundleVersion)
                    LabeledContent("Build Number", value: SystemInformation.bundleBuildNumber, format: .number)
                    if SystemInformation.bundleInfoDictionary.isEmpty {
                        LabeledContent("Bundle Info", value: "Empty")
                    } else {
                        NavigationLink {
                            AnyJSONObjectVisualizerView(object: SystemInformation.bundleInfoDictionary)
                                .navigationTitle("Bundle Info")
                        } label: {
                            LabeledContent("Bundle Info") {
                                Text("^[\(SystemInformation.bundleInfoDictionary.count) key](inflect: true)")
                            }
                            .bold()
                        }
                    }
                    if SystemInformation.environment.isEmpty {
                        LabeledContent("Environment Values", value: "Empty")
                    } else {
                        NavigationLink {
                            AnyJSONObjectVisualizerView(object: SystemInformation.environment.mapValues({ .string($0) }))
                                .navigationTitle("Environment Values")
                        } label: {
                            LabeledContent("Environment Values") {
                                Text("^[\(SystemInformation.environment.count) key](inflect: true)")
                            }
                            .bold()
                        }
                    }
                    
                    LabeledContent("Executable Path", value: SystemInformation.executablePath)
                    
                    if SystemInformation.arguments.isEmpty {
                        LabeledContent("Command Line Arguments", value: "Empty")
                    } else {
                        NavigationLink {
                            AnyJSONArrayVisualizerView(array: SystemInformation.arguments.map({ .string($0) }))
                                .navigationTitle("Command Line Arguments")
                        } label: {
                            LabeledContent("Command Line Arguments") {
                                Text("^[\(SystemInformation.arguments.count) argument](inflect: true)")
                            }
                            .bold()
                        }
                    }
                } header: {
                    Label("App Information", systemImage: "app")
                }

                
                Section {
                    NavigationLink("Logs", destination: FileSystemLogsView.init)
                        .bold()
                } header: {
                    Label("File System", systemImage: "archivebox")
                }
                
                Section {
                    NavigationLink("Logs", destination: DatabaseLogsView.init)
                        .bold()
                } header: {
                    Label("Database", systemImage: "swiftdata")
                }
                
                let callback: PostMessageCallback = { message in
                    NotificationCenter.default.post(name: .debugMenuMessage, object: nil, userInfo: ["message": message])
                }
                AnyView(DebugMenuPresenter.shared.content(callback))
                
                Section {
                    VStack(spacing: 6) {
                        Text("Made with ♥︎")
                            .font(.caption.weight(.semibold))
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text("© 2025")
                            Link("@nozhana", destination: URL(string: "https://github.com/nozhana")!)
                                .bold()
                                .underline()
                        }
                        .font(.caption2.weight(.medium))
                    }
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                }
                .listRowInsets(.init())
                .listRowBackground(Color.clear)
            }
            .toolbar {
                Button("Done", systemImage: "checkmark") {
                    DebugMenuPresenter.shared.dismiss()
                }
            }
            .navigationTitle("Debug Menu")
        }
        .environment(systemInformationManager)
        .environment(databaseLogManager)
        .environment(fileSystemLogManager)
        .environment(networkLogManager)
    }
}

extension DebugMenuView {
    /// Initialize necessary resources (i.e. Presenter, Network logger, File system logger, Database logger) on launch.
    ///
    /// Call this method as soon as the app starts.
    /// ```swift
    /// struct MyApp: App {
    ///     init() {
    ///         DebugMenuView.initialize()
    ///     }
    ///
    ///     // ...
    /// }
    /// ```
    ///
    /// - Note: Calling ``registerContent(_:)-fdls`` implicitly invokes this method as well.
    public static func initialize() {
        _ = DebugMenuPresenter.shared
        _ = NetworkLogManager.shared
        _ = FileSystemLogManager.shared
        _ = DatabaseLogManager.shared
        _ = SystemInformationManager.shared
    }
    
    /// The component to draw over the top view using ``present(_:)``
    public enum Component {
        case debugMenu, networkLogs, networkEvents, fileSystemLogs, databaseLogs
        
        var notification: Notification.Name {
            switch self {
            case .debugMenu: .presentDebugMenu
            case .networkLogs: .presentNetworkLogs
            case .networkEvents: .presentNetworkEvents
            case .fileSystemLogs: .presentFileSystemLogs
            case .databaseLogs: .presentDatabaseLogs
            }
        }
    }
    
    /// Present a component or the entire debug menu.
    /// - Parameter component: The debug menu ``Component`` to present.
    ///
    /// - SeeAlso: ``present()``
    public static func present(_ component: Component) {
        initialize()
        NotificationCenter.default.post(name: component.notification, object: nil)
    }
    
    /// Present the debug menu.
    ///
    /// - Note: This is equivalent to calling ``present(_:)`` with ``Component/debugMenu``.
    /// - SeeAlso: ``present(_:)``, ``Component``
    public static func present() {
        present(.debugMenu)
    }
    
    /// A representation of the transition style for the debug menu.
    ///
    /// ## Cases
    /// - ``cover``
    /// - ``flip``
    ///
    /// - SeeAlso: ``presentationMode-swift.type.property``
    public enum PresentationMode: CaseIterable, CustomStringConvertible {
        case cover, flip
        
        public var description: String {
            switch self {
            case .cover: "Vertical Cover"
            case .flip: "Horizontal Flip"
            }
        }
    }
    
    /// How the debug menu transitions into view when activated.
    ///
    /// - SeeAlso: ``PresentationMode-swift.enum``
    public static var presentationMode: PresentationMode {
        get { DebugMenuPresenter.shared.presentationMode }
        set { DebugMenuPresenter.shared.presentationMode = newValue }
    }
    
    /// A representation of what the Debug Menu will present in reaction to shaking the device, if any.
    ///
    /// ## Cases
    /// - ``debugMenu``: Present the entire debug menu in fullscreen.
    /// - ``networkLogs``: Present network logs in a modal sheet.
    /// - ``networkEvents``: Present network events in a modal sheet.
    /// - ``fileSystemLogs``: Present file system logs in a modal sheet.
    /// - ``databaseLogs``: Present database logs in a modal sheet.
    /// - ``disabled``: Don't present anything in reaction to shaking the device.
    ///
    /// - SeeAlso: ``shakeMode-swift.type.property``
    public enum ShakeMode: Int, CaseIterable, CustomStringConvertible {
        case debugMenu, networkLogs, networkEvents, fileSystemLogs, databaseLogs
        case disabled = -1
        
        public var description: String {
            switch self {
            case .debugMenu: "Debug Menu"
            case .networkLogs: "Network Logs"
            case .networkEvents: "Network Events"
            case .fileSystemLogs: "File System Logs"
            case .databaseLogs: "Database Logs"
            case .disabled: "Disabled"
            }
        }
    }
    
    /// How the debug menu reacts to shaking the device.
    ///
    /// - SeeAlso: ``ShakeMode-swift.enum``
    public static var shakeMode: ShakeMode {
        get { DebugMenuPresenter.shared.shakeMode }
        set { DebugMenuPresenter.shared.shakeMode = newValue }
    }
    
    /// A publisher that publishes ``DebugMenuMessage`` items produced by a ``PostMessageCallback`` in a ``Content`` block.
    ///
    /// ## Usage
    /// Subscribe to this publisher to receive debug menu messages.
    ///
    /// ### SwiftUI
    /// ```swift
    /// var body: some View {
    ///     ProfileView()
    ///         .onReceive(DebugMenuView.messagePublisher) { message in
    ///             switch message {
    ///                 case .profileDidUpdate:
    ///                     // Do something
    ///                 default:
    ///                     break
    ///             }
    ///         }
    /// }
    /// ```
    ///
    /// ### Combine
    /// ```swift
    /// @MainActor
    /// func setupBindings() {
    ///     DebugMenuView.messagePublisher
    ///         .sink { [weak self] message in
    ///             self?.handleMessage(message)
    ///         }
    ///         .store(in: &cancellables)
    /// }
    /// ```
    ///
    /// - SeeAlso: ``DebugMenuMessage``, ``PostMessageCallback``, ``Content``
    public static var messagePublisher: some Publisher<DebugMenuMessage, Never> {
        NotificationCenter.default.publisher(for: .debugMenuMessage)
            .receive(on: RunLoop.main)
            .compactMap({ $0.userInfo?["message"] as? DebugMenuMessage })
    }
    
    /// Subscribe to all debug menu messages, or a subset of them.
    /// - Parameters:
    ///   - messages: A variadic array of debug menu messages to observe. If empty, will return a cancellable observing **all debug menu messages**.
    ///   - action: Action block to perform when receiving the debug menu message.
    /// - Returns: An `AnyCancellable` that represents the subscription.
    ///
    /// ## Usage
    /// ```swift
    /// @MainActor
    /// func setupBindings() {
    ///     DebugMenuView.onMessage(.printMessage) { message in
    ///         print(message)
    ///     }
    ///     .store(in: &cancellables)
    /// }
    /// ```
    ///
    /// - Warning: You should maintain a strong reference to the cancellable to keep the subscription alive,
    /// using `store(in:)` or assigning the cancellable to a property on a reference type object.
    ///
    /// - SeeAlso: ``onMessage(_:perform:)-9rdxn``
    public static func onMessage(_ messages: DebugMenuMessage..., perform action: @escaping (_ message: DebugMenuMessage) -> Void) -> AnyCancellable {
        messagePublisher
            .receive(on: RunLoop.main)
            .sink { message in
                if messages.isEmpty || messages.contains(message) {
                    action(message)
                }
            }
    }
    
    /// Subscribe to all debug menu messages, or a subset of them.
    /// - Parameters:
    ///   - messages: A variadic array of debug menu messages to observe. If empty, will return a cancellable observing **all debug menu messages**.
    ///   - action: Action block to perform when receiving the debug menu message.
    /// - Returns: An `AnyCancellable` that represents the subscription.
    ///
    /// ## Usage
    /// ```swift
    /// @MainActor
    /// func setupBindings() {
    ///     DebugMenuView.onMessage(.wipeCache) {
    ///         Task { try await model.wipeCache() }
    ///     }
    ///     .store(in: &cancellables)
    /// }
    /// ```
    ///
    /// - Warning: You should maintain a strong reference to the cancellable to keep the subscription alive,
    /// using `store(in:)` or assigning the cancellable to a property on a reference type object.
    ///
    /// - SeeAlso: ``onMessage(_:perform:)-6746m``
    public static func onMessage(_ messages: DebugMenuMessage..., perform action: @escaping () -> Void) -> AnyCancellable {
        messagePublisher
            .receive(on: RunLoop.main)
            .sink { message in
                if messages.isEmpty || messages.contains(message) {
                    action()
                }
            }
    }
    
    /// A callback that posts a notification for a provided ``DebugMenuMessage``.
    ///
    /// - SeeAlso: ``Content``, ``DebugMenuMessage``, ``messagePublisher``, ``onMessage(_:perform:)-6746m``
    public typealias PostMessageCallback = (_ message: DebugMenuMessage) -> Void
    
    /// A view builder callback that represents the customized content for the Debug Menu.
    ///
    /// - SeeAlso: ``PostMessageCallback``, ``registerContent(_:)-3yg69``
    public typealias Content = (_ post: @escaping PostMessageCallback) -> any View
    
    /// Registers customized content for the Debug Menu.
    /// - Parameter content: The ``Content`` to display in the Debug Menu below the proprietary controls.
    ///
    /// ## Usage
    /// ```swift
    /// struct MyApp: App {
    ///     init() {
    ///         DebugMenuView.registerContent { post in
    ///             Button("Clear Logs", systemImage: "trash", role: .destructive) {
    ///                 post(.clearLogs)
    ///             }
    ///         }
    ///     }
    ///
    ///     var body: some Scene {
    ///         // ...
    ///     }
    /// }
    ///
    /// extension DebugMenuMessage {
    ///     static let clearLogs: DebugMenuMessage = "clearLogs"
    /// }
    /// ```
    ///
    /// - Note: Calling this method automatically initializes `DebugKit`, so there is no need to explicitly call ``initialize()`` if you're registering the content as soon as the app starts.
    /// - SeeAlso: ``registerContent(_:)-3yg69``, ``Content``, ``PostMessageCallback``, ``initialize()``
    public static func registerContent(@ViewBuilder _ content: @escaping (_ post: @escaping PostMessageCallback) -> some View) {
        initialize()
        DebugMenuPresenter.shared.content = content
    }
    
    /// Registers customized content for the Debug Menu without a ``PostMessageCallback``.
    /// - Parameter content: The ``Content`` to display in the Debug Menu below the proprietary controls.
    ///
    /// ## Usage
    /// ```swift
    /// struct MyApp: App {
    ///     init() {
    ///         DebugMenuView.registerContent {
    ///             Label("Made With Love", systemImage: "heart.fill")
    ///         }
    ///     }
    ///
    ///     var body: some Scene {
    ///         // ...
    ///     }
    /// }
    /// ```
    ///
    /// - Note: Calling this method automatically initializes `DebugKit`, so there is no need to explicitly call ``initialize()`` if you're registering the content as soon as the app starts.
    /// - SeeAlso: ``registerContent(_:)-fdls``, ``Content``, ``initialize()``
    public static func registerContent(@ViewBuilder _ content: @escaping () -> some View) {
        registerContent { _ in content() }
    }
}
