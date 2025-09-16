//
//  UnsafeScript.swift
//  Shell
//
//  Created by David Walter on 14.09.24.
//

import Foundation
import SwiftSystem

/// An unsafe script to run with a shell
public struct UnsafeScript: Sendable, ExpressibleByStringLiteral {
    private let script: String
    private let shell: Shell?

    // MARK: - init

    /// Create an unsafe script to execute
    /// - Parameters:
    ///   - shell: The ``Shell/Shell`` to use. Defaults to `nil`.
    ///   - script: Callback to create a script to execute.
    public init(shell: Shell? = nil, script: () -> String) {
        self.init(script(), shell: shell)
    }

    /// Create an unsafe script to execute
    /// - Parameters:
    ///   - script: The script to execute.
    ///   - shell: The ``Shell/Shell`` to use. Defaults to `nil`.
    public init(_ script: String, shell: Shell? = nil) {
        self.script = script
        self.shell = shell
    }

    // MARK: - ExpressibleByStringLiteral

    public init(stringLiteral value: String) {
        self.init(value)
    }

    // MARK: -

    private var command: String {
        if let shell {
            "\(shell.rawValue) -c \"\(script)\""
        } else {
            script
        }
    }

    // MARK: -

    /// Runs the process and all of its callers
    public func run() throws {
        swiftSystem(command)
    }

    /// Runs the process and all of its callers
    public func callAsFunction() throws {
        let terminationStatus = swiftSystem(command)
        if terminationStatus != 0 {
            throw RunnableError.terminated(terminationStatus, stderr: nil)
        }
    }
}
