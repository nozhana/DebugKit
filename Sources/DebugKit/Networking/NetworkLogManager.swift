//
//  NetworkLogManager.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/4/25.
//

import Combine
import Foundation

@Observable
final class NetworkLogManager {
    @ObservationIgnored
    private let notificationCenter = NotificationCenter.default
    
    var logs = Queue<NetworkLog>()
    var events = Queue<NetworkEvent>(capacity: 50)
    
    private(set) var persistedLogs = Queue<NetworkLog>()
    
    @ObservationIgnored
    private var cancellables: Set<AnyCancellable> = []
    
    @ObservationIgnored
    private let persistentLogsObserver = FileSystemObserver(path: .networkLogs)
    
    @ObservationIgnored
    @MainActor
    static let shared = NetworkLogManager()
    
    private init() {
        setupBindings()
        retrievePersistedLogs()
    }
    
    func persist(_ log: NetworkLog) {
        guard let dto = NetworkLogDTO(log: log),
              let data = try? JSONEncoder().encode(dto) else { return }
        let url = URL.networkLogs.appendingPathComponent(log.id.uuidString, conformingTo: .json)
        try? FileManager.default.removeItem(at: url)
        try? data.write(to: url)
    }
    
    func removePersistedLog(_ log: NetworkLog) {
        let url = URL.networkLogs.appendingPathComponent(log.id.uuidString, conformingTo: .json)
        try? FileManager.default.removeItem(at: url)
    }
    
    private func retrievePersistedLogs() {
        guard let contents = try? FileManager.default.contentsOfDirectory(at: .networkLogs, includingPropertiesForKeys: nil) else { return }
        persistedLogs = contents.reduce(into: []) { partialResult, url in
            guard let data = try? Data(contentsOf: url),
                  let dto = try? JSONDecoder().decode(NetworkLogDTO.self, from: data) else { return }
            let log = NetworkLog(dto: dto)
            partialResult.push(log)
        }
    }
    
    private func setupBindings() {
        persistentLogsObserver.onEvent(perform: retrievePersistedLogs)
        
        notificationCenter.publisher(for: .networkTaskStarted)
            .receive(on: RunLoop.main)
            .sink { [weak self] notification in
                guard let self,
                      let userInfo = notification.userInfo as? [String: Any],
                      let id = userInfo["id"] as? UUID,
                      let request = userInfo["request"] as? URLRequest,
                      let timestamp = userInfo["timestamp"] as? CFAbsoluteTime else { return }
                let date = Date(timeIntervalSinceReferenceDate: timestamp)
                let log = NetworkLog(id: id, request: request, start: date)
                logs.removeAll(where: { $0.id == id })
                logs.push(log)
                
                let event = NetworkEvent.taskStarted(request: request, timestamp: date)
                events.push(event)
                
            }
            .store(in: &cancellables)
        
        notificationCenter.publisher(for: .networkTaskDidReceiveResponse)
            .receive(on: RunLoop.main)
            .sink { [weak self] notification in
                guard let self,
                      let userInfo = notification.userInfo as? [String: Any],
                      let id = userInfo["id"] as? UUID,
                      let request = userInfo["request"] as? URLRequest,
                      let response = userInfo["response"] as? HTTPURLResponse else { return }
                let date = Date.now
                if let logIndex = logs.firstIndex(where: { $0.id == id }) {
                    var log = logs[logIndex]
                    guard !log.isCompleted else { return }
                    log.response = response
                    logs[logIndex] = log
                } else {
                    let log = NetworkLog(id: id, request: request, response: response, start: date)
                    logs.removeAll(where: { $0.id == id })
                    logs.push(log)
                }
                
                let event = NetworkEvent.taskDidReceiveResponse(request: request, response: response, timestamp: date)
                events.push(event)
            }
            .store(in: &cancellables)
        
        notificationCenter.publisher(for: .networkTaskDidLoadData)
            .receive(on: RunLoop.main)
            .sink { [weak self] notification in
                guard let self,
                      let userInfo = notification.userInfo as? [String: Any],
                      let id = userInfo["id"] as? UUID,
                      let request = userInfo["request"] as? URLRequest,
                      let data = userInfo["data"] as? Data,
                      let response = userInfo["response"] as? HTTPURLResponse else { return }
                let date = Date.now
                if let logIndex = logs.firstIndex(where: { $0.id == id }) {
                    var log = logs[logIndex]
                    guard !log.isCompleted else { return }
                    if let currentData = log.responseData {
                        log.responseData = currentData + data
                    } else {
                        log.responseData = data
                    }
                    log.response = response
                    logs[logIndex] = log
                } else {
                    let log = NetworkLog(id: id, request: request, response: response, responseData: data, start: date)
                    logs.removeAll(where: { $0.id == id })
                    logs.push(log)
                }
                
                let event = NetworkEvent.taskDidLoadData(request: request, response: response, data: data, timestamp: date)
                events.push(event)
            }
            .store(in: &cancellables)
        
        notificationCenter.publisher(for: .networkTaskFinished)
            .receive(on: RunLoop.main)
            .sink { [weak self] notification in
                guard let self,
                      let userInfo = notification.userInfo as? [String: Any],
                      let id = userInfo["id"] as? UUID,
                      let request = userInfo["request"] as? URLRequest,
                      let timestamp = userInfo["timestamp"] as? CFAbsoluteTime else { return }
                let data = userInfo["data"] as? Data
                let response = userInfo["response"] as? HTTPURLResponse
                
                let date = Date(timeIntervalSinceReferenceDate: timestamp)
                if let logIndex = logs.firstIndex(where: { $0.id == id }) {
                    var log = logs[logIndex]
                    guard !log.isCompleted else { return }
                    log.request = request
                    log.responseData = data
                    log.response = response
                    log.end = date
                    
                    if let error = userInfo["error"] as? URLError {
                        log.error = .urlError(error)
                        events.push(.taskDidFailWithError(request: request, response: response, error: .urlError(error), data: data, timestamp: date))
                    } else if let response,
                              let error = NetworkError(rawValue: response.statusCode) {
                        log.error = error
                        events.push(.taskDidFailWithError(request: request, response: response, error: error, data: data, timestamp: date))
                    } else if let response, let data {
                        events.push(.taskDidFinishSuccessfully(request: request, response: response, data: data, timestamp: date))
                    }
                    logs[logIndex] = log
                } else {
                    var log = NetworkLog(id: id, request: request, response: response, responseData: data, start: date, end: date)
                    if let error = userInfo["error"] as? URLError {
                        log.error = .urlError(error)
                        events.push(.taskDidFailWithError(request: request, response: response, error: .urlError(error), data: data, timestamp: date))
                    } else if let response,
                              let error = NetworkError(rawValue: response.statusCode) {
                        log.error = error
                        events.push(.taskDidFailWithError(request: request, response: response, error: error, data: data, timestamp: date))
                    } else if let response,
                              let data {
                        events.push(.taskDidFinishSuccessfully(request: request, response: response, data: data, timestamp: date))
                    }
                    logs.removeAll(where: { $0.id == id })
                    logs.push(log)
                }
            }
            .store(in: &cancellables)
    }
}
