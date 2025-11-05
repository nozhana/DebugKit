//
//  NetworkLogDTO.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/6/25.
//

import Foundation

struct NetworkLogDTO: Codable {
    var id: UUID
    var request: URLRequestDTO
    var response: HTTPURLResponseDTO?
    var responseData: Data?
    var start: Date
    var end: Date?
    var error: NetworkError?
}

extension NetworkLogDTO {
    init?(log: NetworkLog) {
        guard let request = URLRequestDTO(request: log.request) else { return nil }
        self.id = log.id
        self.request = request
        self.response = log.response.map { .init(response: $0) } ?? nil
        self.responseData = log.responseData
        self.start = log.start
        self.end = log.end
        self.error = log.error
    }
    
    func log() -> NetworkLog {
        .init(id: id,
              request: request.request(),
              response: response?.response(),
              responseData: responseData,
              start: start,
              end: end,
              error: error)
    }
}

extension NetworkLog {
    init(dto: NetworkLogDTO) {
        self = dto.log()
    }
}

struct URLRequestDTO: Codable {
    var url: URL
    var httpMethod: String?
    var httpBody: Data?
    var allHTTPHeaderFields: [String: String]?
    var timeoutInterval: TimeInterval
    var allowsCellularAccess: Bool
    var allowsConstrainedNetworkAccess: Bool
    var allowsExpensiveNetworkAccess: Bool
    var assumesHTTP3Capable: Bool
    var attribution: URLRequest.Attribution
    var cachePolicy: URLRequest.CachePolicy
    var networkServiceType: URLRequest.NetworkServiceType
}

extension URLRequestDTO {
    init?(request: URLRequest) {
        guard let url = request.url else { return nil }
        self.url = url
        self.httpMethod = request.httpMethod
        self.httpBody = request.httpBody
        self.allHTTPHeaderFields = request.allHTTPHeaderFields
        self.timeoutInterval = request.timeoutInterval
        self.allowsCellularAccess = request.allowsCellularAccess
        self.allowsConstrainedNetworkAccess = request.allowsConstrainedNetworkAccess
        self.allowsExpensiveNetworkAccess = request.allowsExpensiveNetworkAccess
        self.assumesHTTP3Capable = request.assumesHTTP3Capable
        self.attribution = request.attribution
        self.cachePolicy = request.cachePolicy
        self.networkServiceType = request.networkServiceType
    }
    
    func request() -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.httpBody = httpBody
        request.allHTTPHeaderFields = allHTTPHeaderFields
        request.timeoutInterval = timeoutInterval
        request.allowsCellularAccess = allowsCellularAccess
        request.allowsConstrainedNetworkAccess = allowsConstrainedNetworkAccess
        request.allowsExpensiveNetworkAccess = allowsExpensiveNetworkAccess
        request.assumesHTTP3Capable = assumesHTTP3Capable
        request.attribution = attribution
        request.cachePolicy = cachePolicy
        request.networkServiceType = networkServiceType
        return request
    }
}

extension URLRequest.Attribution: @retroactive Codable {}
extension URLRequest.CachePolicy: @retroactive Codable {}
extension URLRequest.NetworkServiceType: @retroactive Codable {}

extension URLRequest {
    init(dto: URLRequestDTO) {
        self = dto.request()
    }
}

struct HTTPURLResponseDTO: Codable {
    var url: URL
    var statusCode: Int
    var httpVersion: String = "HTTP/1.1"
    var headerFields: [String: String]?
}

extension HTTPURLResponseDTO {
    init?(response: HTTPURLResponse) {
        guard let url = response.url else { return nil }
        self.url = url
        self.statusCode = response.statusCode
        self.headerFields = response.allHeaderFields as? [String: String]
    }
    
    func response() -> HTTPURLResponse {
        .init(url: url, statusCode: statusCode, httpVersion: httpVersion, headerFields: headerFields)!
    }
}

extension HTTPURLResponse {
    convenience init(dto: HTTPURLResponseDTO) {
        self.init(url: dto.url, statusCode: dto.statusCode, httpVersion: dto.httpVersion, headerFields: dto.headerFields)!
    }
}
