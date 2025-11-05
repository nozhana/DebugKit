//
//  NetworkEventsView.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/4/25.
//

import SwiftUI

struct NetworkEventsView: View {
    @Environment(NetworkLogManager.self) private var manager
    
    var body: some View {
        VStack(spacing: .zero) {
            if manager.events.isEmpty {
                ContentUnavailableView("No Events", systemImage: "circle.dashed")
            } else {
                List(manager.events.indices, id: \.self) { index in
                    if manager.events.indices.contains(index) {
                        let event = manager.events[index]
                        NetworkEventSectionView(event: event)
                    }
                }
            }
        }
        .animation(.smooth, value: manager.events)
        .toolbar {
            Button("Clear", systemImage: "clear", role: .destructive) {
                manager.events.removeAll()
            }
        }
        .navigationTitle("Network Events")
    }
}

#Preview {
    NetworkEventsView()
}

private struct NetworkEventSectionView: View {
    var event: NetworkEvent
    
    var body: some View {
        Section {
            switch event {
            case .taskStarted(let request, _):
                LabeledContent("Request URL", value: request.url?.absoluteString ?? "N/A")
                LabeledContent("HTTP Method", value: request.httpMethod ?? "N/A")
            case .taskDidReceiveResponse(let request, let response, _):
                LabeledContent("Request URL", value: request.url?.absoluteString ?? "N/A")
                LabeledContent("Response URL", value: response.url?.absoluteString ?? "N/A")
                LabeledContent("HTTP Method", value: request.httpMethod ?? "N/A")
                LabeledContent("Response Status", value: NetworkResponseStatus(rawValue: response.statusCode).description)
                let expectedBytes = Measurement(value: Double(response.expectedContentLength), unit: UnitInformationStorage.bytes)
                LabeledContent("Mime Type", value: response.mimeType ?? "N/A")
                LabeledContent("Expected Content Length", value: expectedBytes, format: .byteCount(style: .memory))
            case .taskDidLoadData(let request, let response, let data, _):
                LabeledContent("Request URL", value: request.url?.absoluteString ?? "N/A")
                LabeledContent("Response URL", value: response.url?.absoluteString ?? "N/A")
                LabeledContent("HTTP Method", value: request.httpMethod ?? "N/A")
                LabeledContent("Response Status", value: NetworkResponseStatus(rawValue: response.statusCode).description)
                let expectedBytes = Measurement(value: Double(response.expectedContentLength), unit: UnitInformationStorage.bytes)
                LabeledContent("Mime Type", value: response.mimeType ?? "N/A")
                LabeledContent("Expected Content Length", value: expectedBytes, format: .byteCount(style: .memory))
                let chunk = Measurement(value: Double(data.count), unit: UnitInformationStorage.bytes)
                LabeledContent("Received Chunk", value: chunk, format: .byteCount(style: .memory))
            case .taskDidFinishSuccessfully(let request, let response, let data, _):
                LabeledContent("Request URL", value: request.url?.absoluteString ?? "N/A")
                LabeledContent("Response URL", value: response.url?.absoluteString ?? "N/A")
                LabeledContent("HTTP Method", value: request.httpMethod ?? "N/A")
                LabeledContent("Response Status", value: NetworkResponseStatus(rawValue: response.statusCode).description)
                let expectedBytes = Measurement(value: Double(response.expectedContentLength), unit: UnitInformationStorage.bytes)
                LabeledContent("Mime Type", value: response.mimeType ?? "N/A")
                LabeledContent("Expected Content Length", value: expectedBytes, format: .byteCount(style: .memory))
                let dataBytes = Measurement(value: Double(data.count), unit: UnitInformationStorage.bytes)
                LabeledContent("Total Received Data", value: dataBytes, format: .byteCount(style: .memory))
            case .taskDidFailWithError(let request, let response, let error, let data, _):
                LabeledContent("Request URL", value: request.url?.absoluteString ?? "N/A")
                LabeledContent("Response URL", value: response?.url?.absoluteString ?? "N/A")
                LabeledContent("HTTP Method", value: request.httpMethod ?? "N/A")
                if let response {
                    LabeledContent("Response Status", value: NetworkResponseStatus(rawValue: response.statusCode).description)
                    let expectedBytes = Measurement(value: Double(response.expectedContentLength), unit: UnitInformationStorage.bytes)
                    LabeledContent("Mime Type", value: response.mimeType ?? "N/A")
                    LabeledContent("Expected Content Length", value: expectedBytes, format: .byteCount(style: .memory))
                } else {
                    LabeledContent("Response Status", value: "N/A")
                    LabeledContent("Mime Type", value: "N/A")
                    LabeledContent("Expected Content Length", value: "N/A")
                }
                if let data {
                    let dataBytes = Measurement(value: Double(data.count), unit: UnitInformationStorage.bytes)
                    LabeledContent("Total Received Data", value: dataBytes, format: .byteCount(style: .memory))
                } else {
                    LabeledContent("Total Received Data", value: "N/A")
                }
                LabeledContent("Error", value: error.localizedDescription)
            }
            LabeledContent("Timestamp", value: event.timestamp, format: .dateTime.hour().minute().second().secondFraction(.fractional(3)))
        } header: {
            Label(event.title, systemImage: event.systemImage)
                .foregroundStyle(event.color.gradient)
        }
    }
}
