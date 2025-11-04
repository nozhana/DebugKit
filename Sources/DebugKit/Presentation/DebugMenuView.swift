//
//  DebugMenuView.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/3/25.
//

import SwiftUI

public struct DebugMenuView: View {
    @State private var networkLogManager = NetworkLogManager()
    
    public init() {}
    
    // FIXME: DEBUG
    @State private var urlField = "https://dummyjson.com/recipes"
    @FocusState private var focused: Bool
    @State private var isLoading = false
    
    public var body: some View {
        NavigationStack {
            List {
                Section("Networking") {
                    NavigationLink("Logs", destination: NetworkLogsView.init)
                    NavigationLink("Events", destination: NetworkEventsView.init)
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
            }
            .navigationTitle("Debug Menu")
        }
        .environment(networkLogManager)
    }
}
