//
//  SystemInformationView.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/7/25.
//

import SwiftUI

struct SystemInformationView: View {
    @Environment(SystemInformationManager.self) private var manager
    
    var body: some View {
        List {
            Section {
                // Series chart
                @Bindable var manager = manager
                Toggle("Observe Changes", systemImage: "eye.fill", isOn: $manager.isObserving)
            }
            
            Section {
                Toggle("Basic Memory Usage", isOn: toggleBinding(for: .basicMemoryUsage))
                Toggle("VM Memory Usage", isOn: toggleBinding(for: .virtualMemoryUsage))
                Toggle("Power Usage", isOn: toggleBinding(for: .powerUsage))
            } header: {
                Label("Observation Options", systemImage: "filemenu.and.selection")
            }
            
            Section {
                if let latestBasicMemoryEntry = manager.latestBasicMemoryUsageEntry,
                   let latestVirtualMemoryEntry = manager.latestVirtualMemoryUsageEntry {
                    MeasurementSeriesChart(
                        series: manager.basicMemoryUsageData, manager.virtualMemoryUsageData,
                        titles: "Basic Memory Usage", "VM Memory Usage",
                        followUpdates: manager.isObserving
                    )
                    .frame(height: 300)
                    
                    LabeledContent("Basic Memory Usage", value: latestBasicMemoryEntry.value, format: .byteCount(style: .memory))
                        .contentTransition(.numericText(value: latestBasicMemoryEntry.value.value))
                        .animation(.smooth, value: latestBasicMemoryEntry.value)
                    LabeledContent("VM Memory Usage", value: latestVirtualMemoryEntry.value, format: .byteCount(style: .memory))
                        .contentTransition(.numericText(value: latestVirtualMemoryEntry.value.value))
                        .animation(.smooth, value: latestVirtualMemoryEntry.value)
                    
                    let dateFormat = {
                        let f = Date.FormatStyle.dateTime.hour().minute().second().secondFraction(.fractional(1))
                        if Calendar.current.isDateInToday(latestBasicMemoryEntry.date) { return f }
                        return f.month().day()
                    }()
                    LabeledContent("Last Updated", value: latestBasicMemoryEntry.date, format: dateFormat)
                        .contentTransition(.numericText(value: latestBasicMemoryEntry.date.timeIntervalSinceReferenceDate))
                        .animation(.smooth, value: latestBasicMemoryEntry.date)
                }
            } header: {
                Label("Memory Usage", systemImage: "memorychip")
            }
            
            Section {
                if let latest = manager.latestPowerUsageEntry {
                    MeasurementChart(data: manager.powerUsageData, followUpdates: manager.isObserving)
                        .frame(height: 300)
                    
                    LabeledContent("Energy Consumption", value: latest.value, format: .measurement(width: .abbreviated, usage: .asProvided, numberFormatStyle: .number.precision(.fractionLength(0...2))))
                        .contentTransition(.numericText(value: latest.value.value))
                        .animation(.smooth, value: latest.value)
                    
                    let dateFormat = {
                        let f = Date.FormatStyle.dateTime.hour().minute().second().secondFraction(.fractional(1))
                        if Calendar.current.isDateInToday(latest.date) { return f }
                        return f.month().day()
                    }()
                    LabeledContent("Last Updated", value: latest.date, format: dateFormat)
                        .contentTransition(.numericText(value: latest.date.timeIntervalSinceReferenceDate))
                        .animation(.smooth, value: latest.date)
                }
            } header: {
                Label("Power Usage", systemImage: "powermeter")
            }
        }
        .navigationTitle("System Information")
    }
    
    private func toggleBinding(for observationMode: SystemInformationManager.ObservationMode) -> Binding<Bool> {
        Binding {
            manager.observedComponents.contains(observationMode)
        } set: {
            if $0 {
                manager.observedComponents.insert(observationMode)
            } else {
                manager.observedComponents.remove(observationMode)
            }
        }
    }
}
