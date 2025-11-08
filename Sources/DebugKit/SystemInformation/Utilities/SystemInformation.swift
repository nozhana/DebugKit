//
//  SystemInformation.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/7/25.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

enum SystemInformation {
    private static let processInfo = ProcessInfo.processInfo
#if os(iOS)
    @MainActor
    private static let device = UIDevice.current
#endif
    
    static var basicMemoryUsage: Measurement<UnitInformationStorage> {
        TaskInformation.basicMemoryUsage
    }
    
    static var virtualMemoryUsage: Measurement<UnitInformationStorage> {
        TaskInformation.virtualMemoryUsage
    }
    
    static var powerUsage: Measurement<UnitEnergy> {
        TaskInformation.powerUsage
    }
    
    @MainActor
    static var operatingSystemName: String {
#if os(macOS)
        "macOS"
#elseif os(iOS)
        device.systemName
#endif
    }
    
    @MainActor
    static var operatingSystemVersion: String {
#if os(macOS)
        processInfo.operatingSystemVersionString
#elseif os(iOS)
        device.systemVersion
#endif
    }
    
    static var isMacCatalystApp: Bool {
        processInfo.isMacCatalystApp
    }
    
    static var isiOSAppOnMac: Bool {
        processInfo.isiOSAppOnMac
    }
    
    @MainActor
    static var deviceModel: String {
#if os(macOS)
        "Mac"
#elseif os(iOS)
        device.localizedModel
#endif
    }
    
    static var isLowPowerModeEnabled: Bool {
        processInfo.isLowPowerModeEnabled
    }
    
    static var powerStateDidChangeNotification: Notification.Name {
        .NSProcessInfoPowerStateDidChange
    }
    
    static var systemUpime: TimeInterval {
        processInfo.systemUptime
    }
    
    static var systemStartup: Date {
        .now.advanced(by: -systemUpime)
    }
    
#if os(iOS)
    @MainActor
    static var isBatteryMonitoringEnabled: Bool {
        get { device.isBatteryMonitoringEnabled }
        set { device.isBatteryMonitoringEnabled = newValue }
    }
    
    @MainActor
    static var batteryLevel: Float {
        isBatteryMonitoringEnabled = true
        return device.batteryLevel
    }
    
    static var batteryLevelDidChangeNotification: Notification.Name {
        UIDevice.batteryLevelDidChangeNotification
    }
    
    @MainActor
    static var batteryState: UIDevice.BatteryState {
        device.batteryState
    }
    
    static var batteryStateDidChangeNotification: Notification.Name {
        UIDevice.batteryStateDidChangeNotification
    }
#endif
    
    static var thermalState: ProcessInfo.ThermalState {
        processInfo.thermalState
    }
    
    static var thermalStateDidChangeNotification: Notification.Name {
        ProcessInfo.thermalStateDidChangeNotification
    }
    
    static var didReceiveMemoryPressureUpdateNotification: Notification.Name {
        MemoryPressureObserver.didReceiveMemoryPressureUpdateNotification
    }
    
#if os(iOS)
    static var didReceiveLowMemoryWarningNotification: Notification.Name {
        UIApplication.didReceiveMemoryWarningNotification
    }
#endif
    
    static var environment: [String: String] {
        processInfo.environment
    }
    
    static var executablePath: String {
        processInfo.arguments.first ?? "N/A"
    }
    
    static var arguments: [String] {
        Array(processInfo.arguments.dropFirst())
    }
    
    static var bundleIdentifier: String {
        Bundle.main.bundleIdentifier ?? "N/A"
    }
    
    static var bundleVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "N/A"
    }
    
    static var bundleBuildNumber: Int {
        guard let string = Bundle.main.infoDictionary?["CFBundleVersion"] as? String,
              let integer = Int(string) else {
            return -1
        }
        return integer
    }
    
    static var bundleName: String {
        Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "N/A"
    }
    
    static var bundleExecutable: String {
        Bundle.main.infoDictionary?["CFBundleExecutable"] as? String ?? "N/A"
    }
    
    static var bundleInfoDictionary: AnyJSONObject {
        guard let info = Bundle.main.infoDictionary,
              let data = try? JSONSerialization.data(withJSONObject: info),
              let json = try? JSONDecoder().decode(AnyJSONObject.self, from: data) else { return [:] }
        return json
    }
    
    static var appLaunches: Int {
        get { UserDefaults.module.integer(forKey: .appLaunchesKey) }
        set { UserDefaults.module.set(newValue, forKey: .appLaunchesKey) }
    }
}

#if os(iOS)
extension UIDevice.BatteryState: @retroactive CustomStringConvertible {
    public var description: String {
        switch self {
        case .unplugged: "Unplugged"
        case .charging: "Charging"
        case .full: "Full"
        default: "Unknown"
        }
    }
}
#endif

extension ProcessInfo.ThermalState: @retroactive CustomStringConvertible {
    public var description: String {
        switch self {
        case .nominal: "Nominal"
        case .fair: "Fair"
        case .serious: "Serious"
        case .critical: "Critical"
        @unknown default: "Unknown (raw: \(rawValue))"
        }
    }
}

extension UserDefaults {
    nonisolated(unsafe) static let module = UserDefaults(suiteName: "com.nozhana.DebugKit.UserDefaults.module")!
}

private extension String {
    static let appLaunchesKey = "appLaunches"
}
