//
//  NetworkManagementView.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/5/25.
//

import SwiftUI

struct NetworkManagementView: View {
    @Environment(NetworkLogManager.self) private var manager
    
    @State private var alertContent: (title: LocalizedStringKey, message: LocalizedStringKey?, actions: (() -> any View)?)?
    @State private var isAlertPresented = false
    
    @State private var isResettingSession = false
    @State private var isClearingCache = false
    @State private var isClearingCookies = false
    @State private var isClearingCredentials = false
    
    var body: some View {
        List {
            Section {
                Button("Reset Session", role: .destructive) {
                    isResettingSession = true
                    URLSession.debug.reset {
                        DispatchQueue.main.async {
                            isResettingSession = false
                            alertContent = ("Session Reset", "Session reset successfully.", nil)
                            isAlertPresented = true
                        }
                    }
                }
                .disabled(isResettingSession)
                .safeAreaInset(edge: .trailing, spacing: 16) {
                    VStack {
                        if isResettingSession {
                            ProgressView()
                                .transition(.blurReplace)
                        }
                    }
                    .animation(.smooth, value: isResettingSession)
                }
            } header: {
                Label("Session", systemImage: "link.circle")
            }
            
            Section {
                Button("Clear Cache", role: .destructive) {
                    isClearingCache = true
                    defer {
                        isClearingCache = false
                        alertContent = ("Cache Cleared", "Cache cleared successfully.", nil)
                        isAlertPresented = true
                    }
                    URLSession.debug.configuration.urlCache?.removeAllCachedResponses()
                }
                .disabled(isClearingCache)
                .safeAreaInset(edge: .trailing, spacing: 16) {
                    VStack {
                        if isClearingCache {
                            ProgressView()
                                .transition(.blurReplace)
                        }
                    }
                    .animation(.smooth, value: isClearingCache)
                }
            } header: {
                Label("Cache", systemImage: "hare")
            }
            
            Section {
                let cookies = URLSession.debug.configuration.httpCookieStorage?.cookies ?? []
                if !cookies.isEmpty {
                    NavigationLink {
                        List {
                            ForEach(cookies, id: \.self) { cookie in
                                Section {
                                    LabeledContent("Name", value: cookie.name)
                                    LabeledContent("Value", value: cookie.value)
                                    LabeledContent("Version", value: cookie.version, format: .number)
                                    LabeledContent("Path", value: cookie.path)
                                    LabeledContent("Domain", value: cookie.domain)
                                    if let comment = cookie.comment {
                                        LabeledContent("Comment", value: comment)
                                    }
                                    if let commentURL = cookie.commentURL {
                                        LabeledContent("Comment URL", value: commentURL.absoluteString)
                                    }
                                    if let expiresDate = cookie.expiresDate {
                                        LabeledContent("Expires At", value: expiresDate, format: .dateTime.month().day().hour().minute().second())
                                    }
                                    LabeledContent("HTTP Only", value: cookie.isHTTPOnly ? "Yes" : "No")
                                    LabeledContent("Session Only", value: cookie.isSessionOnly ? "Yes" : "No")
                                    LabeledContent("Secure", value: cookie.isSecure ? "Yes" : "No")
                                } header: {
                                    Text(cookie.name)
                                }
                            }
                        }
                        .navigationTitle("Cookies")
                    } label: {
                        LabeledContent("Cookies") {
                            Text("^[\(cookies.count) item](inflect: true)")
                        }
                    }
                }
                
                Button("Clear Cookies", role: .destructive) {
                    isClearingCookies = true
                    defer {
                        isClearingCookies = false
                        alertContent = ("Cookies Cleared", "Cookies cleared successfully.", nil)
                        isAlertPresented = true
                    }
                    URLSession.debug.configuration.httpCookieStorage?.removeCookies(since: .distantPast)
                }
                .disabled(isClearingCookies)
                .safeAreaInset(edge: .trailing, spacing: 16) {
                    VStack {
                        if isClearingCookies {
                            ProgressView()
                                .transition(.blurReplace)
                        }
                    }
                    .animation(.smooth, value: isClearingCookies)
                }
            } header: {
                Label("Cookies", systemImage: "globe")
            }
            
            Section {
                Button("Clear Credentials", role: .destructive) {
                    isClearingCredentials = true
                    defer {
                        isClearingCredentials = false
                        alertContent = ("Credentials Cleared", "Credentials cleared successfully.", nil)
                        isAlertPresented = true
                    }
                    URLSession.debug.configuration.urlCredentialStorage?.allCredentials.forEach { pair in
                        pair.value.values.forEach { credential in
                            URLSession.debug.configuration.urlCredentialStorage?.remove(credential, for: pair.key)
                        }
                    }
                }
                .disabled(isClearingCredentials)
                .safeAreaInset(edge: .trailing, spacing: 16) {
                    VStack {
                        if isClearingCredentials {
                            ProgressView()
                                .transition(.blurReplace)
                        }
                    }
                    .animation(.smooth, value: isClearingCredentials)
                }
            } header: {
                Label("Credentials", systemImage: "lock.circle.dotted")
            }
        }
        .navigationTitle("Network Management")
        .alert(alertContent?.title ?? "", isPresented: $isAlertPresented, presenting: alertContent) { content in
            if let actions = content.actions {
                AnyView(actions())
            } else {
                Button("OK") {
                    Task {
                        try await Task.sleep(for: .seconds(0.2))
                        alertContent = nil
                    }
                }
            }
        } message: { content in
            content.message.map { Text($0) }
        }
    }
}
