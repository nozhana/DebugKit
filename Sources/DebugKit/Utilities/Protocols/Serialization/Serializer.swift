//
//  Serializer.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/6/25.
//

import Foundation

protocol ValueEncoder<Value> {
    associatedtype Value
    static func data(from value: Value) throws -> Data
}

protocol ValueDecoder<Value> {
    associatedtype Value
    static func value(from data: Data) throws -> Value
}

typealias Serializer = ValueEncoder & ValueDecoder

struct JSONSerializer<Value>: Serializer where Value: Codable {
    static func data(from value: Value) throws -> Data {
        try JSONEncoder().encode(value)
    }
    
    static func value(from data: Data) throws -> Value {
        try JSONDecoder().decode(Value.self, from: data)
    }
}
