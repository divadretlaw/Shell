//
//  Script.swift
//  Shell
//
//  Created by David Walter on 14.09.24.
//

import Foundation

public final class Script: Runnable, ExpressibleByStringLiteral {
    let command: Command
    
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
    
    // MARK: - Runnable
    
    public var caller: Runnable? {
        command.caller
    }
    
    public var stdout: Pipe {
        command.stdout
    }
    
    public func redirected(from runner: Runnable) -> Runnable {
        command.redirected(from: runner)
    }
    
    public func run() throws {
        try command.run()
    }
    
    public func callAsFunction() async throws {
        try await command()
    }
    
    public func capture() async throws -> String {
        try await command.capture()
    }
    
    public func stream() -> AsyncThrowingStream<ShellOutput, Error> {
        command.stream()
    }
}
