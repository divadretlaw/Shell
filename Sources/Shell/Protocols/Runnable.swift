//
//  Runnable.swift
//  Shell
//
//  Created by David Walter on 10.09.24.
//

import Foundation

public protocol Runnable: Sendable {
    /// The caller of this runnable
    var caller: Runnable? { get }
    /// The `stdout` pipe
    var stdout: Pipe { get }
    
    /// Pipe the output of the ``Runnable`` to the given ``Runnable``
    /// - Parameter caller: The ``Runnable`` that should provides its output as input.
    /// - Returns: The updated ``Runnable``
    func redirected(from caller: Runnable) -> Runnable
    /// Pipe the output of the ``Runnable`` to the given ``Runnable``
    /// - Parameter other: The ``Runnable`` that should receive the output as input.
    /// - Returns: The updated ``Runnable``
    func pipe(_ other: Runnable) -> Runnable
    
    /// Starts the process and all of its callers
    func run() throws
    /// Runs the process and all of its callers
    func callAsFunction() async throws
    /// Runs the process and all of its callers and streams its output
    func stream() -> AsyncThrowingStream<RunnableOutput, Error>
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
