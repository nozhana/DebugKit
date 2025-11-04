//
//  NetworkLoggerProtocol.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/3/25.
//

import Foundation
import OSLog

extension Logger {
    static let networking = Logger(subsystem: "com.nozhana.DebugKit", category: "networking")
}

final class NetworkLoggerProtocol: URLProtocol, @unchecked Sendable {
    private static let ignoredURLs: [String] = []
    
    private lazy var session: URLSession = .init(configuration: .default, delegate: self, delegateQueue: nil)
    
    private var id: UUID?
    private var responseData: NSMutableData?
    private var response: URLResponse?
    
    override class func canInit(with request: URLRequest) -> Bool {
        canServeRequest(request)
    }
    
    override class func canInit(with task: URLSessionTask) -> Bool {
        guard let request = task.currentRequest else { return false }
        return canServeRequest(request)
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }
    
    override func startLoading() {
        session.dataTask(with: request).resume()
    }
    
    override func stopLoading() {
        session.getTasksWithCompletionHandler { tasks, _, _ in
            tasks.forEach { $0.cancel() }
            self.session.invalidateAndCancel()
        }
    }
    
    // MARK: - Private
    private class func canServeRequest(_ request: URLRequest) -> Bool {
        guard let url = request.url,
              (url.absoluteString.hasPrefix("http") || url.absoluteString.hasPrefix("https")) else {
            return false
        }
        
        let absoluteString = url.absoluteString
        guard !ignoredURLs.contains(where: { absoluteString.hasPrefix($0) }) else { return false }
        
        return true
    }
}

extension NetworkLoggerProtocol: URLSessionDataDelegate {
    private func postNotification(_ name: Notification.Name, _ userInfo: [String: Any]? = nil) {
        NotificationCenter.default.post(name: name, object: nil, userInfo: userInfo)
    }
    
    func urlSession(_ session: URLSession, didCreateTask task: URLSessionTask) {
        let timestamp = CFAbsoluteTimeGetCurrent()
        
        guard let request = task.currentRequest ?? task.originalRequest,
              let url = request.url else { return }
        Logger.networking.info("Started task for \(url.absoluteString)")
        id = UUID()
        let userInfo: [String: Any] = [
            "id": id!,
            "request": request,
            "timestamp": timestamp
        ]
        postNotification(.networkTaskStarted, userInfo)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        responseData?.append(data)
        client?.urlProtocol(self, didLoad: data)
        var userInfo = [String: Any]()
        userInfo["data"] = data
        if let request = dataTask.currentRequest ?? dataTask.originalRequest {
            userInfo["request"] = request
        }
        if let response {
            userInfo["response"] = response
        }
        if let id {
            userInfo["id"] = id
        }
        postNotification(.networkTaskDidLoadData, userInfo)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        self.response = response
        self.responseData = NSMutableData()
        
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .allowed)
        var userInfo = [String: Any]()
        userInfo["response"] = response
        if let request = dataTask.currentRequest ?? dataTask.originalRequest {
            userInfo["request"] = request
        }
        if let id {
            userInfo["id"] = id
        }
        postNotification(.networkTaskDidReceiveResponse, userInfo)
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        let timestamp = CFAbsoluteTimeGetCurrent()
        
        defer {
            if let error {
                client?.urlProtocol(self, didFailWithError: error)
            } else {
                client?.urlProtocolDidFinishLoading(self)
            }
        }
        
        let request = task.currentRequest ?? task.originalRequest
        
        var userInfo = [String: Any]()
        userInfo["timestamp"] = timestamp
        userInfo["request"] = request
        
        if let id {
            userInfo["id"] = id
            self.id = nil
        }
        
        if let error {
            userInfo["error"] = error
            Logger.networking.error("Request \(request?.url?.absoluteString ?? "N/A") failed with error: \(error)")
        }
        if let response {
            let data = (responseData ?? NSMutableData()) as Data
            userInfo["response"] = response
            userInfo["data"] = data
            Logger.networking.info("Request \(request?.url?.absoluteString ?? "N/A") completed: \(response)\nData: \(data)")
            if let json = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed),
               let prettyData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
               let prettyString = String(data: prettyData, encoding: .utf8) {
                Logger.networking.info("Pretty-printed response:\n\(prettyString)")
            }
        }
        postNotification(.networkTaskFinished, userInfo)
    }
}
