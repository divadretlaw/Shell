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
    
    public convenience init(script: () -> String) {
        self.init(script())
    }
    
    public init(_ script: String) {
        self.command = Command(arguments: ["zsh", "-c", script], currentDirectoryURL: nil)
    }
    
    // MARK: - ExpressibleByStringLiteral
    
    public convenience init(stringLiteral value: String) {
        self.init(value)
    }
}
