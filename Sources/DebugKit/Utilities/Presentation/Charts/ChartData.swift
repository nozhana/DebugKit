//
//  ChartData.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/7/25.
//

import Foundation

typealias ChartEntry<T: Unit> = (date: Date, value: Measurement<T>)
typealias ChartData<T: Unit> = Queue<ChartEntry<T>>
