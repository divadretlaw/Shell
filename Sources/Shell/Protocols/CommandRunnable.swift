//
//  CommandRunnable.swift
//  Shell
//
//  Created by David Walter on 14.09.24.
//

import Foundation

public protocol CommandRunnable: Runnable {
    var command: Command { get }
}

extension CommandRunnable {
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
