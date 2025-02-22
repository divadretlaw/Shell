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
    
    static func expand(arguments: [String]?, environment: [String: String]) -> [String] {
        guard let arguments else { return [] }
        return arguments.map { argument in
            argument.expand(with: environment)
        }
    }
}

private extension String {
    func expand(with environment: [String: String]) -> String {
        do {
            var result = self
            
            for match in matches(of: try Regex("\\${\\w+:-.*?}")) {
                let variable = self[match.range]
                let keyContent = String(variable.dropFirst(2).dropLast())
                let parts = keyContent.split(separator: ":-", maxSplits: 1, omittingEmptySubsequences: false)
                if let key = parts.first, let value = environment[String(key)] {
                    result = result.replacingOccurrences(of: variable, with: value.expand(with: environment))
                } else if let fallback = parts.last {
                    result = result.replacingOccurrences(of: variable, with: String(fallback).expand(with: environment))
                } else {
                    result = result.replacingOccurrences(of: variable, with: "")
                }
            }
            
            for match in matches(of: try Regex("\\${\\w+}")) {
                let variable = self[match.range]
                let key = variable.dropFirst(2).dropLast()
                if let value = environment[String(key)] {
                    result = result.replacingOccurrences(of: variable, with: value.expand(with: environment))
                } else {
                    result = result.replacingOccurrences(of: variable, with: "")
                }
            }
            
            for match in matches(of:  try Regex("\\$\\w+")) {
                let variable = self[match.range]
                let key = variable.dropFirst()
                if let value = environment[String(key)] {
                    result = result.replacingOccurrences(of: variable, with: value.expand(with: environment))
                } else {
                    result = result.replacingOccurrences(of: variable, with: "")
                }
            }
            
            return result
        } catch {
            return self
        }
    }
}
