//
//  UnsafeScript.swift
//  Shell
//
//  Created by David Walter on 14.09.24.
//

import Foundation
import SwiftSystem

public final class UnsafeScript: ExpressibleByStringLiteral {
    private let script: String
    private let shell: Shell?
    
    // MARK: - init
    
    public convenience init(shell: Shell? = nil, script: () -> String) {
        self.init(script(), shell: shell)
    }
    
    public init(_ script: String, shell: Shell? = nil) {
        self.script = script
        self.shell = shell
    }
    
    // MARK: - ExpressibleByStringLiteral
    
    public convenience init(stringLiteral value: String) {
        self.init(value)
    }
    
    // MARK: -
    
    private var command: String {
        if let shell {
            "\(shell) -c \"\(script)\""
        } else {
            script
        }
    }
    
    // MARK: -
    
    public func run() throws {
        swiftSystem(command)
    }
    
    public func callAsFunction() async throws {
        let terminationStatus = swiftSystem(command)
        if terminationStatus != 0 {
            throw ShellError.terminated(terminationStatus, stderr: nil)
        }
    }
}
