//
//  URLSession+Debug.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/4/25.
//

import Foundation

extension URLSession {
    public static let debug = {
        let config = URLSessionConfiguration.default
        config.protocolClasses = [NetworkLoggerProtocol.self]
        return URLSession(configuration: config)
    }()
}
