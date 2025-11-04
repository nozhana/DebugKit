//
//  NetworkEvent.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/4/25.
//

import SwiftUI

enum NetworkEvent: Equatable {
    case taskStarted(request: URLRequest, timestamp: Date)
    case taskDidReceiveResponse(request: URLRequest, response: HTTPURLResponse, timestamp: Date)
    case taskDidLoadData(request: URLRequest, response: HTTPURLResponse, data: Data, timestamp: Date)
    case taskDidFinishSuccessfully(request: URLRequest, response: HTTPURLResponse, data: Data, timestamp: Date)
    case taskDidFailWithError(request: URLRequest, response: HTTPURLResponse?, error: NetworkError, data: Data?, timestamp: Date)
}

extension NetworkEvent: CustomStringConvertible {
    var description: String {
        switch self {
        case .taskStarted(let request, _):
            "Task Started for \(request.url?.absoluteString ?? "N/A")"
        case .taskDidReceiveResponse(let request, let response, _):
            "Received response for \(request.url?.absoluteString ?? "N/A")\n\(NetworkResponseStatus(rawValue: response.statusCode))"
        case .taskDidLoadData(let request, _, let data, _):
            "Loaded data for \(request.url?.absoluteString ?? "N/A")\n\(data)"
        case .taskDidFinishSuccessfully(let request, let response, let data, _):
            "Task Finished Successfully: \(request.url?.absoluteString ?? "N/A")\n\(NetworkResponseStatus(rawValue: response.statusCode))\n\(data)"
        case .taskDidFailWithError(let request, let response, let error, let data, _):
            "Task Failed for \(request.url?.absoluteString ?? "N/A")\n\(error.localizedDescription)\n\(response.map { NetworkResponseStatus(rawValue: $0.statusCode) })\n\("\(data?.count ?? 0) Bytes")"
        }
    }
    
    var title: String {
        switch self {
        case .taskStarted: "Task Started"
        case .taskDidReceiveResponse: "Received Response"
        case .taskDidLoadData: "Loaded Data"
        case .taskDidFinishSuccessfully: "Task Finished"
        case .taskDidFailWithError: "Task Failed"
        }
    }
    
    var systemImage: String {
        switch self {
        case .taskStarted: "play.fill"
        case .taskDidReceiveResponse: "tray.fill"
        case .taskDidLoadData: "arrow.down.circle.dotted"
        case .taskDidFinishSuccessfully: "checkmark.circle.fill"
        case .taskDidFailWithError: "exclamationmark.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .taskStarted: .blue
        case .taskDidReceiveResponse: .mint
        case .taskDidLoadData: .purple
        case .taskDidFinishSuccessfully: .green
        case .taskDidFailWithError: .red
        }
    }
    
    var timestamp: Date {
        switch self {
        case .taskStarted(_, let timestamp),
                .taskDidReceiveResponse(_, _, let timestamp),
                .taskDidLoadData(_, _, _, let timestamp),
                .taskDidFinishSuccessfully(_, _, _, let timestamp),
                .taskDidFailWithError(_, _, _, _, let timestamp):
            timestamp
        }
    }
}
