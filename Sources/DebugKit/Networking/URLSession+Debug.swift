//
//  URLSession+Debug.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/4/25.
//

import Foundation

extension URLSession {
    /// Shared debugging ``Foundation/URLSession`` object.
    ///
    /// All requests made using this instance will be monitored in the Debug Menu.
    ///
    /// If you need to create a custom ``Foundation/URLSession`` instance, use the ``Foundation/URLSessionConfiguration/debug`` configuration like so:
    /// ```swift
    /// // Simple instance
    /// let session = URLSession(configuration: .debug)
    ///
    /// // Customized instance
    /// let session = {
    ///     let configuration = URLSessionConfiguration.debug
    ///     // configuration.httpAdditionalHeaders = ["Authorization": "Bearer eyjxxxxxxxxxxxxxxx"]
    ///     // Modifications...
    ///     return URLSession(configuration: configuration)
    /// }()
    /// ```
    ///
    /// - SeeAlso: `URLSessionConfiguration.`‌``Foundation/URLSessionConfiguration/debug``
    public static let debug = URLSession(configuration: .debug)
}

extension URLSessionConfiguration {
    /// Shared debugging ``Foundation/URLSessionConfiguration`` object.
    ///
    /// All sessions created using this configuration will be monitored in the Debug Menu.
    ///
    /// If you don't need to create a separate ``Foundation/URLSession`` instance, check out the shared ``Foundation/URLSession/debug`` session.
    ///
    /// - SeeAlso: `URLSession.`‌``Foundation/URLSession/debug``
    public static let debug = {
        defer {
            DispatchQueue.main.async {
                DebugMenuView.initialize()
            }
        }
        let config = URLSessionConfiguration.default
        config.protocolClasses = [NetworkLoggerProtocol.self]
        return config
    }()
}
