//
//  NetworkLogsView.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/4/25.
//

import AVKit
import SwiftUI

struct NetworkLogsView: View {
    @Environment(NetworkLogManager.self) private var manager
    
    @State private var isShowingPersistedLogs = false
    
    var body: some View {
        VStack(spacing: .zero) {
            if isShowingPersistedLogs,
               !manager.persistedLogs.isEmpty {
                List(manager.persistedLogs) { log in
                    NetworkLogSectionView(log: log, isPersisted: Binding { true } set: { _ in manager.removePersistedLog(log) })
                }
                .animation(.smooth, value: manager.persistedLogs)
            } else if manager.logs.isEmpty {
                ContentUnavailableView("No Logs", systemImage: "cloud")
            } else {
                List(manager.logs) { log in
                    let isPersistedBinding = Binding<Bool> {
                        manager.persistedLogs.contains(where: { $0.id == log.id })
                    } set: { value in
                        if value {
                            manager.persist(log)
                        } else {
                            manager.removePersistedLog(log)
                        }
                    }
                    NetworkLogSectionView(log: log, isPersisted: isPersistedBinding)
                }
            }
        }
        .animation(.smooth, value: manager.logs)
        .toolbar {
            if !manager.persistedLogs.isEmpty {
                Toggle("Persisted Logs", systemImage: "bookmark.fill", isOn: $isShowingPersistedLogs.animation(.smooth))
            }
            Button("Clear", systemImage: "clear", role: .destructive) {
                manager.logs.removeAll()
            }
        }
        .navigationTitle("Network Logs")
    }
}

#Preview {
    NetworkLogsView()
}

private struct NetworkLogSectionView: View {
    var log: NetworkLog
    @Binding var isPersisted: Bool
    
    @State private var isJSONExpanded = false
    
    var body: some View {
        Section {
            LabeledContent("Request URL", value: log.request.url?.absoluteString ?? "N/A")
            if let headers = log.request.allHTTPHeaderFields?.mapValues({ AnyJSON(rawValue: $0) }) {
                NavigationLink {
                    AnyJSONObjectVisualizerView(object: headers)
                        .navigationTitle("Request Headers")
                } label: {
                    LabeledContent("Request Headers") {
                        Text("^[\(headers.count) entry](inflect: true)")
                    }
                }
            }
            LabeledContent("Start Time", value: log.start, format: dateFormat(for: log.start))
            LabeledContent("Duration", value: log.duration ?? .zero, format: .time(pattern: .minuteSecond(padMinuteToLength: 2, fractionalSecondsLength: 3)))
            LabeledContent("Completed", value: log.isCompleted ? "Yes" : "No")
            if let end = log.end {
                LabeledContent("End Time", value: end, format: dateFormat(for: end))
            } else {
                LabeledContent("End Time", value: "N/A")
            }
            LabeledContent("Response Status", value: log.responseStatus?.description ?? "N/A")
            let bytes = Measurement(value: Double(log.responseData?.count ?? .zero), unit: UnitInformationStorage.bytes)
            LabeledContent("Response Data", value: bytes, format: .byteCount(style: .memory, allowedUnits: .default, spellsOutZero: true))
            if let response = log.response {
                let expectedBytes = Measurement(value: Double(response.expectedContentLength), unit: UnitInformationStorage.bytes)
                LabeledContent("Expected Content Length", value: expectedBytes, format: .byteCount(style: .memory))
            } else {
                LabeledContent("Expected Content Length", value: "N/A")
            }
            LabeledContent("Mime Type", value: log.response?.mimeType ?? "N/A")
            if let error = log.error {
                LabeledContent("Error") {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(error.description)
                            .font(.system(size: 15, weight: .medium))
                        Image(systemName: error.systemImage)
                    }
                    .foregroundStyle(.red)
                }
            }
            if !log.isCompleted,
               let progress = log.progress {
                LabeledContent("Progress") {
                    ProgressView(value: progress, total: 1)
                        .progressViewStyle(.linear)
                }
            }
            if let response = log.decodedResponse {
                NavigationLink {
                    AnyJSONObjectVisualizerView(object: response)
                        .navigationTitle("Response")
                } label: {
                    LabeledContent("Response") {
                        Text("^[\(response.count) entry](inflect: true)")
                    }
                }
            }
            if let headers = log.response?.allHeaderFields as? [String: String] {
                NavigationLink {
                    let headers = headers.mapValues { AnyJSON(rawValue: $0) }
                    AnyJSONObjectVisualizerView(object: headers)
                        .navigationTitle("Response Headers")
                } label: {
                    LabeledContent("Response Headers") {
                        Text("^[\(headers.count) entry](inflect: true)")
                    }
                }
            }
            if let prettyPrintedJSON = log.prettyPrintedJSON {
                VStack(alignment: .leading, spacing: 8) {
                    Label("JSON", systemImage: "curlybraces.square.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(prettyPrintedJSON)
                        .lineLimit(isJSONExpanded ? nil : 10)
                        .multilineTextAlignment(.leading)
                }
                .onTapGesture {
                    isJSONExpanded.toggle()
                }
            }
            if log.isCompleted,
               log.response?.mimeType?.starts(with: "image") == true,
               let data = log.responseData,
               let image = PlatformImage(data: data) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Image")
                    Image(platformImage: image)
                        .resizable()
                        .scaledToFit()
                        .clipShape(.rect(cornerRadius: 12))
                        .padding(16)
                        .frame(height: 300)
                }
            }
            if log.isCompleted,
               log.response?.mimeType?.starts(with: "image/svg") == true,
               let data = log.responseData {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Image")
                    WebView(svgData: data, request: log.request)
                        .padding(16)
                        .frame(height: 300)
                }
            }
            if log.isCompleted,
               log.response?.mimeType?.starts(with: "video") == true,
               let data = log.responseData {
                let url = {
                    let tmp = URL.temporaryDirectory.appendingPathComponent("video", conformingTo: .init(mimeType: log.response?.mimeType ?? "video/mp4", conformingTo: .movie) ?? .mpeg4Movie)
                    try? FileManager.default.removeItem(at: tmp)
                    try? data.write(to: tmp)
                    return tmp
                }()
                let player = AVPlayer(url: url)
                VStack(alignment: .leading, spacing: 8) {
                    Button("Play Video", systemImage: "play") {
                        player.pause()
                        player.seek(to: .zero)
                        player.play()
                    }
                    VideoPlayer(player: player)
                        .aspectRatio(1, contentMode: .fit)
                }
            }
            if log.isCompleted,
               log.response?.mimeType == "text/html" {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Web Page")
                    WebView(request: log.request,
                            simulatedResponse: log.response,
                            simulatedResponseData: log.responseData)
                    .frame(height: 300)
                }
            }
        } header: {
            HStack(spacing: 8) {
                if let method = log.request.httpMethod {
                    Text(method)
                    Divider()
                }
                if let error = log.error {
                    Label(error.shortDescription, systemImage: error.systemImage)
                        .foregroundStyle(.red)
                } else if let status = log.responseStatus {
                    Label(status.description, systemImage: status.systemImage)
                        .foregroundStyle(status.color.gradient)
                } else if !log.isCompleted {
                    ProgressView()
                } else {
                    Image(systemName: "questionmark.circle")
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Toggle("Persisted", systemImage: isPersisted ? "bookmark.fill" : "bookmark", isOn: $isPersisted)
                    .if(UIDevice.current.userInterfaceIdiom == .phone) {
                        $0.labelStyle(.iconOnly)
                    }
                    .toggleStyle(.button)
            }
        }
        .contentTransition(.numericText())
    }
    
    private func dateFormat(for date: Date) -> Date.FormatStyle {
        let format = Date.FormatStyle.dateTime.hour().minute().second().secondFraction(.fractional(3))
        if Calendar.current.isDateInToday(date) { return format }
        return format.month().day()
    }
}
