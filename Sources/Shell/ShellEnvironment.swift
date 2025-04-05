//
//  ShellEnvironment.swift
//  Shell
//
//  Created by David Walter on 29.09.24.
//

import Foundation
import os

public final class ShellEnvironment: @unchecked Sendable {
    public static let shared = ShellEnvironment()
    
    private let _environment: OSAllocatedUnfairLock<[String: String]>
    
    init() {
        _environment = OSAllocatedUnfairLock(initialState: [:])
    }
    
    public func set(environment: [String: String]) {
        _environment.withLock {
            $0 = environment
        }
    }
    
    public var environment: [String: String] {
        _environment.withLock {
            ProcessInfo.processInfo.environment.merging($0) { lhs, rhs in
                rhs
            }
        }
    }
}
