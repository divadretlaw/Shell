//
//  Runnable.swift
//  Shell
//
//  Created by David Walter on 10.09.24.
//

import Foundation

public protocol Runnable: Sendable {
    var caller: Runnable? { get }
    var stdout: Pipe { get }
    
    func redirected(from: Runnable) -> Runnable
    func pipe(_ other: Runnable) -> Runnable
    
    /// Runs the process and all of its callers
    func run() throws
    /// Runs the process and all of its callers and captures its output
    func callAsFunction() async throws
    /// Runs the process and all of its callers and streams its output
    func stream() -> AsyncThrowingStream<ShellOutput, Error>
    /// Runs the process and all of its callers and captures its output
    func capture() async throws -> String
}

extension Runnable {
    public func pipe(_ other: Runnable) -> Runnable {
        other.redirected(from: self)
    }
}

public extension [Runnable] {
    func piped() throws -> Runnable? {
        guard var task = first else { return nil }
        for run in dropFirst() {
            task = task.pipe(run)
        }
        return task
    }
}

public func | (lhs: Runnable, rhs: Runnable) -> Runnable {
    lhs.pipe(rhs)
}
