//
//  NetworkLogSerializer.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/6/25.
//

import Foundation

struct NetworkLogSerializer: Serializer {
    static func value(from data: Data) throws -> NetworkLog {
        let dto = try JSONDecoder().decode(NetworkLogDTO.self, from: data)
        return NetworkLog(dto: dto)
    }
    
    static func data(from value: NetworkLog) throws -> Data {
        let dto = NetworkLogDTO(log: value)
        return try JSONEncoder().encode(dto)
    }
}
