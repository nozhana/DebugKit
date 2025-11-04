//
//  AnyJSON.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/4/25.
//

import Foundation

typealias AnyJSONArray = [AnyJSON]
typealias AnyJSONObject = [String: AnyJSON]

enum AnyJSON: RawRepresentable, Codable {
    case null
    case bool(Bool)
    case int(Int)
    case double(Double)
    case date(Date)
    case string(String)
    indirect case array(AnyJSONArray)
    indirect case object(AnyJSONObject)
    
    var rawValue: String {
        switch self {
        case .null: "null"
        case .bool(let bool): bool ? "true" : "false"
        case .int(let int): String(int)
        case .double(let double): String(double)
        case .date(let date): date.formatted(.iso8601)
        case .string(let string): string
        case .array(let array): "[" + array.map(\.rawValue).joined(separator: ", ") + "]"
        case .object(let object): "{" + object.mapValues(\.rawValue).map({ "\($0.key):\($0.value)" }).joined(separator: ", ") + "}"
        }
    }
    
    init(rawValue: String) {
        if rawValue == "null" {
            self = .null
        } else if let int = Int(rawValue) {
            self = .int(int)
        } else if let double = Double(rawValue) {
            self = .double(double)
        } else if let date = (try? Date(rawValue, strategy: .dateTime)) ?? (try? Date(rawValue, strategy: .iso8601)) {
            self = .date(date)
        } else {
            guard let data = rawValue.data(using: .utf8) else {
                self = .string(rawValue)
                return
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            if let array = try? decoder.decode(AnyJSONArray.self, from: data) {
                self = .array(array)
            } else if let object = try? decoder.decode(AnyJSONObject.self, from: data) {
                self = .object(object)
            } else {
                self = .string(rawValue)
            }
        }
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            self = .null
        } else if let bool = try? container.decode(Bool.self) {
            self = .bool(bool)
        } else if let int = try? container.decode(Int.self) {
            self = .int(int)
        } else if let double = try? container.decode(Double.self) {
            self = .double(double)
        } else if let date = try? container.decode(Date.self) {
            self = .date(date)
        } else if let string = try? container.decode(String.self) {
            if let date = (try? Date(string, strategy: .dateTime)) ?? (try? Date(string, strategy: .iso8601)) {
                self = .date(date)
            } else {
                self = .string(string)
            }
        } else if let array = try? container.decode(AnyJSONArray.self) {
            self = .array(array)
        } else if let object = try? container.decode(AnyJSONObject.self) {
            self = .object(object)
        } else {
            throw DecodingError.dataCorrupted(.init(codingPath: container.codingPath, debugDescription: "Invalid JSON data.\nUser Info: \(decoder.userInfo)"))
        }
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .null:
            try container.encodeNil()
        case .bool(let value):
            try container.encode(value)
        case .int(let value):
            try container.encode(value)
        case .double(let value):
            try container.encode(value)
        case .date(let date):
            try container.encode(date.formatted(.iso8601))
        case .string(let value):
            try container.encode(value)
        case .array(let value):
            try container.encode(value)
        case .object(let value):
            try container.encode(value)
        }
    }
}

extension AnyJSON: ExpressibleByNilLiteral {
    init(nilLiteral: ()) {
        self = .null
    }
}

extension AnyJSON: ExpressibleByBooleanLiteral {
    init(booleanLiteral value: Bool) {
        self = .bool(value)
    }
}

extension AnyJSON: ExpressibleByIntegerLiteral {
    init(integerLiteral value: Int) {
        self = .int(value)
    }
}

extension AnyJSON: ExpressibleByFloatLiteral {
    init(floatLiteral value: Double) {
        self = .double(value)
    }
}

extension AnyJSON: ExpressibleByStringLiteral {
    init(stringLiteral value: String) {
        self = .string(value)
    }
}

extension AnyJSON: ExpressibleByArrayLiteral {
    init(arrayLiteral elements: AnyJSON...) {
        self = .array(elements)
    }
}

extension AnyJSON: ExpressibleByDictionaryLiteral {
    init(dictionaryLiteral elements: (String, AnyJSON)...) {
        self = .object(Dictionary(elements) { $1 })
    }
}
