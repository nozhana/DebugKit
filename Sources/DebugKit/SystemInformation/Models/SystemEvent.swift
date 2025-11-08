//
//  SystemEvent.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/8/25.
//

import Foundation

struct SystemEvent: Codable {
    var type: SystemEventType
    var timestamp = Date.now
    
    static func memoryPressure(_ event: SystemEventType.MemoryPressure, timestamp: Date = .now) -> SystemEvent {
        .init(type: .memoryPressure(event), timestamp: timestamp)
    }
    
    static func thermalState(_ event: SystemEventType.ThermalState, timestamp: Date = .now) -> SystemEvent {
        .init(type: .thermalState(event), timestamp: timestamp)
    }
    
#if os(iOS)
    static func batteryState(_ event: SystemEventType.BatteryState, timestamp: Date = .now) -> SystemEvent {
        .init(type: .batteryState(event), timestamp: timestamp)
    }
#endif
    
    static func powerState(_ event: SystemEventType.PowerState, timestamp: Date = .now) -> SystemEvent {
        .init(type: .powerState(event), timestamp: timestamp)
    }
    
    static var memoryWarning: SystemEvent { .init(type: .memoryWarning) }
    static func memoryWarning(timestamp: Date = .now) -> SystemEvent {
        .init(type: .memoryWarning, timestamp: timestamp)
    }
}

enum SystemEventType: Codable {
    enum MemoryPressure: UInt8, Codable {
        case normal, warning, critical
    }
    
    enum ThermalState: UInt8, Codable {
        case nominal, fair, serious, critical
    }
    
#if os(iOS)
    enum BatteryState: UInt8, Codable {
        case unplugged, charging, full
    }
#endif
    
    enum PowerState: UInt8, Codable {
        case normal, lowPower
    }
    
    case memoryPressure(MemoryPressure)
    case memoryWarning
    case thermalState(ThermalState)
#if os(iOS)
    case batteryState(BatteryState)
#endif
    case powerState(PowerState)
}

extension SystemEventType.MemoryPressure {
    init?(_ event: DispatchSource.MemoryPressureEvent) {
        switch event {
        case .normal: self = .normal
        case .warning: self = .warning
        default:
            if event.contains(.critical) {
                self = .critical
            } else if event.contains(.warning) {
                self = .warning
            } else if event.contains(.normal) {
                self = .normal
            } else {
                return nil
            }
        }
    }
}

extension SystemEventType.ThermalState {
    init?(_ event: ProcessInfo.ThermalState) {
        switch event {
        case .nominal: self = .nominal
        case .fair: self = .fair
        case .serious: self = .serious
        case .critical: self = .critical
        @unknown default: return nil
        }
    }
}

#if canImport(UIKit)
import UIKit
extension SystemEventType.BatteryState {
    init?(_ event: UIDevice.BatteryState) {
        switch event {
        case .unplugged: self = .unplugged
        case .charging: self = .charging
        case .full: self = .full
        default: return nil
        }
    }
}
#endif

extension SystemEventType.PowerState {
    init(isLowPowerModeEnabled: Bool) {
        self = isLowPowerModeEnabled ? .lowPower : .normal
    }
}
