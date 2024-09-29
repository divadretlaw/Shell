//
//  ShellEnvironment.swift
//  Shell
//
//  Created by David Walter on 29.09.24.
//

import Foundation

public final class ShellEnvironment: @unchecked Sendable {
    public static let shared = ShellEnvironment()
    
    private var _environment: [String: String]
    private let lock = NSLock()
    
    init() {
        _environment = [:]
    }
    
    public func set(environment: [String: String]) {
        lock.withLock {
            _environment = environment
        }
    }
    
    public var environment: [String: String] {
        let environment = lock.withLock { _environment }
        return ProcessInfo.processInfo.environment.merging(environment) { lhs, rhs in
            rhs
        }
    }
}
