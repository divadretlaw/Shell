//
//  Script.swift
//  Shell
//
//  Created by David Walter on 14.09.24.
//

import Foundation

/// A script to run with a shell
public final class Script: CommandRunnable, ExpressibleByStringLiteral {
    public let command: Command
    
    // MARK: - init
    
    /// Create a script to execute
    /// - Parameters:
    ///   - shell: The ``Shell/Shell`` to use. Defaults to ``Shell/Shell/sh``.
    ///   - environment: The environment the command should inherit.
    ///   - script: Callback to create a script to execute.
    public convenience init(
        shell: Shell = .sh,
        environment: [String: String] = ShellEnvironment.shared.environment,
        script: () -> String
    ) {
        self.init(script(), shell: shell)
    }
    
    /// Create a script to execute
    /// - Parameters:
    ///   - script: The script to execute.
    ///   - shell: The ``Shell/Shell`` to use. Defaults to ``Shell/Shell/zsh``.
    ///   - environment: The environment the command should inherit.
    public init(
        _ script: String,
        shell: Shell = .zsh,
        environment: [String: String] = ShellEnvironment.shared.environment
    ) {
        self.command = Command(arguments: [shell.rawValue, "-c", script], currentDirectoryURL: nil, environment: environment)
    }
    
    // MARK: - ExpressibleByStringLiteral
    
    public convenience init(stringLiteral value: String) {
        self.init(value)
    }
}
