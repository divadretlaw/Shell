//
//  Script.swift
//  Shell
//
//  Created by David Walter on 14.09.24.
//

import Foundation

public final class Script: CommandRunnable, ExpressibleByStringLiteral {
    public let command: Command
    
    // MARK: - init
    
    public convenience init(shell: Shell = .zsh, script: () -> String) {
        self.init(script(), shell: shell)
    }
    
    public init(_ script: String, shell: Shell = .zsh) {
        self.command = Command(arguments: [shell.rawValue, "-c", script], currentDirectoryURL: nil)
    }
    
    // MARK: - ExpressibleByStringLiteral
    
    public convenience init(stringLiteral value: String) {
        self.init(value)
    }
}
