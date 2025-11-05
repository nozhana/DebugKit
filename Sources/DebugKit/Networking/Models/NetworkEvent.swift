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

extension NetworkEvent {
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
