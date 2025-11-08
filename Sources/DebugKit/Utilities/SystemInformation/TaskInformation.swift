//
//  TaskInformation.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/7/25.
//

import Foundation

enum TaskInformation {
  private static func taskInfo<T>(_ info: T, _ flavor: Int32) -> T {
    var info = info
    var count = mach_msg_type_number_t(MemoryLayout<T>.size / MemoryLayout<natural_t>.size)
    _ = withUnsafeMutablePointer(to: &info) {
      $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
        task_info(mach_task_self, task_flavor_t(flavor), $0, &count)
      }
    }
    return info
  }
  
  static var basic: task_basic_info { taskInfo(task_basic_info(), TASK_BASIC_INFO) }
  static var events: task_events_info { taskInfo(task_events_info(), TASK_EVENTS_INFO) }
  static var thread_times: task_thread_times_info { taskInfo(task_thread_times_info(), TASK_THREAD_TIMES_INFO) }
  static var absolutetime: task_absolutetime_info { taskInfo(task_absolutetime_info(), TASK_ABSOLUTETIME_INFO) }
  static var kernelmemory: task_kernelmemory_info { taskInfo(task_kernelmemory_info(), TASK_KERNELMEMORY_INFO) }
  static var affinity_tag: task_affinity_tag_info { taskInfo(task_affinity_tag_info(), TASK_AFFINITY_TAG_INFO) }
  static var dyld: task_dyld_info { taskInfo(task_dyld_info(), TASK_DYLD_INFO) }
  static var extmod: task_extmod_info { taskInfo(task_extmod_info(), TASK_EXTMOD_INFO) }
  static var power: task_power_info_v2 { taskInfo(task_power_info_v2(), TASK_POWER_INFO_V2) }
  static var vm: task_vm_info { taskInfo(task_vm_info(), TASK_VM_INFO) }
  static var trace_memory: task_trace_memory_info { taskInfo(task_trace_memory_info(), TASK_TRACE_MEMORY_INFO) }
  static var wait_state: task_wait_state_info { taskInfo(task_wait_state_info(), TASK_WAIT_STATE_INFO) }
  static var flags: task_flags_info { taskInfo(task_flags_info(), TASK_FLAGS_INFO) }
}

extension TaskInformation {
    static var basicMemoryUsage: Measurement<UnitInformationStorage> {
        .init(value: Double(basic.resident_size), unit: .bytes)
    }
    
    static var virtualMemoryUsage: Measurement<UnitInformationStorage> {
        .init(value: Double(vm.internal), unit: .bytes)
    }
    
    static var powerUsage: Measurement<UnitEnergy> {
        .init(value: Double(power.task_energy) / 1_000_000_000, unit: .joules)
    }
}
