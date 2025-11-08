//
//  mach_task_self.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/7/25.
//

@preconcurrency import Darwin

var mach_task_self: mach_port_t {
    mach_task_self_
}
