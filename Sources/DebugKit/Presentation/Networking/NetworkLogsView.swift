//
//  NetworkLogsView.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/4/25.
//

import SwiftUI

struct NetworkLogsView: View {
    @Environment(NetworkLogManager.self) private var manager
    
    var body: some View {
        List(manager.logs) { log in
            NetworkLogSectionView(log: log)
        }
        .animation(.smooth, value: manager.logs)
        .toolbar {
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
    
    @State private var isJSONExpanded = false
    
    var body: some View {
        Section(log.id.uuidString) {
            LabeledContent("Request URL", value: log.request.url?.absoluteString ?? "N/A")
            LabeledContent("Request HTTP Method", value: log.request.httpMethod ?? "N/A")
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
            LabeledContent("Start Time", value: log.start, format: .dateTime.hour().minute().second().secondFraction(.fractional(3)))
            LabeledContent("Duration", value: log.duration ?? .zero, format: .time(pattern: .minuteSecond(padMinuteToLength: 2, fractionalSecondsLength: 3)))
            LabeledContent("Completed", value: log.isCompleted ? "Yes" : "No")
            if let end = log.end {
                LabeledContent("End Time", value: end, format: .dateTime.hour().minute().second().secondFraction(.fractional(3)))
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
        }
        .contentTransition(.numericText())
    }
}
