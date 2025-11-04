//
//  NetworkLog.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/3/25.
//

import Foundation

struct NetworkLog: Identifiable, Equatable {
    var id = UUID()
    var request: URLRequest
    var response: HTTPURLResponse?
    var responseData: Data?
    var start: Date
    var end: Date?
    var error: NetworkError?
}

extension NetworkLog {
    var isCompleted: Bool {
        get { end != nil }
        set { end = newValue ? .now : nil }
    }
    
    var duration: Duration? {
        .seconds((end ?? .now).timeIntervalSince(start))
    }
    
    var progress: Double? {
        if isCompleted { return 1 }
        guard let response else { return nil }
        guard let responseData else { return .zero }
        return min(1, max(0, Double(responseData.count) / Double(response.expectedContentLength)))
    }
    
    var url: URL? {
        request.url
    }
    
    var responseStatus: NetworkResponseStatus? {
        guard let response else { return nil }
        return .init(rawValue: response.statusCode)
    }
    
    var prettyPrintedJSON: String? {
        guard isCompleted,
              let responseData,
              let jsonObject = try? JSONSerialization.jsonObject(with: responseData, options: [.fragmentsAllowed]),
              let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted, .sortedKeys]),
              let prettyString = String(data: prettyData, encoding: .utf8) else { return nil }
        return prettyString
    }
    
    var decodedResponse: AnyJSONObject? {
        guard let responseData else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(AnyJSONObject.self, from: responseData)
    }
}
