//
//  MeasurementChart.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/7/25.
//

import Charts
import SwiftUI

struct MeasurementChart<UnitType>: View where UnitType: Dimension {
    private let data: ChartData<UnitType>
    private let followUpdates: Bool
    
    @State private var scrollPosition: Date
    
    init(data: ChartData<UnitType>, followUpdates: Bool = false) {
        self.data = data
        self.followUpdates = followUpdates
        self._scrollPosition = .init(initialValue: data.first?.date ?? .now)
    }
    
    private var scrollPositionBinding: Binding<Date> {
        followUpdates ? .constant(data.first?.date ?? .now) : $scrollPosition
    }
    
    var body: some View {
        Chart {
            ForEach(data.reversed(), id: \.date) { entry in
                AreaMark(x: .value("Timestamp", entry.date), y: .value("Value", entry.value.value))
                    .foregroundStyle(.linearGradient(Color.teal.gradient, startPoint: .bottom, endPoint: .top).tertiary)
                LineMark(x: .value("Timestamp", entry.date), y: .value("Value", entry.value.value))
            }
            .interpolationMethod(.catmullRom)
        }
        .animation(.smooth, value: data.count)
        .chartXVisibleDomain(length: 10)
        .chartScrollableAxes([.horizontal])
        .chartScrollPosition(x: scrollPositionBinding)
        .chartXAxis {
            AxisMarks(values: .stride(by: .second)) { value in
                if let date = value.as(Date.self) {
                    AxisTick()
                    if Calendar.current.component(.second, from: date) % 5 == 0 {
                        AxisGridLine(stroke: .init(lineWidth: 1))
                            .foregroundStyle(.purple.gradient)
                        AxisValueLabel(format: .dateTime.minute().second(), collisionResolution: .greedy)
                    } else {
                        AxisGridLine()
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks { value in
                if let double = value.as(Double.self) {
                    if double == double.rounded() {
                        AxisTick()
                        if Int(double) % 10 == 0 {
                            AxisGridLine(stroke: .init(lineWidth: 1))
                                .foregroundStyle(.teal.gradient)
                            if data.indices.contains(value.index) {
                                if UnitType.self == UnitInformationStorage.self {
                                    AxisValueLabel(format: .byteCount(style: .memory))
                                } else if UnitType.self == UnitEnergy.self {
                                    let measurement = data[value.index].value
                                    AxisValueLabel(measurement.formatted(.measurement(width: .narrow, usage: .asProvided, numberFormatStyle: .number.precision(.fractionLength(0...2)))))
                                }
                            }
                        } else {
                            AxisGridLine()
                        }
                    }
                }
            }
        }
        .onChange(of: followUpdates) {
            guard let date = data.first?.date else { return }
            scrollPosition = date
        }
    }
}

#Preview {
    let data: ChartData<UnitInformationStorage> = (0..<50).reduce(into: []) { partialResult, index in
        let randomBytes = Int.random(in: 16...128)
        let date = Date.now.advanced(by: -TimeInterval(index))
        partialResult.append((date, .init(value: Double(randomBytes), unit: .bytes)))
    }
    
    MeasurementChart(data: data)
}
