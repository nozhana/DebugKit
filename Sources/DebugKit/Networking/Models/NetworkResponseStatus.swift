//
//  NetworkResponseStatus.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/3/25.
//

import SwiftUI

enum NetworkResponseStatus: RawRepresentable, CustomStringConvertible {
    case informational(Informational)
    case success(Success)
    case redirection(Redirection)
    case clientError(ClientError)
    case serverError(ServerError)
    case unknown(statusCode: Int)
    
    var description: String {
        switch self {
        case .informational(let informational): informational.description
        case .success(let success): success.description
        case .redirection(let redirection): redirection.description
        case .clientError(let clientError): clientError.description
        case .serverError(let serverError): serverError.description
        case .unknown(let statusCode): "Unknown status: \(statusCode)"
        }
    }
    
    init(rawValue: Int) {
        if let informational = Informational(rawValue: rawValue) {
            self = .informational(informational)
        } else if let success = Success(rawValue: rawValue) {
            self = .success(success)
        } else if let redirection = Redirection(rawValue: rawValue) {
            self = .redirection(redirection)
        } else if let clientError = ClientError(rawValue: rawValue) {
            self = .clientError(clientError)
        } else if let serverError = ServerError(rawValue: rawValue) {
            self = .serverError(serverError)
        } else {
            self = .unknown(statusCode: rawValue)
        }
    }
    
    var rawValue: Int {
        switch self {
        case .informational(let informational): informational.rawValue
        case .success(let success): success.rawValue
        case .redirection(let redirection): redirection.rawValue
        case .clientError(let clientError): clientError.rawValue
        case .serverError(let serverError): serverError.rawValue
        case .unknown(let statusCode): statusCode
        }
    }
    
    var systemImage: String {
        switch self {
        case .informational: "info.circle.fill"
        case .success: "checkmark.circle.fill"
        case .redirection: "arrowshape.turn.up.right.circle.fill"
        case .clientError: "exclamationmark.circle.fill"
        case .serverError: "exclamationmark.icloud.fill"
        case .unknown: "questionmark.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .informational: .yellow
        case .success: .green
        case .redirection: .orange
        case .clientError: .red
        case .serverError: .red
        case .unknown: .purple
        }
    }
    
    init(_ informational: Informational) {
        self = .informational(informational)
    }
    
    init(_ success: Success) {
        self = .success(success)
    }
    
    init(_ redirection: Redirection) {
        self = .redirection(redirection)
    }
    
    init(_ clientError: ClientError) {
        self = .clientError(clientError)
    }
    
    init(_ serverError: ServerError) {
        self = .serverError(serverError)
    }
    
    enum Informational: Int, CustomStringConvertible {
        case `continue` = 100
        case switchingProtocols = 101
        case processing = 102
        case earlyHints = 103
        
        var description: String {
            switch self {
            case .continue: "100 Continue"
            case .switchingProtocols: "101 Switching Protocols"
            case .processing: "102 Processing"
            case .earlyHints: "103 Early Hints"
            }
        }
    }
    
    enum Success: Int, CustomStringConvertible {
        case ok = 200
        case created = 201
        case accepted = 202
        case nonAuthoritativeInformation = 203
        case noContent = 204
        case resetContent = 205
        case partialContent = 206
        case multiStatus = 207
        case alreadyReported = 208
        case IMUsed = 226
        
        var description: String {
            switch self {
            case .ok: "200 OK"
            case .created: "201 Created"
            case .accepted: "202 Accepted"
            case .nonAuthoritativeInformation: "203 Non-Authoritative Information"
            case .noContent: "204 No Content"
            case .resetContent: "205 Reset Content"
            case .partialContent: "206 Partial Content"
            case .multiStatus: "207 Multi-Status"
            case .alreadyReported: "208 Already Reported"
            case .IMUsed: "226 IM Used"
            }
        }
    }
    
    enum Redirection: Int, CustomStringConvertible {
        case multipleChoices = 300
        case movedPermanently = 301
        case found = 302
        case seeOther = 303
        case notModified = 304
        case useProxy = 305
        case switchProxy = 306
        case temporaryRedirect = 307
        case permanentRedirect = 308
        
        var description: String {
            switch self {
            case .multipleChoices: "300 Multiple Choices"
            case .movedPermanently: "301 Moved Permanently"
            case .found: "302 Found"
            case .seeOther: "303 See Other"
            case .notModified: "304 Not Modified"
            case .useProxy: "305 Use Proxy"
            case .switchProxy: "306 Switch Proxy"
            case .temporaryRedirect: "307 Temporary Redirect"
            case .permanentRedirect: "308 Permanent Redirect"
            }
        }
    }
    
    typealias ClientError = NetworkError.ClientError
    typealias ServerError = NetworkError.ServerError
}
