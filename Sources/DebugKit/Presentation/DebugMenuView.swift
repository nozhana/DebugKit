//
//  DebugMenuView.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/3/25.
//

import SwiftUI

public struct DebugMenuView: View {
    @State private var networkLogManager = NetworkLogManager()
    @State private var fileSystemLogManager = FileSystemLogManager()
    @State private var databaseLogManager = DatabaseLogManager()
    
    @State private var currentTasks: (data: [URLSessionDataTask], upload: [URLSessionUploadTask], download: [URLSessionDownloadTask]) = ([], [] ,[])
    
    public init() {}
    
    // FIXME: DEBUG
    @State private var urlField = "https://dummyjson.com/recipes"
    @FocusState private var focused: Bool
    @State private var isLoading = false
    
    public var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink("Logs", destination: NetworkLogsView.init)
                    NavigationLink("Events", destination: NetworkEventsView.init)
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
                        Label("Active Download Tasks", systemImage: "tray.and.arrow.up")
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
                
                // FIXME: DEBUG
                Section {
                    TextField("Test URL", text: $urlField, prompt: Text(verbatim: "https://google.com/..."))
                        .focused($focused)
                        .disabled(isLoading)
                    Button("Perform Request", systemImage: "tray.and.arrow.down") {
                        do {
                            guard let url = URL(string: urlField) else {
                                focused = true
                                return
                            }
                            Task {
                                isLoading = true
                                defer {
                                    isLoading = false
                                }
                                do {
                                    try await Task.sleep(for: .seconds(2))
                                    let (data, response) = try await URLSession.debug.data(from: url)
                                    print("Request finished successfully: \(data)\nResponse: \(response)")
                                } catch {
                                    print("Request failed: \(error.localizedDescription)")
                                    print("Type: \(String(describing: type(of: error)))")
                                    print("Reflection: \(String(reflecting: error))")
                                }
                            }
                        }
                    }
                    .disabled(isLoading)
                    .safeAreaInset(edge: .trailing, spacing: 16) {
                        if isLoading {
                            ProgressView()
                        }
                    }
                }
                
                // FIXME: DEBUG
                Section {
                    let base = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let urls = (0..<5).reduce(into: [URL]()) { partialResult, index in
                        let url = base.appendingPathComponent("test\(index).txt", conformingTo: .text)
                        partialResult.append(url)
                    }
                    
                    Button("Create test files") {
                        Task {
                            let data = "Hello, World!".data(using: .utf8)!
                            for url in urls {
                                try data.write(to: url)
                                try await Task.sleep(for: .seconds(1))
                            }
                        }
                    }
                    Button("Remove test files") {
                        Task {
                            for url in urls {
                                try FileManager.default.removeItem(at: url)
                                try await Task.sleep(for: .seconds(1))
                            }
                        }
                    }
                }
            }
            .navigationTitle("Debug Menu")
        }
        .environment(databaseLogManager)
        .environment(fileSystemLogManager)
        .environment(networkLogManager)
    }
}
