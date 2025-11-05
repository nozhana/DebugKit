//
//  NetworkError.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/3/25.
//

import Foundation

enum NetworkError: RawRepresentable, LocalizedError, CustomStringConvertible, Equatable, Codable {
    case urlError(URLError)
    case clientError(ClientError)
    case serverError(ServerError)
    
    var errorCode: Int { rawValue }
    
    var errorDescription: String? { description }
    
    var shortDescription: String {
        switch self {
        case .urlError(let urlError):
            "URLError \(urlError.errorCode)"
        default: description
        }
    }
    
    var description: String {
        switch self {
        case .urlError(let urlError):
            urlError.localizedDescription
        case .clientError(let clientError):
            clientError.localizedDescription
        case .serverError(let serverError):
            serverError.localizedDescription
        }
    }
    
    var systemImage: String {
        switch self {
        case .urlError: "cube"
        case .clientError: "exclamationmark.circle.fill"
        case .serverError: "exclamationmark.icloud.fill"
        }
    }
    
    init?(rawValue: Int) {
        if let clientError = ClientError(rawValue: rawValue) {
            self = .clientError(clientError)
        } else if let serverError = ServerError(rawValue: rawValue) {
            self = .serverError(serverError)
        } else if !(100..<400).contains(rawValue) {
            self = .urlError(.init(.init(rawValue: rawValue)))
        } else {
            return nil
        }
    }
    
    var rawValue: Int {
        switch self {
        case .urlError(let urlError):
            urlError.errorCode
        case .clientError(let clientError):
            clientError.rawValue
        case .serverError(let serverError):
            serverError.rawValue
        }
    }
    
    init(_ urlErrorCode: URLError.Code) {
        self = .urlError(.init(urlErrorCode))
    }
    
    init(_ clientError: ClientError) {
        self = .clientError(clientError)
    }
    
    init(_ serverError: ServerError) {
        self = .serverError(serverError)
    }
    
    enum ClientError: Int, LocalizedError, CustomStringConvertible, Codable {
        case badRequest = 400
        case unauthorized = 401
        case paymentRequired = 402
        case forbidden = 403
        case notFound = 404
        case methodNotAllowed = 405
        case notAcceptable = 406
        case proxyAuthenticationRequired = 407
        case requestTimeout = 408
        case conflict = 409
        case gone = 410
        case lengthRequired = 411
        case preconditionFailed = 412
        case payloadTooLarge = 413
        case uriTooLong = 414
        case unsupportedMediaType = 415
        case rangeNotSatisfiable = 416
        case expectationFailed = 417
        case imATeapot = 418
        case misdirectedRequest = 421
        case unprocessableContent = 422
        case locked = 423
        case failedDependency = 424
        case tooEarly = 425
        case upgradeRequired = 426
        case preconditionRequired = 428
        case tooManyRequests = 429
        case requestHeaderFieldsTooLarge = 431
        case unavailableForLegalReasons = 451
        
        // Internet Information Services
        case iisLoginTimeout = 440
        case iisRetryWith = 449
        case iisBlockedByWindowsParentalControls = 450
        
        // Nginx
        case nginxNoResponse = 444
        case nginxRequestHeaderTooLarge = 494
        case nginxSSLCertificateError = 495
        case nginxSSLCertificateRequired = 496
        case nginxHttpRequestSentToHttpsPort = 497
        case nginxClientClosedRequest = 499
        
        var errorCode: Int { rawValue }
        
        var errorDescription: String? { description }
        
        var description: String {
            switch self {
            case .badRequest: "400 Bad Request"
            case .unauthorized: "401 Unauthorized"
            case .paymentRequired: "402 Payment Required"
            case .forbidden: "403 Forbidden"
            case .notFound: "404 Not Found"
            case .methodNotAllowed: "405 Method Not Allowed"
            case .notAcceptable: "406 Not Acceptable"
            case .proxyAuthenticationRequired: "407 Proxy Authentication Required"
            case .requestTimeout: "408 Request Timeout"
            case .conflict: "409 Conflict"
            case .gone: "410 Gone"
            case .lengthRequired: "411 Length Required"
            case .preconditionFailed: "412 Precondition Failed"
            case .payloadTooLarge: "413 Payload Too Large"
            case .uriTooLong: "414 URI Too Long"
            case .unsupportedMediaType: "415 Unsupported Media Type"
            case .rangeNotSatisfiable: "416 Range Not Satisfiable"
            case .expectationFailed: "417 Expectation Failed"
            case .imATeapot: "418 I'm A Teapot"
            case .misdirectedRequest: "421 Misdirected Request"
            case .unprocessableContent: "422 Unprocessable Content"
            case .locked: "423 Locked"
            case .failedDependency: "424 Failed Dependency"
            case .tooEarly: "425 Too Early"
            case .upgradeRequired: "426 Upgrade Required"
            case .preconditionRequired: "428 Precondition Required"
            case .tooManyRequests: "429 Too Many Requests"
            case .requestHeaderFieldsTooLarge: "431 Request Header Fields Too Large"
            case .unavailableForLegalReasons: "451 Unavailable For Legal Reasons"
                
            case .iisLoginTimeout: "440 Login Timeout (IIS)"
            case .iisRetryWith: "449 Retry With (IIS)"
            case .iisBlockedByWindowsParentalControls: "450 Blocked By Windows Parental Controls (IIS)"
                
            case .nginxNoResponse: "444 No Response (Nginx)"
            case .nginxRequestHeaderTooLarge: "494 Request Header Too Large (Nginx)"
            case .nginxSSLCertificateError: "495 SSL Certificate Error (Nginx)"
            case .nginxSSLCertificateRequired: "496 SSL Certificate Required (Nginx)"
            case .nginxHttpRequestSentToHttpsPort: "497 HTTP Request Sent to HTTPS Port (Nginx)"
            case .nginxClientClosedRequest: "499 Client Closed Request (Nginx)"
            }
        }
    }
    
    enum ServerError: Int, LocalizedError, CustomStringConvertible, Codable {
        case internalServerError = 500
        case notImplemented = 501
        case badGateway = 502
        case serviceUnavailable = 503
        case gatewayTimeout = 504
        case httpVersionNotSupported = 505
        case variantAlsoNegotiates = 506
        case insufficientStorage = 507
        case loopDetected = 508
        case notExtended = 510
        case networkAuthenticationRequired = 511
        
        // Cloudflare
        case cfWebServerReturnedAnUnknownError = 520
        case cfWebServerIsDown = 521
        case cfConnectionTimedOut = 522
        case cfOriginIsUnreachable = 523
        case cfTimeoutOccurred = 524
        case cfSSLHandshakeFailed = 525
        case cfInvalidSSLCertificate = 526
        case cfRailgunError = 527
        case cfOriginUnavailable = 530
        
        var errorCode: Int { rawValue }
        
        var errorDescription: String? { description }
        
        var description: String {
            switch self {
            case .internalServerError: "500 Internal Server Error"
            case .notImplemented: "501 Not Implemented"
            case .badGateway: "502 Bad Gateway"
            case .serviceUnavailable: "503 Service Unavailable"
            case .gatewayTimeout: "504 Gateway Timeout"
            case .httpVersionNotSupported: "505 HTTP Version Not Supported"
            case .variantAlsoNegotiates: "506 Variant Also Negotiates"
            case .insufficientStorage: "507 Insufficient Storage"
            case .loopDetected: "508 Loop Detected"
            case .notExtended: "510 Not Extended"
            case .networkAuthenticationRequired: "511 Network Authentication Required"
                
            case .cfWebServerReturnedAnUnknownError: "520 Web Server Returned an Unknown Error (Cloudflare)"
            case .cfWebServerIsDown: "521 Web Server Is Down (Cloudflare)"
            case .cfConnectionTimedOut: "522 Connection Timed Out (Cloudflare)"
            case .cfOriginIsUnreachable: "523 Origin Is Unreachable (Cloudflare)"
            case .cfTimeoutOccurred: "524 Timeout Occurred (Cloudflare)"
            case .cfSSLHandshakeFailed: "525 SSL Handshake Failed (Cloudflare)"
            case .cfInvalidSSLCertificate: "526 Invalid SSL Certificate (Cloudflare)"
            case .cfRailgunError: "527 Railgun Error (Cloudflare)"
            case .cfOriginUnavailable: "530 Origin Unavailable (Cloudflare)"
            }
        }
    }
}
