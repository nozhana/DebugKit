//
//  MeasurementSeriesChart.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/7/25.
//

import Charts
import SwiftUI

struct MeasurementSeriesChart<UnitType>: View where UnitType: Dimension {
    private let series: [ChartData<UnitType>]
    private let titles: [String]
    private let followUpdates: Bool
    
    @State private var scrollPosition: Date
    
    init(series: [ChartData<UnitType>], titles: [String], followUpdates: Bool = false) {
        self.series = series
        self.titles = titles
        self.followUpdates = followUpdates
        self._scrollPosition = .init(initialValue: series.first?.first?.date ?? .now)
    }
    
    init(series: ChartData<UnitType>..., titles: String..., followUpdates: Bool = false) {
        self.init(series: series, titles: titles, followUpdates: followUpdates)
    }
    
    private var scrollPositionBinding: Binding<Date> {
        followUpdates ? .constant(series.first?.first?.date ?? .now) : $scrollPosition
    }
    
    var body: some View {
        Chart {
            ForEach(series.indices, id: \.self) { index in
                let data = series[index].reversed()
                ForEach(data, id: \.date) { entry in
                    if index == 0 {
                        LineMark(x: .value("Timestamp", entry.date), y: .value("Value", entry.value.value))
                            .foregroundStyle(.blue.gradient)
                    } else {
                        AreaMark(x: .value("Timestamp", entry.date), y: .value("Value", entry.value.value))
                            .foregroundStyle(.green.gradient.tertiary)
                    }
                }
                .foregroundStyle(by: .value("Index", titles.indices.contains(index) ? titles[index] : "Series \(index+1)"))
                .interpolationMethod(.catmullRom)
            }
        }
        .animation(.smooth, value: series.first?.count)
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
                            if series.first?.indices.contains(value.index) == true {
                                if UnitType.self == UnitInformationStorage.self {
                                    AxisValueLabel(format: .byteCount(style: .memory))
                                } else if UnitType.self == UnitEnergy.self,
                                          let data = series.first {
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
            guard let date = series.first?.first?.date else { return }
            scrollPosition = date
        }
    }
}
