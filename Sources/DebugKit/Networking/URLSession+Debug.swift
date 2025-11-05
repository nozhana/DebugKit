//
//  URLSession+Debug.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/4/25.
//

import Foundation

extension URLSession {
    public static let debug = URLSession(configuration: .debug)
}

extension URLSessionConfiguration {
    public static let debug = {
        defer {
            DispatchQueue.main.async {
                _ = NetworkLogManager.shared
            }
        }
        let config = URLSessionConfiguration.default
        config.protocolClasses = [NetworkLoggerProtocol.self]
        return config
    }()
}
