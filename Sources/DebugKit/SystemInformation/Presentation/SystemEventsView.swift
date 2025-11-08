//
//  SystemEventsView.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/8/25.
//

import SwiftUI

struct SystemEventsView: View {
    @Environment(SystemInformationManager.self) private var manager
    
    var body: some View {
        VStack(spacing: .zero) {
            if manager.events.isEmpty {
                ContentUnavailableView("No Events", systemImage: "circle.dotted")
            } else {
                List(manager.events, id: \.timestamp) { event in
                    SystemEventSectionView(event: event)
                }
            }
        }
        .animation(.smooth, value: manager.events.count)
        .toolbar {
#if os(iOS)
            Menu("Options", systemImage: "ellipsis") {
                Button("Simulate low memory warning", systemImage: "externaldrive.trianglebadge.exclamationmark") {
                    UIApplication.shared.perform(Selector(("_performMemoryWarning")))
                }
            }
#endif
            if !manager.events.isEmpty {
                Button("Clear", systemImage: "clear") {
                    manager.events.removeAll()
                }
            }
        }
        .navigationTitle("System Events")
    }
}

struct SystemEventSectionView: View {
    var event: SystemEvent
    
    var body: some View {
        Section {
            event.type.content
            let dateFormat = {
                let f = Date.FormatStyle.dateTime.hour().minute().second().secondFraction(.fractional(3))
                if Calendar.current.isDateInToday(event.timestamp) { return f }
                return f.month().day()
            }()
            LabeledContent("Timestamp", value: event.timestamp, format: dateFormat)
        } header: {
            event.type.header
        }
    }
}

private extension SystemEventType {
    var header: some View {
        switch self {
        case .memoryPressure:
            Label("Memory Pressure", systemImage: "memorychip")
        case .memoryWarning:
            Label("Low Memory Warning", systemImage: "exclamationmark.triangle")
        case .thermalState:
            Label("Thermal State", systemImage: "thermometer.variable")
#if os(iOS)
        case .batteryState:
            Label("Battery State", systemImage: "batteryblock")
#endif
        case .powerState:
            Label("Low Power Mode", systemImage: "bolt")
        }
    }
    
    @ViewBuilder
    var content: some View {
        switch self {
        case .memoryPressure(let memoryPressure):
            switch memoryPressure {
            case .normal: Label("Normal", systemImage: "externaldrive")
                    .foregroundStyle(.green)
            case .warning: Label("Warning", systemImage: "externaldrive.trianglebadge.exclamationmark")
                    .foregroundStyle(.orange)
            case .critical: Label("Critical", systemImage: "externaldrive.fill.badge.exclamationmark")
                    .foregroundStyle(.red)
            }
        case .memoryWarning:
            Label("The system is running low on memory.", systemImage: "externaldrive.trianglebadge.exclamationmark")
                .foregroundStyle(.orange)
        case .thermalState(let thermalState):
            switch thermalState {
            case .nominal: Label("Nominal", systemImage: "thermometer.low")
                    .foregroundStyle(.green)
            case .fair: Label("Fair", systemImage: "thermometer.medium")
                    .foregroundStyle(.brown)
            case .serious: Label("Serious", systemImage: "thermometer.high")
                    .foregroundStyle(.orange)
            case .critical: Label("Critical", systemImage: "thermometer.sun.fill")
                    .foregroundStyle(.red)
            }
#if os(iOS)
        case .batteryState(let batteryState):
            switch batteryState {
            case .unplugged: Label("Unplugged", systemImage: "battery.50percent")
            case .charging: Label("Charging", systemImage: "battery.100.bolt")
                    .foregroundStyle(.yellow.gradient)
            case .full: Label("Full", systemImage: "battery.100percent")
                    .foregroundStyle(.green)
            }
#endif
        case .powerState(let powerState):
            switch powerState {
            case .lowPower: Label("Enabled", systemImage: "bolt.circle.fill")
                    .foregroundStyle(.green)
            case .normal: Label("Disabled", systemImage: "bolt.circle")
            }
        }
    }
}
