//
//  SystemInformationManager.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/7/25.
//

import Foundation
import Combine
import QuartzCore
import UIKit

@MainActor
@Observable
final class SystemInformationManager {
    var events = Queue<SystemEvent>(capacity: 50)
    
    private(set) var basicMemoryUsageData = ChartData<UnitInformationStorage>(capacity: 100)
    private(set) var virtualMemoryUsageData = ChartData<UnitInformationStorage>(capacity: 100)
    private(set) var powerUsageData = ChartData<UnitEnergy>(capacity: 100)
    
    var latestBasicMemoryUsageEntry: ChartEntry<UnitInformationStorage>? {
        basicMemoryUsageData.first
    }
    
    var latestVirtualMemoryUsageEntry: ChartEntry<UnitInformationStorage>? {
        virtualMemoryUsageData.first
    }
    
    var latestPowerUsageEntry: ChartEntry<UnitEnergy>? {
        powerUsageData.first
    }
    
    var observedComponents = ObservationMode.Set.all
    var isObserving = false {
        willSet {
            if newValue {
                startObservation()
            } else {
                stopObservation()
            }
        }
    }
    
    private(set) var isLowPowerModeEnabled = SystemInformation.isLowPowerModeEnabled
#if os(iOS)
    var isBatteryMonitoringEnabled: Bool {
        get { SystemInformation.isBatteryMonitoringEnabled }
        set { SystemInformation.isBatteryMonitoringEnabled = newValue }
    }
    private(set) var batteryLevel = SystemInformation.batteryLevel
    private(set) var batteryState = SystemInformation.batteryState
#endif
    private(set) var thermalState = SystemInformation.thermalState
    
    @ObservationIgnored
    private var cancellables = Set<AnyCancellable>()
    
    @ObservationIgnored
    // private weak var displayLink: CADisplayLink?
    private weak var timer: Timer?
    
    @ObservationIgnored
    static let shared = SystemInformationManager()
    
    private init() {
        SystemInformation.appLaunches += 1
        _ = MemoryPressureObserver.shared
        setupBindings()
    }
    
    private func setupBindings() {
        NotificationCenter.default.publisher(for: SystemInformation.powerStateDidChangeNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                let enabled = SystemInformation.isLowPowerModeEnabled
                self?.isLowPowerModeEnabled = enabled
                self?.events.push(.powerState(.init(isLowPowerModeEnabled: enabled)))
            }
            .store(in: &cancellables)
#if os(iOS)
        NotificationCenter.default.publisher(for: SystemInformation.batteryLevelDidChangeNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] _  in
                self?.batteryLevel = SystemInformation.batteryLevel
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: SystemInformation.batteryStateDidChangeNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                let state = SystemInformation.batteryState
                self?.batteryState = state
                if let event = SystemEventType.BatteryState(state) {
                    self?.events.push(.batteryState(event))
                }
            }
            .store(in: &cancellables)
#endif
        NotificationCenter.default.publisher(for: SystemInformation.thermalStateDidChangeNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                let state = SystemInformation.thermalState
                self?.thermalState = state
                if let event = SystemEventType.ThermalState(state) {
                    self?.events.push(.thermalState(event))
                }
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: SystemInformation.didReceiveMemoryPressureUpdateNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] notification in
                guard let userInfo = notification.userInfo as? [String: Any],
                      let event = userInfo["event"] as? DispatchSource.MemoryPressureEvent,
                      let memoryPressure = SystemEventType.MemoryPressure(event) else { return }
                self?.events.push(.memoryPressure(memoryPressure))
            }
        
#if os(iOS)
        NotificationCenter.default.publisher(for: SystemInformation.didReceiveLowMemoryWarningNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.events.push(.memoryWarning)
            }
            .store(in: &cancellables)
#endif
    }
    
    // @objc private func displayRefreshed(_ displayLink: CADisplayLink) {
    //     let date = Date(timeIntervalSinceReferenceDate: displayLink.timestamp)
    @objc private func timerBlock(_ timer: Timer) {
        let date = Date.now
        if observedComponents.contains(.basicMemoryUsage) {
            let update = SystemInformation.basicMemoryUsage
            basicMemoryUsageData.push((date, update))
        }
        if observedComponents.contains(.virtualMemoryUsage) {
            let update = SystemInformation.virtualMemoryUsage
            virtualMemoryUsageData.push((date, update))
        }
        if observedComponents.contains(.powerUsage) {
            let update = SystemInformation.powerUsage
            powerUsageData.push((date, update))
        }
    }
    
    private func startObservation() {
        // defer { isObserving = true }
        
        // displayLink?.invalidate()
        // let displayLink = CADisplayLink(target: self, selector: #selector(displayRefreshed))
        // displayLink.add(to: .main, forMode: .common)
        // self.displayLink = displayLink
        
        timer?.invalidate()
        timer = .scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(timerBlock), userInfo: nil, repeats: true)
        timer!.fire()
    }
    
    private func stopObservation() {
        // defer { isObserving = false }
        
        // displayLink?.invalidate()
        
        timer?.invalidate()
    }
    
    func clearData(for components: ObservationMode.Set = .all) {
        if components.contains(.basicMemoryUsage) {
            basicMemoryUsageData.removeAll()
        }
        if components.contains(.virtualMemoryUsage) {
            virtualMemoryUsageData.removeAll()
        }
        if components.contains(.powerUsage) {
            powerUsageData.removeAll()
        }
    }
}

extension SystemInformationManager {
    enum ObservationMode: Int8, CaseIterable, Identifiable {
        case basicMemoryUsage, virtualMemoryUsage, powerUsage
        
        var id: Int8 { rawValue }
        
        struct Set: OptionSet {
            let rawValue: Int8
            
            static let basicMemoryUsage = Set(rawValue: 1 << ObservationMode.basicMemoryUsage.rawValue)
            static let virtualMemoryUsage = Set(rawValue: 1 << ObservationMode.virtualMemoryUsage.rawValue)
            static let powerUsage = Set(rawValue: 1 << ObservationMode.powerUsage.rawValue)
            
            static let all = Set([.basicMemoryUsage, .virtualMemoryUsage, .powerUsage])
            static let disabled = Set()
        }
    }
}

extension SystemInformationManager.ObservationMode.Set {
    func contains(_ member: SystemInformationManager.ObservationMode) -> Bool {
        self.contains(.init(rawValue: 1 << member.rawValue))
    }
    
    @discardableResult
    mutating func insert(_ newMember: SystemInformationManager.ObservationMode) -> (inserted: Bool, memberAfterInsert: SystemInformationManager.ObservationMode.Set) {
        insert(.init(rawValue: 1 << newMember.rawValue))
    }
    
    @discardableResult
    mutating func remove(_ member: SystemInformationManager.ObservationMode) -> SystemInformationManager.ObservationMode.Set? {
        remove(.init(rawValue: 1 << member.rawValue))
    }
}
